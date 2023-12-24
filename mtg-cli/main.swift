//
//  main.swift
//  mtg-cli
//
//  Created by Andrew McKnight on 12/23/23.
//

import Foundation
import mtg
import SwiftCSV

guard let inputCSVPath = ProcessInfo.processInfo.arguments.last else {
    fatalError("Must provide a path to a CSV file")
}

let csvFile: EnumeratedCSV
do {
    csvFile = try EnumeratedCSV(url: URL(fileURLWithPath: inputCSVPath))
} catch {
    fatalError("Failed to read CSV file")
}

var cards = [(card: Card, quantity: UInt)]()
do {
    try csvFile.enumerateAsDict { keyValues in
        guard let quantity = keyValues["Quantity"]?.unsignedIntegerValue else { fatalError("failed to parse field") }
        
        guard let card = Card(keyValues: keyValues) else {
            fatalError("Failed to parse card from row")
        }
        cards.append((card: card, quantity: quantity))
    }
} catch {
    fatalError("Failed enumerating CSV file")
}

print("here")
