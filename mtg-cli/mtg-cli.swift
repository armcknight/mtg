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
    var addToDeck: String? = nil
    
    @Option(name: .long, help: "Move the cards from the base collection to a deck.")
    var moveToDeckFromCollection: String? = nil
    
    @Option(name: .long, help: "Remove the cards from the specified deck and place them in the base collection.")
    var moveToCollectionFromDeck: String? = nil
    
    @Option(name: .long, help: "Custom location of the managed CSV files.")
    var collectionPath: String = "."
    
    @Flag(name: .long, help: "Create backup files before modifying any managed CSV file.")
    var backupFilesBeforeModifying: Bool = false
    
    @Argument(help: "One or more paths to CSV files or directories containing CSV files that contain cards to process according to the specified options.")
    var inputPaths: [String]
}

extension MTG {
    mutating func run() throws {
        if let deckName = processInfo.environment["--move-to-deck"] {
            
        }
        
        else if let deckName = addToDeck {
            write(cards: processInputPaths(paths: inputPaths), path: managedPath(name: "\(decksDirectory)/\(deckName).csv"))
        }
        
        else if let deckName = processInfo.environment["--move-to-collection-from"] {
            
        }
        
        else if processInfo.arguments.contains("--add-to-collection") {
            write(cards: processInputPaths(paths: inputPaths), path: managedPath(name: baseCollectionFile))
        }
        
        else if processInfo.arguments.contains("--remove-from-collection") {
            
        }
        
        else {
            throw Error.unexpectedOption
        }
    }
    
    func managedPath(name: String) -> String {
        (collectionPath as NSString).appendingPathComponent(name)
    }
}


