//
//  main.swift
//  mtg-cli
//
//  Created by Andrew McKnight on 12/23/23.
//

import Foundation
import mtg
import SwiftCSV
import ArgumentParser
import Progress

/** 
 * A command-line tool to manage a collection of Magic: the Gathering cards.
 */
@main struct MTG: ParsableCommand {
    static let configuration = CommandConfiguration(abstract: "Take a CSV file from a card scanner app like TCGPlayer and incorporate the cards it describes into a database of cards describing a base collection and any number of constructed decks. Cards in constructed decks are not duplicated in the base collection.")
    
    @Flag(name: .long, help: "Migrate the existing managed CSVs to include any new features developed after they were generated.")
    var migrate: Bool = false
    
    @Flag(name: .long, help: "Add the cards in the input CSV to the base collection.")
    var addToCollection: Bool = false
    
    @Option(name: .long, help: "Remove the cards in the input CSV from the base collection. You may want to do this if you've sold the cards.")
    var removeFromCollection: Bool = false
    
    @Option(name: .long, help: "Add new cards not already in the base collection directly to a deck.")
    var addToDeck: String? = nil
    
    @Option(name: .long, help: "Move the cards from the base collection to a deck.")
    var moveToDeckFromCollection: String? = nil
    
    @Option(name: .long, help: "Remove the cards from the specified deck and place them in the base collection.")
    var moveToCollectionFromDeck: String? = nil
    
    @Option(name: .long, help: "Custom location of the managed CSV files.")
    var collectionPath: String = "."
    
    @Flag(name: .long, help: "Create backup files before modifying any managed CSV file.")
    var backupFilesBeforeModifying: Bool = false
    
    @Option(name: .long, help: "Location of Scryfall data dump file.")
    var scryfallDataDumpPath: String? = nil
    
    @Argument(help: "A path to a CSV file or directories containing CSV files that contain cards to process according to the specified options.")
    var inputPath: String?
    
    lazy var decksDirectory: String = {
        (collectionPath as NSString).appendingPathComponent("decks")
    }()
    
    lazy var collectionFile: String = {
        (collectionPath as NSString).appendingPathComponent("collection.csv")
    }()
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

extension MTG {
    var scryfallCards: ScryfallCardLookups? {
        var scryfallLoadProgress: ProgressBar?
        guard let scryfallDataDumpPath else {
            print("[Scryfall] no path to bulk data download provided, will not fill in Scryfall info")
            return nil
        }
        
        return parseScryfallDataDump(path: scryfallDataDumpPath, progressInit: {
            scryfallLoadProgress = ProgressBar(count: $0, configuration: progressBarConfiguration(with: "Loading Scryfall local data:"))
        }, progress: {
            scryfallLoadProgress?.next()
        })
    }
    
