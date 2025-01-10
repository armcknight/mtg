//
//  mtg.swift
//  mtg
//
//  Created by Andrew McKnight on 12/23/23.
//

import Foundation
import scryfall
import SwiftCSV

import Logging
public var logger = Logger(label: "mtg")

let schemaVersion = 1

public var dateFormatter: ISO8601DateFormatter = {
    let df = ISO8601DateFormatter()
    df.timeZone = Calendar.current.timeZone
    df.formatOptions =  [.withInternetDateTime, .withFractionalSeconds]
    return df
}()
public var humanReadableDateFormatter: DateFormatter = {
    let df = DateFormatter()
    df.timeStyle = .long
    df.dateStyle = .long
    return df
}()
public let processInfo = ProcessInfo.processInfo
public let fileManager = FileManager.default

public enum Error: Swift.Error {
    case unexpectedOption
}

public typealias CardQuantity = (card: Card, quantity: UInt)

public func processInputPaths(path: String, fetchScryfallData: Bool = true) -> [CardQuantity] {
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
        do {
            newCards = try parseTCGPlayerCSVAtPath(path: path, fileAttributes: fileAttributes, fetchScryfallData: fetchScryfallData)
        } catch {
            do {
                newCards = try parseMTGOFileAtPath(path: path, fetchScryfallData: fetchScryfallData)
            } catch {
                do {
                    newCards = try parseSetCodeAndNumberList(path: path, fetchScryfallData: fetchScryfallData)
                    
                    let moxfieldFormat = newCards.map({$0.card.moxfieldRow(quantity: $0.quantity)}).joined(separator: "\n")
                    do {
                        try moxfieldFormat.write(toFile: path, atomically: true, encoding: .utf8)
                    } catch {
                        fatalError("Failed to rewrite input file with moxfield format: \(error)")
                    }
                } catch {
                    fatalError("Could not parse file at \(path) with any supported format")
                }
            }
        }
    default: fatalError("Unexpected path type; expected either file or directory")
    }
    return newCards
}

public func parseManagedCSV(at path: String, progressInit: ((Int) -> Void)?, progress: (() -> Void)?) -> [CardQuantity] {
    var csvFileStringContents: String
    do {
        try csvFileStringContents = String(contentsOf: URL(filePath: path))
    } catch {
        fatalError("Failed to get contents of managed CSV file: \(error)")
    }
    
    let firstHeadingRange = csvFileStringContents.firstRange(of: csvHeaders.first!)!
    let metadataRange = csvFileStringContents.startIndex..<firstHeadingRange.lowerBound
    let metadata = csvFileStringContents[metadataRange]
    // TODO: migrate if schema is out of date?
    
    csvFileStringContents.removeSubrange(metadataRange)
    let csvContents: EnumeratedCSV
    do {
        csvContents = try EnumeratedCSV(string: csvFileStringContents)
    } catch {
        fatalError("Failed to parse managed CSV at \(path): \(error)")
    }
    progressInit?(csvContents.rows.count)
    var cards = [CardQuantity]()
    do {
        try csvContents.enumerateAsDict { keyValues in
            progress?()
            
            guard let quantity = keyValues["Quantity"]?.unsignedIntegerValue else { fatalError("failed to parse field") }
            
            guard let card = Card(managedCSVKeyValues: keyValues) else {
                fatalError("Failed to parse card from row")
            }
            
            cards.append((card: card, quantity: quantity))
        }
    } catch {
        fatalError("Failed enumerating CSV file: \(error.localizedDescription)")
    }
    return cards
}

public enum TCGPlayerCSVParseError: Swift.Error {
    case noQuantity
}

