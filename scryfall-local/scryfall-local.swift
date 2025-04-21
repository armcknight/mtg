//
//  main.swift
//  scryfall-local
//
//  Created by Andrew McKnight on 1/27/24.
//

#if os(macOS)

import Progress
import Foundation
import mtg
import ArgumentParser
import scryfall
import Swifter

/**
 * A command-line tool to run a local HTTP server to serve Scryfall bulk data downloads that mimics the API endpoint to request cards e.g. https://api.scyfall.com/cards/$set-code/$card-number
 */
@available(macOS 13.0, *)
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

@available(macOS 13.0, *)
extension ScryfallLocal {
    @available(macOS 13.0, *)
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
            let fullPath = (scryfallDataDumpPath as NSString).expandingTildeInPath
            scryfallCards = parseScryfallDataDump(path: fullPath, progressInit: {
                scryfallLoadProgress = ProgressBar(count: UInt64($0), configuration: progressBarConfiguration(with: "Loading Scryfall local data:"))
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

@available(macOS 13.0, *)
extension ScryfallLocal {
    struct Download: ParsableCommand {
        static let configuration = CommandConfiguration(abstract: "Manage local downloads of Scryfall bulk data.")

        enum Error: Swift.Error {
            /// Path should point to a directory to contain bulk data download files, but the path itself is a file. This is unrecoverable because I don't want to delete that file to create the directory.
            case pathIsAFile
        }

        @Argument(help: "Directory in which to save downloaded Scryfall bulk data file.")
        var scryfallDataDumpPath: String

        func run() throws {
            logger.info("Retrieving latest Scryfall bulk data download information...")
            let bulkDataInfoResult: Result<ScryfallBulkData, RequestError> = synchronouslyRequest(request: bulkDataRequest())
            switch bulkDataInfoResult {
            case .failure(let error):
                logger.notice("Failed to get bulk data download information: \(error)")
                return
            case .success(let bulkDataInfo):
                let lastUpdateDate = dateFormatter.date(from: bulkDataInfo.updated_at.replacingOccurrences(of: "+", with: "Z"))!
                let fm = FileManager.default
                let fullPath = (scryfallDataDumpPath as NSString).expandingTildeInPath
                if !fm.fileExists(atPath: fullPath) {
                    try fm.createDirectory(at: URL(fileURLWithPath: fullPath), withIntermediateDirectories: true)
                }
                let attributes = try fm.attributesOfItem(atPath: fullPath)
                guard let fileType = attributes[FileAttributeKey.type] as? String, fileType == FileAttributeType.typeDirectory.rawValue else {
                    logger.error("The provided path (\(fullPath)) is a file, but must be a directory.")
                    throw Error.pathIsAFile
                }
                if let mostRecentDownload = try fm.contentsOfDirectory(atPath: fullPath).filter({
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
                
                let file = URL(filePath: fullPath).appending(component: bulkDataInfo.download_uri.lastPathComponent)
                let progressReporter = DownloadProgressReporter(progressBarConfiguration: progressBarConfiguration(with: "Loading Scryfall local data:"))
                logger.info("Starting download of new scryfall bulk data to \(file)")
                try synchronouslyDownload(request: URLRequest(url: bulkDataInfo.download_uri), to: file, delegate: progressReporter)
                logger.info("Downloaded new scryfall bulk data to \(file)")
            }
        }

        /// Take a scryfall bulk data download filename and extract the date
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
    }
}

#endif // os(macOS)
