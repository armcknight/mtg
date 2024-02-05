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
    
    @Option(name: .long, help: "Move the cards from the base collection to a deck. If the card doesn't already exist in the collection, its record will be \"created\" in the deck.")
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
    mutating func run() throws {
        if migrate {
            let deckPaths: [String]
            do {
                deckPaths = try fileManager.contentsOfDirectory(atPath: decksDirectory)
            } catch {
                fatalError("Failed to find deck lists: \(error)")
            }
            
            do {
                let allPaths = deckPaths.map({ path(forDeck: $0)}) + [collectionFile]
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
                            if card.scryfallInfo == nil {
                                card.fetchScryfallInfo()
                            }
                            
                            cards.append((card: card, quantity: quantity))
                        }
                    } catch {
                        fatalError("Failed enumerating CSV file: \(error.localizedDescription)")
                    }
                    
                    let cardsToWrite = combine(cards: cards, withCardsIn: path)
                    write(
                        cards: cards,
                        path: path,
                        backup: backupFilesBeforeModifying,
                        migrate: true
                    )
                }
            } catch {
                fatalError("Failed to parse csv: \(error)")
            }
        }
        
        else if let deckName = moveToDeckFromCollection {
            guard let inputPath else { fatalError("Must supply a path to a CSV or directory of CSVs with input cards.") }
            ensureDecksDirectory()
            
            let cardsToMove = processInputPaths(path: inputPath)
            
            let leftoverCollectionCards = subtract(cards: cardsToMove, fromCardsIn: collectionFile)
            write(cards: leftoverCollectionCards, path: collectionFile, backup: backupFilesBeforeModifying, migrate: false)
            
            let deckPath = path(forDeck: deckName)
            let deckAfterAdding = combine(cards: cardsToMove, withCardsIn: deckPath)
            write(cards: deckAfterAdding, path: deckPath, backup: backupFilesBeforeModifying, migrate: false)
        }
        
        else if let deckName = addToDeck {
            guard let inputPath else { fatalError("Must supply a path to a CSV or directory of CSVs with input cards.") }
            ensureDecksDirectory()
            
            let cards = processInputPaths(path: inputPath)
            let deckPath = path(forDeck: deckName)
            let cardsToWrite = combine(cards: cards, withCardsIn: deckPath)
            write(
                cards: cardsToWrite,
                path: deckPath,
                backup: backupFilesBeforeModifying,
                migrate: false
            )
        }
        
        else if let deckName = moveToCollectionFromDeck {
            guard let inputPath else { fatalError("Must supply a path to a CSV or directory of CSVs with input cards.") }
            
            let deckPath = path(forDeck: deckName)
            guard FileManager.default.fileExists(atPath: deckPath) else { fatalError("No file contains contents of deck named \(deckName).") }
            
            let cardsToMove = processInputPaths(path: inputPath)
            let leftoverDeckCards = subtract(cards: cardsToMove, fromCardsIn: deckPath)
            write(cards: leftoverDeckCards, path: deckPath, backup: backupFilesBeforeModifying, migrate: false)
            
            let collectionAfterAdding = combine(cards: cardsToMove, withCardsIn: collectionFile)
            write(cards: collectionAfterAdding, path: collectionFile, backup: backupFilesBeforeModifying, migrate: false)
        }
        
        else if addToCollection {
            guard let inputPath else { fatalError("Must supply a path to a CSV or directory of CSVs with input cards.") }
            
            let cards = processInputPaths(path: inputPath)
            let cardsToWrite = combine(cards: cards, withCardsIn: collectionFile)
            write(
                cards: cardsToWrite,
                path: collectionFile,
                backup: backupFilesBeforeModifying,
                migrate: false
            )
        }
        
        else if removeFromCollection {
            guard let inputPath else { fatalError("Must supply a path to a CSV or directory of CSVs with input cards.") }
            let cardsToRemove = processInputPaths(path: inputPath)
            let leftoverCards = subtract(cards: cardsToRemove, fromCardsIn: collectionFile)
            write(cards: leftoverCards, path: collectionFile, backup: backupFilesBeforeModifying, migrate: false)
        }
        
        else {
            throw Error.unexpectedOption
        }
    }
}

// MARK: Private
private extension MTG {
    func subtract(cards: [CardQuantity], fromCardsIn file: String) -> [CardQuantity] {
        var preexistingParseProgress: ProgressBar?
        var collectionCards = parseManagedCSV(
            at: file,
            progressInit: {
                preexistingParseProgress = ProgressBar(count: $0, configuration: progressBarConfiguration(with: "Parsing preexisting entries:"))
            },
            progress: {
                preexistingParseProgress?.next()
            }
        )
        
        for card in cards {
            guard let index = collectionCards.firstIndex( where:{ collectionCard in
                equalCards(a: card.card, b: collectionCard.card)
            }) else {
                print("[mtg-cli] Could not find card (\"\(card.card.name)\": \(card.card.setCode) \(card.card.cardNumber))")
                continue
            }
            
            var collectionCard = collectionCards[index]
            if collectionCard.quantity == 1 {
                collectionCards.remove(at: index)
            } else {
                collectionCard.quantity -= 1
            }
        }
        
        return collectionCards
    }
    
    func combine(cards: [CardQuantity], withCardsIn file: String) -> [CardQuantity] {
        var preexistingParseProgress: ProgressBar?
        var consolidationProgress: ProgressBar?
        return combinedWithPreviousCards(
            cards: cards,
            path: file,
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
    
    mutating func ensureDecksDirectory() {
        if !FileManager.default.fileExists(atPath: decksDirectory) {
            do {
                try FileManager.default.createDirectory(atPath: decksDirectory, withIntermediateDirectories: false)
            } catch {
                fatalError("Couldn't create decks directory")
            }
        }
    }
    
    mutating func path(forDeck named: String) -> String {
        ((decksDirectory as NSString).appendingPathComponent(named) as NSString).appendingPathExtension("csv")!
    }
}