public func parseTCGPlayerCSVAtPath(path: String, fileAttributes: [FileAttributeKey: Any], fetchScryfallData: Bool) throws -> [CardQuantity] {
    guard let fileCreationDate = fileAttributes[FileAttributeKey.creationDate] as? Date else {
        fatalError("Couldn't read creation date of file")
    }

    let url = URL(fileURLWithPath: path)
    let csvContents: EnumeratedCSV
    do {
        csvContents = try EnumeratedCSV(url: url)
    } catch {
        logger.error("Cannot parse file at \(path) as a CSV file: \(error.localizedDescription)")
        throw error
    }
    
    var cards = [CardQuantity]()
    var error: TCGPlayerCSVParseError?
    do {
        try csvContents.enumerateAsDict { keyValues in
            guard let quantity = keyValues["Quantity"]?.unsignedIntegerValue else {
                error = .noQuantity
                return
            }
            
            guard var card = Card(tcgPlayerFetchDate: fileCreationDate, keyValues: keyValues) else {
                fatalError("Failed to parse card from row")
            }
            
            if fetchScryfallData {
                card.fetchScryfallInfo()
            }
            
            cards.append((card: card, quantity: quantity))
        }
    } catch {
        fatalError("Failed enumerating CSV file: \(error.localizedDescription)")
    }
    
    if let error {
        throw error
    }
    
    return cards
}

enum MTGOParseError: Swift.Error {
    case notEnoughFields
    case noQuantityField
}

    /**
     * if the file is not a CSV, try parsing it as a mtga/mtgo/moxfield format eg
     *
     *     1 Alela, Cunning Conqueror (WOC) 3 *F* PROXY
     *     1 Arcane Denial (WOC) 84
     *
     * modifiers:
     * `*F*` for foil, `PROXY` for proxies
     */
public func parseMTGOFileAtPath(path: String, fetchScryfallData: Bool) throws -> [CardQuantity] {
    var cards = [CardQuantity]()
    let content = try String(contentsOfFile: path)
    try content.lines.forEach {
        let split1 = $0.split(separator: "(")
        guard split1.count > 1 else {
            throw MTGOParseError.notEnoughFields
        }
        let split2 = split1[1].split(separator: ")")
        let split3 = split2[1].split(separator: " ")
        
        let quantityAndName = split1[0]
        let startIndex = quantityAndName.unicodeScalars.startIndex
        guard let quantityIdx = quantityAndName.unicodeScalars.firstIndex(where: { CharacterSet.whitespaces.contains($0) }) else {
            throw MTGOParseError.noQuantityField
        }
        let quantity = String(quantityAndName.unicodeScalars[startIndex..<quantityIdx]).unsignedIntegerValue
        let name = String(quantityAndName.unicodeScalars[quantityIdx...]).trimmingCharacters(in: .whitespaces)
        let setCode = String(split2[0])
        let cardNumber = String(split3[0]).trimmingCharacters(in: .whitespaces)
        let otherCardInfo = split3[1...]
        
        var card = Card(name: name, setCode: setCode, cardNumber: cardNumber, foil: otherCardInfo.contains("*F*"), proxy: otherCardInfo.contains("PROXY"))
                
        if fetchScryfallData {
            card.fetchScryfallInfo()
        }
        
        cards.append((card, quantity))
    }
    return cards
}

enum SetCodeAndNumberListError: Swift.Error {
    case notEnoughFields
    case noScryfallRarityFound
    case noScryfallNameFound
    case noScryfallSetCodeFound
}

func parseSetCodeAndNumberList(path: String, fetchScryfallData: Bool) throws -> [CardQuantity] {
    var cards = [CardQuantity]()
    let content = try String(contentsOfFile: path)
    try content.lines.forEach { line in
        let split = line.split(separator: " ")
        guard split.count >= 3 else {
            throw SetCodeAndNumberListError.notEnoughFields
        }
        
        let quantity = split[0]
        let setCode = split[1]
        let number = split[2]
        
        var foil: Bool = false
        var proxy: Bool = false
        if split.count > 3 {
            foil = split[3] == "*F*"
            proxy = split.last == "PROXY"
        }
        
        var card = Card(name: nil, setCode: String(setCode), cardNumber: String(number), foil: foil, proxy: proxy)
        
        if fetchScryfallData {
            card.fetchScryfallInfo()
        }
        
        if card.name == nil {
            // the card was entered by only set code and number; fill in other basic info from scryfall info; rarity is already set in fetchScryfallInfo which calls fixRarity
            card.name = card.scryfallInfo!.name
            card.simpleName = card.scryfallInfo!.printedName
            card.set = card.scryfallInfo!.setName!
            if let tcgPlayerID = card.scryfallInfo!.tcgPlayerID {
                card.tcgPlayerInfo = TCGPlayerInfo(productID: tcgPlayerID)
            }
        }
        
        cards.append((card, String(quantity).unsignedIntegerValue))
    }
    return cards
}

