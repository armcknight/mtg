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
import Logging

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
    
    @Option(name: .long, help: "Retired a deck: keep its list, but move its cards back into the collection.")
    var retireDeck: String? = nil
    
    @Flag(name: .long, help: "When adding cards to a deck, also retire that deck")
    var retire: Bool = false

    @Option(name: .long, help: "Log level.")
    var logLevel: String? = nil
    
    @Argument(help: "A path to a CSV file or directories containing CSV files that contain cards to process according to the specified options.")
    var inputPath: String?

    @Flag(name: .long, help: "Display progress of each long-running operation.")
    var progress: Bool = false

    /// expand any tildes denoting user home portion of input path
    lazy var fullCollectionPath: String = {
        (collectionPath as NSString).expandingTildeInPath
    }()

    lazy var fullInputPath: String? = {
        (inputPath as? NSString)?.expandingTildeInPath
    }()

    lazy var decksDirectory: String = {
        (fullCollectionPath as NSString).appendingPathComponent("decks")
    }()
    
    lazy var retiredDecksDirectory: String = {
        (decksDirectory as NSString).appendingPathComponent("retired")
    }()
    
    lazy var collectionFile: String = {
        (fullCollectionPath as NSString).appendingPathComponent("collection.csv")
    }()

    func progressBar(count: Int, title: String) -> ProgressBar? {
        guard progress else { return nil }
        return ProgressBar(count: count, configuration: [
            ProgressIndex(),
            ProgressString(string: title),
            ProgressBarLine(),
            ProgressPercent(),
            ProgressTimeEstimates()
        ])
    }
}

extension MTG {
    mutating func run() throws {
        let defaultLogLevel = Logger.Level.info
        if let logLevel = logLevel, let logLevelCase = Logger.Level(rawValue: logLevel) {
            logger.logLevel = logLevelCase
        } else {
            logger.logLevel = defaultLogLevel
        }

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
                    var scryfallProgress = progressBar(count: csvContents.rows.count, title: "Scryfall fetches:")
                    do {
                        try csvContents.enumerateAsDict { keyValues in
                            scryfallProgress?.next()
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
                        cards: cardsToWrite,
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
            guard let fullInputPath else { fatalError("Must supply a path to a CSV or directory of CSVs with input cards.") }
            
            logger.info("Moving cards in \"\(fullInputPath)\" to deck \"\(deckName)\" from collection")
            
            ensureDecksDirectory()
            
            let cardsToMove = processInputPaths(path: fullInputPath)
            
            let leftoverCollectionCards = subtract(cards: cardsToMove, fromCardsIn: collectionFile)
            write(cards: leftoverCollectionCards, path: collectionFile, backup: backupFilesBeforeModifying, migrate: false)
            
            let deckPath = path(forDeck: deckName)
            let deckAfterAdding = combine(cards: cardsToMove, withCardsIn: deckPath)
            write(cards: deckAfterAdding, path: deckPath, backup: backupFilesBeforeModifying, migrate: false)
        }
        
        else if let deckName = addToDeck {
            guard let fullInputPath else { fatalError("Must supply a path to a CSV or directory of CSVs with input cards.") }
            
            logger.info("Adding cards in \"\(fullInputPath)\" to deck \"\(deckName)\"")
            
            ensureDecksDirectory()
            
            let cards = processInputPaths(path: fullInputPath)
            let deckPath = path(forDeck: deckName)
            let cardsToWrite = combine(cards: cards, withCardsIn: deckPath)
            write(
                cards: cardsToWrite,
                path: deckPath,
                backup: backupFilesBeforeModifying,
                migrate: false
            )
            
            if retire {
                retireDeck(named: deckName)
            }
        }
        
        else if let deckName = moveToCollectionFromDeck {
            guard let fullInputPath else { fatalError("Must supply a path to a CSV or directory of CSVs with input cards.") }
            
            logger.info("Moving cards in \"\(fullInputPath)\" to collection from deck \"\(deckName)\"")
            
            let deckPath = path(forDeck: deckName)
            guard FileManager.default.fileExists(atPath: deckPath) else { fatalError("No file contains contents of deck named \"\(deckName)\".") }
            
            let cardsToMove = processInputPaths(path: fullInputPath)
            let leftoverDeckCards = subtract(cards: cardsToMove, fromCardsIn: deckPath)
            write(cards: leftoverDeckCards, path: deckPath, backup: backupFilesBeforeModifying, migrate: false)
            
            let collectionAfterAdding = combine(cards: cardsToMove, withCardsIn: collectionFile)
            write(cards: collectionAfterAdding, path: collectionFile, backup: backupFilesBeforeModifying, migrate: false)
        }
        
        else if addToCollection {
            guard let fullInputPath else { fatalError("Must supply a path to a CSV or directory of CSVs with input cards.") }
            
            let cards = processInputPaths(path: fullInputPath)
            logger.info("Adding cards in \"\(fullInputPath)\" to collection")
            
            let cardsToWrite = combine(cards: cards, withCardsIn: collectionFile)
            write(
                cards: cardsToWrite,
                path: collectionFile,
                backup: backupFilesBeforeModifying,
                migrate: false
            )
        }
        
        else if removeFromCollection {
            guard let fullInputPath else { fatalError("Must supply a path to a CSV or directory of CSVs with input cards.") }
            let cardsToRemove = processInputPaths(path: fullInputPath)
            
            logger.info("Removing cards in \"\(fullInputPath)\" from collection")
            
            let leftoverCards = subtract(cards: cardsToRemove, fromCardsIn: collectionFile)
            write(cards: leftoverCards, path: collectionFile, backup: backupFilesBeforeModifying, migrate: false)
        }
        
        else if let deckToRetire = retireDeck {
            retireDeck(named: deckToRetire)
        }
        
        else {
            throw Error.unexpectedOption
        }
    }
}

// MARK: Private
private extension MTG {
    mutating func retireDeck(named deckToRetire: String) {
        logger.info("Retiring deck \"\(deckToRetire)\"")
        let deckPath = path(forDeck: deckToRetire)
        guard FileManager.default.fileExists(atPath: deckPath) else { fatalError("No file contains contents of deck named \(deckToRetire).") }
        
        let cardsToMove = parseManagedCSV(at: deckPath)
        let retiredDeckPath = path(forDeck: deckToRetire, retired: true)
        ensureDecksDirectory(retired: true)
        do {
            try FileManager.default.moveItem(atPath: deckPath, toPath: retiredDeckPath)
        } catch {
            fatalError("Failed to move \(deckPath) to \(retiredDeckPath): \(error)")
        }
        
        let collectionAfterAdding = combine(cards: cardsToMove, withCardsIn: collectionFile)
        write(cards: collectionAfterAdding, path: collectionFile, backup: backupFilesBeforeModifying, migrate: false)
    }
    
