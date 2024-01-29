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
            var scryfallLoadProgress: ProgressBar?
            scryfallCards = parseScryfallDataDump(path: scryfallDataDumpPath, progressInit: {
                scryfallLoadProgress = ProgressBar(count: $0, configuration: progressBarConfiguration(with: "Loading Scryfall local data:"))
            }, progress: {
                scryfallLoadProgress?.next()
            })
            
            server["/cardBySetAndNumber/:set/:number"] = { return self.serveCardBySetAndNumber(request: $0, scryfallCards: self.scryfallCards) }
            server["/cardByNameAndSet//:name/:set"] = { return self.serveCardByNameAndSet(request: $0, scryfallCards: self.scryfallCards) }
            
            try server.start()
            
            while true {
                sleep(1)
            }
        }
        
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
    }
}