public func equalCards(a: Card, b: Card) -> Bool {
    guard a.finish == b.finish && a.proxy == b.proxy else { return false }
    
    if let aScryfallInfo = a.scryfallInfo, let bScryfallInfo = b.scryfallInfo {
        return aScryfallInfo.scryfallID == bScryfallInfo.scryfallID
    }
    
    return a.setCode == b.setCode && a.cardNumber == b.cardNumber
}

public func consolidateCardQuantities(cards: [CardQuantity], progress: (() -> Void)?) -> [CardQuantity] {
    var unconsolidatedCards = cards
    let consolidatedCards = cards.reduce([CardQuantity]()) { partialResult, nextCardEntry in
        progress?()
        
        // partition is mutating
        let partitioned = unconsolidatedCards.partition { cardMatch in
            equalCards(a: nextCardEntry.card, b: cardMatch.card)
        }
        
        // dropFirst is not mutating, should really be called droppingFirst ¯\_(ツ)_/¯ same with dropLast below
        let duplicates = unconsolidatedCards.dropFirst(partitioned)
        if duplicates.count == 0 {
            logger.debug("No duplicates of \(String(describing: nextCardEntry.card.name)) (\(nextCardEntry.card.setCode) \(nextCardEntry.card.cardNumber))")
            return partialResult
        }
        
        logger.debug("Combining multiple quantities of \(String(describing: nextCardEntry.card.name)) (\(nextCardEntry.card.setCode) \(nextCardEntry.card.cardNumber)): \(duplicates.map({$0.quantity}))")
        let remaining = unconsolidatedCards.dropLast(unconsolidatedCards.count - partitioned)
        let quantity = duplicates.map({$0.quantity}).reduce(0, +)
        
        unconsolidatedCards = Array(remaining)
        
        return partialResult + [(card: nextCardEntry.card, quantity: quantity)]
    }
    return consolidatedCards
}

public func combinedWithPreviousCards(cards: [CardQuantity], path: String, preexistingCardParseProgressInit: ((Int) -> Void)?, preexistingCardParseProgress: (() -> Void)?, countConsolidationProgressInit: ((Int) -> Void)?, countConsolidationProgress: (() -> Void)?) -> [CardQuantity] {
    var cardsToWrite = [CardQuantity]()
    
    if fileManager.fileExists(atPath: path) {
        cardsToWrite.append(contentsOf: parseManagedCSV(at: path, progressInit: preexistingCardParseProgressInit, progress: preexistingCardParseProgress))
    }
    cardsToWrite.append(contentsOf: cards)
    
    countConsolidationProgressInit?(cardsToWrite.count)
    return consolidateCardQuantities(cards: cardsToWrite, progress: countConsolidationProgress)
}

public func write(cards: [CardQuantity], path: String, backup: Bool, migrate: Bool) {
    let cardRows = cards.sorted(by: { a, b in
        return a.card.compareCSVOrder(other: b.card)
    }).map({
        $0.card.csvRow(quantity: $0.quantity)
    })
    
    var contentString = ([csvHeaderRow] + cardRows).joined(separator: "\n")
    
    if !fileManager.fileExists(atPath: path) {
        contentString = "#schema_version: \(schemaVersion)\n" + contentString
    } else if migrate {
        if !contentString.contains("#schema_version") {
            let metadata = "#schema_version: \(schemaVersion)\n"
            contentString.insert(contentsOf: metadata, at: contentString.startIndex)
        } else {
            // TODO: migrations
        }
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
        fatalError("Failed to write to path \(path): \(error.localizedDescription)")
    }
}