    func parseManagedCSV(at file: String) -> [CardQuantity] {
        var preexistingParseProgress: ProgressBar?
        return mtg.parseManagedCSV(
            at: file,
            progressInit: {
                preexistingParseProgress = progressBar(count: $0, title: "Parsing preexisting entries:")
            },
            progress: {
                preexistingParseProgress?.next()
            }
        )
    }
    
    func subtract(cards: [CardQuantity], fromCardsIn file: String) -> [CardQuantity] {
        var collectionCards = parseManagedCSV(at: file)
        
        for card in cards {
            guard let index = collectionCards.firstIndex( where:{ collectionCard in
                equalCards(a: card.card, b: collectionCard.card)
            }) else {
                logger.trace("Could not find card (\"\(String(describing: card.card.name))\": \(card.card.setCode) \(card.card.cardNumber))")
                continue
            }
            
            var collectionCard = collectionCards[index]
            logger.trace("Moving \(String(describing: collectionCard.card.name)) (\(collectionCard.card.setCode) \(collectionCard.card.cardNumber))")
            if collectionCard.quantity == 1 {
                collectionCards.remove(at: index)
            } else {
                collectionCard.quantity -= 1
                collectionCards[index] = collectionCard
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
                preexistingParseProgress = progressBar(count: $0, title: "Parsing preexisting entries:")
            },
            preexistingCardParseProgress: {
                preexistingParseProgress?.next()
            }, countConsolidationProgressInit: {
                consolidationProgress = progressBar(count: $0, title: "Consolidating entries:")
            }, countConsolidationProgress: {
                consolidationProgress?.next()
            }
        )
    }
    
    mutating func ensureDecksDirectory(retired: Bool = false) {
        let directory = retired ? retiredDecksDirectory : decksDirectory
        if !FileManager.default.fileExists(atPath: directory) {
            do {
                try FileManager.default.createDirectory(atPath: directory, withIntermediateDirectories: false)
            } catch {
                fatalError("Couldn't create directory at \(directory)")
            }
        }
    }
    
    mutating func path(forDeck named: String, retired: Bool = false) -> String {
        if retired {
            return ((retiredDecksDirectory as NSString).appendingPathComponent(named) as NSString).appendingPathExtension("csv")!
        } else {
            return ((decksDirectory as NSString).appendingPathComponent(named) as NSString).appendingPathExtension("csv")!
        }
    }
}


