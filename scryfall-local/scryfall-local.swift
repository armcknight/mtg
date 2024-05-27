//
//  main.swift
//  scryfall-local
//
//  Created by Andrew McKnight on 1/27/24.
//

import Progress
import Foundation
import mtg
import ArgumentParser
import Progress
import scryfall
import Swifter

/**
 * A command-line tool to run a local HTTP server to serve Scryfall bulk data downloads that mimics the API endpoint to request cards e.g. https://api.scyfall.com/cards/$set-code/$card-number
 */
@main struct ScryfallLocal: ParsableCommand {
    static let configuration = CommandConfiguration(abstract: "Manage and use local Scryfall bulk data files to query for card information.", subcommands: [Serve.self, Download.self])
}

func progressBarConfiguration(with title: String) -> [ProgressElementType] {
    [
        ProgressIndex(),
        ProgressString(string: title),
        ProgressBarLine(),
        ProgressPercent(),
        ProgressTimeEstimates()
    ]
}

let jsonEncoder = JSONEncoder()

extension ScryfallLocal {
    class Serve: ParsableCommand {
        // no-op, but must be implemented for this ParsableCommand to be a class, which is required for the lazy var scryfallCards to be lazy because the server callback will mutate it, and if this is a struct then the escaping closures the server uses can't mutate the instance
        required init() {}
        
        static let configuration = CommandConfiguration(abstract: "Run a local HTTP server that serves requests into a Scryfall bulk data JSON file.")
        
        @Argument(help: "Location of Scryfall bulk data file.")
        var scryfallDataDumpPath: String
        
        lazy var server = HttpServer()
        lazy var scryfallCards: ScryfallCardLookups? = nil
        
        func run() throws {
            try server.start()
            
            var scryfallLoadProgress: ProgressBar?
            scryfallCards = parseScryfallDataDump(path: scryfallDataDumpPath, progressInit: {
                scryfallLoadProgress = ProgressBar(count: $0, configuration: progressBarConfiguration(with: "Loading Scryfall local data:"))
            }, progress: {
                scryfallLoadProgress?.next()
            })
            
            server["/cardBySetAndNumber/:set/:number"] = { return self.serveCardBySetAndNumber(request: $0, scryfallCards: self.scryfallCards) }
            server["/cardByNameAndSet//:name/:set"] = { return self.serveCardByNameAndSet(request: $0, scryfallCards: self.scryfallCards) }
            
            while true {
                sleep(1)
            }
        }
        
        // the default endpoint to use to request cards
        func serveCardBySetAndNumber(request: HttpRequest, scryfallCards: ScryfallCardLookups?) -> HttpResponse {
            guard let set = request.params[":set"] else {
                return .badRequest(.text("Must include a set parameter in the path"))
            }
            guard let number = request.params[":number"] else {
                return .badRequest(.text("Must include a card number parameter in the path"))
            }
            guard let card = scryfallCards?.bySetAndNumber[set]?[number] else {
                return .notFound
            }
            do {
                let jsonData = try jsonEncoder.encode(card)
                return .ok(.data(jsonData))
            } catch {
                return .internalServerError
            }
        }
        
        // currently only made available to query for cards from The List
        func serveCardByNameAndSet(request: HttpRequest, scryfallCards: ScryfallCardLookups?) -> HttpResponse {
            guard let name = request.params[":name"] else {
                return .badRequest(.text("Must include a card name parameter in the path"))
            }
            guard let set = request.params[":set"] else {
                return .badRequest(.text("Must include a set parameter in the path"))
            }
            guard let card = scryfallCards?.byNameAndSet[name]?[set] else {
                return .notFound
            }
            do {
                let jsonData = try jsonEncoder.encode(card)
                return .ok(.data(jsonData))
            } catch {
                return .internalServerError
            }
        }
    }
}

extension ScryfallLocal {
    struct Download: ParsableCommand {
        static let configuration = CommandConfiguration(abstract: "Manage local downloads of Scryfall bulk data.")
        
        @Argument(help: "Directory in which to save downloaded Scryfall bulk data file.")
        var scryfallDataDumpPath: String
        
        func run() throws {
            let bulkDataInfoResult: Result<ScryfallBulkData, RequestError> = synchronouslyRequest(request: bulkDataRequest())
            switch bulkDataInfoResult {
            case .failure(let error):
                logger.notice("Failed to get bulk data download information: \(error)")
                return
            case .success(let bulkDataInfo):
                let lastUpdateDate = dateFormatter.date(from: bulkDataInfo.updated_at.replacingOccurrences(of: "+", with: "Z"))!
                let fm = FileManager.default
                func date(from path: String) -> Date {
                    let dateSegment = path.replacingOccurrences(of: "default-cards-", with: "").replacingOccurrences(of: ".json", with: "")
                    let year = Int(dateSegment[dateSegment.startIndex...dateSegment.index(dateSegment.startIndex, offsetBy: 3)])
                    let month = Int(dateSegment[dateSegment.index(dateSegment.startIndex, offsetBy: 4)...dateSegment.index(dateSegment.startIndex, offsetBy: 5)])
                    let day = Int(dateSegment[dateSegment.index(dateSegment.startIndex, offsetBy: 6)...dateSegment.index(dateSegment.startIndex, offsetBy: 7)])
                    let hour = Int(dateSegment[dateSegment.index(dateSegment.startIndex, offsetBy: 8)...dateSegment.index(dateSegment.startIndex, offsetBy: 9)])
                    let minute = Int(dateSegment[dateSegment.index(dateSegment.startIndex, offsetBy: 10)...dateSegment.index(dateSegment.startIndex, offsetBy: 11)])
                    let second = Int(dateSegment[dateSegment.index(dateSegment.startIndex, offsetBy: 12)...dateSegment.index(dateSegment.startIndex, offsetBy: 13)])
                    let dc = DateComponents(calendar: Calendar(identifier: .gregorian), timeZone: TimeZone(secondsFromGMT: 0), year: year, month: month, day: day, hour: hour, minute: minute, second: second)
                    return dc.date!
                }
                if let mostRecentDownload = try fm.contentsOfDirectory(atPath: scryfallDataDumpPath).filter({
                    $0.contains("default-cards-") && $0.contains(".json")
                }).sorted(by: { a, b in
                    date(from: a).compare(date(from: b)) != .orderedAscending
                }).first {
                    let mostRecentUpdateDate = date(from: mostRecentDownload)
                    let interval = lastUpdateDate.timeIntervalSince(mostRecentUpdateDate)
                    let twelveHours: TimeInterval = 12 * 60 * 60
                    if interval < twelveHours {
                        let nextDownloadDate = lastUpdateDate.addingTimeInterval(twelveHours)
                        logger.notice("No new bulk data to download, most recent is from \(humanReadableDateFormatter.string(from: mostRecentUpdateDate)), try again at \(humanReadableDateFormatter.string(from: nextDownloadDate))")
                        return
                    }
                }
                
                let file = URL(filePath: scryfallDataDumpPath).appending(component: bulkDataInfo.download_uri.lastPathComponent)
                try synchronouslyDownload(request: URLRequest(url: bulkDataInfo.download_uri), to: file)
                logger.info("Downloaded new scryfall bulk data to \(file)")
            }
        }
    }
}