    mutating func run() throws {
        if migrate {
            let deckPaths: [String]
            do {
                deckPaths = try fileManager.contentsOfDirectory(atPath: decksDirectory)
            } catch {
                fatalError("Failed to find deck lists: \(error)")
            }
            
            let scryfallCards = scryfallCards
            
            do {
                let allPaths = deckPaths.map({ deckPath(fileName: $0)}) + [collectionFile]
                for path in allPaths {
                    guard !path.contains(".DS_Store") else { continue }
                    guard !path.contains(".bak") else { continue }
                    
                    let csvContents = try EnumeratedCSV(url: URL(filePath: path))
                    var cards = [CardQuantity]()
                    var scryfallProgress = ProgressBar(count: csvContents.rows.count, configuration: progressBarConfiguration(with: "Scryfall fetches:"))
                    do {
                        try csvContents.enumerateAsDict { keyValues in
                            scryfallProgress.next()
                            guard let quantity = keyValues["Quantity"]?.unsignedIntegerValue else { fatalError("failed to parse field") }
                            
                            guard var card = Card(managedCSVKeyValues: keyValues) else {
                                fatalError("Failed to parse card from row")
                            }
                            
                            // fill in scryfall data if not already present
                            if let scryfallCards, card.scryfallInfo == nil {
                                card.fetchScryfallInfo(scryfallCards: scryfallCards)
                            }
                            
                            cards.append((card: card, quantity: quantity))
                        }
                    } catch {
                        fatalError("Failed enumerating CSV file: \(error.localizedDescription)")
                    }
                    
                    var consolidationProgress: ProgressBar?
                    var preexistingParseProgress: ProgressBar?
                    write(
                        cards: cards,
                        path: path,
                        backup: backupFilesBeforeModifying,
                        migrate: true,
                        preexistingCardParseProgressInit: {
                            preexistingParseProgress = ProgressBar(count: $0, configuration: progressBarConfiguration(with: "Parsing preexisting entries:"))
                        },
                        preexistingCardParseProgress: {
                            preexistingParseProgress?.next()
                        }, countConsolidationProgressInit: {
                            consolidationProgress = ProgressBar(count: $0, configuration: progressBarConfiguration(with: "Consolidating entries:"))
                        }, countConsolidationProgress: {
                            consolidationProgress?.next()
                        }
                    )
                }
            } catch {
                fatalError("Failed to parse csv: \(error)")
            }
        }
        
        else if let deckName = moveToDeckFromCollection {
            
        }
        
        else if let deckName = addToDeck {
            guard let inputPath else { fatalError("Must supply a path to a CSV or directory of CSVs with input cards.") }
            if !FileManager.default.fileExists(atPath: decksDirectory) {
                do {
                    try FileManager.default.createDirectory(atPath: decksDirectory, withIntermediateDirectories: false)
                } catch {
                    fatalError("Couldn't create decks directory")
                }
            }
            
            let scryfallCards = scryfallCards
            
            let cards = processInputPaths(path: inputPath, scryfallCards: scryfallCards)
            var preexistingParseProgress: ProgressBar?
            var consolidationProgress: ProgressBar?
            write(
                cards: cards,
                path: deckPath(fileName: "\(deckName).csv"),
                backup: backupFilesBeforeModifying,
                migrate: false,
                preexistingCardParseProgressInit: {
                    preexistingParseProgress = ProgressBar(count: $0, configuration: progressBarConfiguration(with: "Parsing preexisting entries:"))
                },
                preexistingCardParseProgress: {
                    preexistingParseProgress?.next()
                }, countConsolidationProgressInit: {
                    consolidationProgress = ProgressBar(count: $0, configuration: progressBarConfiguration(with: "Consolidating entries:"))
                }, countConsolidationProgress: {
                    consolidationProgress?.next()
                }
            )
        }
        
        else if let deckName = moveToCollectionFromDeck {
            
        }
        
        else if addToCollection {
            guard let inputPath else { fatalError("Must supply a path to a CSV or directory of CSVs with input cards.") }
            
            let scryfallCards = scryfallCards
            
            let cards = processInputPaths(path: inputPath, scryfallCards: scryfallCards)
            var preexistingParseProgress: ProgressBar?
            var consolidationProgress: ProgressBar?
            write(
                cards: cards,
                path: collectionFile,
                backup: backupFilesBeforeModifying,
                migrate: false,
                preexistingCardParseProgressInit: {
                    preexistingParseProgress = ProgressBar(count: $0, configuration: progressBarConfiguration(with: "Parsing preexisting entries:"))
                },
                preexistingCardParseProgress: {
                    preexistingParseProgress?.next()
                }, countConsolidationProgressInit: {
                    consolidationProgress = ProgressBar(count: $0, configuration: progressBarConfiguration(with: "Consolidating entries:"))
                }, countConsolidationProgress: {
                    consolidationProgress?.next()
                }
            )
        }
        
        else if removeFromCollection {
            
        }
        
        else {
            throw Error.unexpectedOption
        }
    }
    
    mutating func deckPath(fileName: String) -> String {
        (decksDirectory as NSString).appendingPathComponent(fileName)
    }
}


