//
//  mtg.swift
//  mtg
//
//  Created by Andrew McKnight on 12/23/23.
//

import Foundation
import SwiftCSV

let schemaVersion = 1

public var dateFormatter: ISO8601DateFormatter = {
    let df = ISO8601DateFormatter()
    df.timeZone = Calendar.current.timeZone
    return df
}()
public let processInfo = ProcessInfo.processInfo
public let fileManager = FileManager.default

public enum Error: Swift.Error {
    case unexpectedOption
}

public typealias CardQuantity = (card: Card, quantity: UInt)

public func processInputPaths(path: String) -> [CardQuantity] {
    let fileAttributes: [FileAttributeKey: Any]
    do {
        fileAttributes = try fileManager.attributesOfItem(atPath: path)
    } catch {
        fatalError("Couldn't read attributes of input file: \(error.localizedDescription)")
    }
    
    guard let fileType = fileAttributes[FileAttributeKey.type] as? String else {
        fatalError("Couldn't ascertain if path is file or directory")
    }
    
    var newCards = [CardQuantity]()
    switch fileType {
    case FileAttributeType.typeDirectory.rawValue:
        let files: [String]
        do {
            files = try fileManager.contentsOfDirectory(atPath: path)
        } catch {
            fatalError("Couldn't get list of files in directory")
        }
        files.forEach { file in
            guard !file.contains(".DS_Store") else { return }
            guard !file.contains(".bak") else { return }
            newCards.append(contentsOf: processInputPaths(path: (path as NSString).appendingPathComponent(file)))
        }
    case FileAttributeType.typeRegular.rawValue:
        newCards = parseTCGPlayerCSVAtPath(path: path, fileAttributes: fileAttributes)
    default: fatalError("Unexpected path type; expected either file or directory")
    }
    return newCards
}

public func parseTCGPlayerCSVAtPath(path: String, fileAttributes: [FileAttributeKey: Any]) -> [CardQuantity] {
    guard let fileCreationDate = fileAttributes[FileAttributeKey.creationDate] as? Date else {
        fatalError("Couldn't read creation date of file")
    }

    let url = URL(fileURLWithPath: path)
    let csvContents: EnumeratedCSV
    do {
        csvContents = try EnumeratedCSV(url: url)
    } catch {
        fatalError("Failed to read CSV file: \(error.localizedDescription)")
    }
    
    var cards = [CardQuantity]()
    do {
        try csvContents.enumerateAsDict { keyValues in
            guard let quantity = keyValues["Quantity"]?.unsignedIntegerValue else { fatalError("failed to parse field") }
            
            guard var card = Card(tcgPlayerFetchDate: fileCreationDate, keyValues: keyValues) else {
                fatalError("Failed to parse card from row")
            }
            card.fetchScryfallInfo()
            cards.append((card: card, quantity: quantity))
        }
    } catch {
        fatalError("Failed enumerating CSV file: \(error.localizedDescription)")
    }
    return cards
}

func equalCards(a: Card, b: Card) -> Bool {
    if let aScryfallInfo = a.scryfallInfo, let bScryfallInfo = b.scryfallInfo {
        return aScryfallInfo.scryfallID == bScryfallInfo.scryfallID && a.finish == b.finish && aScryfallInfo.frameEffects == bScryfallInfo.frameEffects && aScryfallInfo.fullArt == bScryfallInfo.fullArt && aScryfallInfo.promoTypes == bScryfallInfo.promoTypes
    }
    
    return a.setCode == b.setCode && a.cardNumber == b.cardNumber && a.finish == b.finish
}

public func consolidateCards(cards: [CardQuantity], progress: (() -> Void)?) -> [CardQuantity] {
    var unconsolidatedCards = cards
    let consolidatedCards = cards.reduce([CardQuantity]()) { partialResult, nextCardEntry in
        progress?()
        
        let partitioned = unconsolidatedCards.partition { cardMatch in
            equalCards(a: nextCardEntry.card, b: cardMatch.card)
        }
        
        let duplicates = unconsolidatedCards.dropFirst(partitioned)
        guard duplicates.count > 0 else {
            return partialResult
        }
        
        let remaining = unconsolidatedCards.dropLast(unconsolidatedCards.count - partitioned)
        let quantity = duplicates.reduce(0) { partialResult, nextQuantity in
            partialResult + nextQuantity.quantity
        }
        
        unconsolidatedCards = Array(remaining)
        
        return partialResult + [(card: nextCardEntry.card, quantity: quantity)]
    }
    return consolidatedCards
}

public func write(cards: [CardQuantity], path: String, backup: Bool, migrate: Bool) {
    var contentString = cards.map {
        $0.card.csvRow(quantity: $0.quantity)
    }.joined(separator: "\n")
    if !fileManager.fileExists(atPath: path) {
        contentString = "#schema_version: \(schemaVersion)\n\(csvHeaderRow)\n" + contentString
    } else if !migrate {
        var existingContent: String
        do {
            existingContent = try String(contentsOfFile: path)
        } catch {
            fatalError("Failed to read existing collection: \(error.localizedDescription)")
        }
        
        contentString = existingContent + "\n" + contentString
    }
    
    if !contentString.contains("#schema_version") {
        let metadata = "#schema_version: \(schemaVersion)\n"
        contentString.insert(contentsOf: metadata, at: contentString.startIndex)
    } else {
        // TODO: migrations
    }
    
    if backup {
        do {
            try fileManager.copyItem(atPath: path, toPath: "\(path).bak_\(dateFormatter.string(from: Date()))")
        } catch {
            fatalError("Failed to create backup copy of managed CSV: \(error.localizedDescription)")
        }
    }
    
    do {
        try contentString.write(toFile: path, atomically: true, encoding: .utf8)
    } catch {
        fatalError("Failed to write to file: \(error.localizedDescription)")
    }
}
