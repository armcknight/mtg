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

@main
struct MTG: ParsableCommand {
    static let configuration = CommandConfiguration(abstract: "Take a CSV file from a card scanner app like TCGPlayer and incorporate the cards it describes into a database of cards describing a base collection and any number of constructed decks. Cards in constructed decks are not duplicated in the base collection.")
    
    @Flag(name: .long, help: "Add the cards in the input CSV to the base collection.")
    var addToCollection: Bool = false
    
    @Option(name: .long, help: "Remove the cards in the input CSV from the base collection. You may want to do this if you've sold the cards.")
    var removeFromCollection: Bool = false
    
    @Option(name: .long, help: "Add new cards not already in the base collection directly to a deck.")
    var addDirectlyToDeck: String? = nil
    
    @Option(name: .long, help: "Move the cards from the base collection to a deck.")
    var moveToDeckFromCollection: String? = nil
    
    @Option(name: .long, help: "Remove the cards from the specified deck and place them in the base collection.")
    var moveToCollectionFromDeck: String? = nil
    
    @Option(name: .long, help: "Custom location of the managed CSV files.")
    var collectionPath: String = "."
    
    @Flag(name: .long, help: "Create backup files before modifying any managed CSV file.")
    var backupFilesBeforeModifying: Bool = false
    
    @Argument(help: "The input CSV file containing cards.")
    var inputCSVFile: String

    mutating func run() throws {
        if let deckName = processInfo.environment["--move-to-deck"] {
            
        }

        else if let deckName = processInfo.environment["--add-to-deck"] {
            writeCards(file: "\(deckName).csv")
        }

        else if let deckName = processInfo.environment["--move-to-collection-from"] {
            
        }

        else if processInfo.arguments.contains("--add-to-collection") {
            writeCards(file: baseCollectionFile)
        }

        else if processInfo.arguments.contains("--remove-from-collection") {
            
        }

        else {
            throw Error.unexpectedOption
        }
    }
    
    enum Error: Swift.Error {
        case unexpectedOption
    }
    
    func processInputCSV() -> [(card: Card, quantity: UInt)] {
        guard let inputCSVPath = processInfo.arguments.last else {
            fatalError("Must provide a path to a CSV file")
        }
        
        let fileAttributes: [FileAttributeKey: Any]
        do {
            fileAttributes = try fileManager.attributesOfItem(atPath: inputCSVPath)
        } catch {
            fatalError("Couldn't read attributes of input file: \(error.localizedDescription)")
        }
        guard let fileCreationDate = fileAttributes[FileAttributeKey.creationDate] as? Date else {
            fatalError("Couldn't read creation date of file")
        }
        
        let url = URL(fileURLWithPath: inputCSVPath)
        
        let csvFile: EnumeratedCSV
        do {
            csvFile = try EnumeratedCSV(url: url)
        } catch {
            fatalError("Failed to read CSV file: \(error.localizedDescription)")
        }
        
        var cards = [(card: Card, quantity: UInt)]()
        do {
            try csvFile.enumerateAsDict { keyValues in
                guard let quantity = keyValues["Quantity"]?.unsignedIntegerValue else { fatalError("failed to parse field") }
                
                guard let card = Card(tcgPlayerFetchDate: fileCreationDate, keyValues: keyValues) else {
                    fatalError("Failed to parse card from row")
                }
                cards.append((card: card, quantity: quantity))
            }
        } catch {
            fatalError("Failed enumerating CSV file: \(error.localizedDescription)")
        }
        return cards
    }

    func writeCards(file: String) {
        let cards = processInputCSV()
        var contentString = cards.map {
            $0.card.csvRow(quantity: $0.quantity)
        }.joined(separator: "\n")
        let path = (collectionPath as NSString).appendingPathComponent(file)
        if !fileManager.fileExists(atPath: path) {
            contentString = csvHeaderRow + "\n" + contentString
        } else {
            let existingContent: String
            do {
                existingContent = try String(contentsOfFile: path)
            } catch {
                fatalError("Failed to read existing collection: \(error.localizedDescription)")
            }
            contentString = existingContent + "\n" + contentString
        }
        if processInfo.arguments.contains("--backup-files-before-modifying") {
            if fileManager.fileExists(atPath: path) {
                do {
                    try fileManager.copyItem(atPath: path, toPath: "\(path).bak_\(dateFormatter.string(from: Date()))")
                } catch {
                    fatalError("Failed to create backup copy of managed CSV: \(error.localizedDescription)")
                }
            }
        }
        do {
            try contentString.write(toFile: path, atomically: true, encoding: .utf8)
        } catch {
            fatalError("Failed to write to file: \(error.localizedDescription)")
        }
    }
}


