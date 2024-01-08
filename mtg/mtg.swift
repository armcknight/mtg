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

public typealias InputCard = (card: Card, quantity: UInt)

public func processInputPaths(paths: [String]) -> [InputCard] {
    var cards = [InputCard]()
    paths.forEach { path in
        guard !path.contains(".DS_Store") else { return }
        let fileAttributes: [FileAttributeKey: Any]
        do {
            fileAttributes = try fileManager.attributesOfItem(atPath: path)
        } catch {
            fatalError("Couldn't read attributes of input file: \(error.localizedDescription)")
        }
        
        guard let fileType = fileAttributes[FileAttributeKey.type] as? String else {
            fatalError("Couldn't ascertain if path is file or directory")
        }
        
        let newCards: [InputCard]
        switch fileType {
        case FileAttributeType.typeDirectory.rawValue:
            let files: [String]
            do {
                try files = fileManager.contentsOfDirectory(atPath: path)
            } catch {
                fatalError("Couldn't get list of files in directory")
            }
            newCards = processInputPaths(paths: files.map { (path as NSString).appendingPathComponent($0) })
        case FileAttributeType.typeRegular.rawValue:
            newCards = processFileAtPath(path: path, fileAttributes: fileAttributes)
        default: fatalError("Unexpected path type; expected either file or directory")
        }
        cards.append(contentsOf: newCards)
    }
    return cards
}

public func processFileAtPath(path: String, fileAttributes: [FileAttributeKey: Any]) -> [(card: Card, quantity: UInt)] {
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
    
    var cards = [(card: Card, quantity: UInt)]()
    do {
        try csvContents.enumerateAsDict { keyValues in
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

public func write(cards: [InputCard], path: String, backup: Bool) {
    var contentString = cards.map {
        $0.card.csvRow(quantity: $0.quantity)
    }.joined(separator: "\n")
    if !fileManager.fileExists(atPath: path) {
        contentString = "#schema_version: \(schemaVersion)\n\(csvHeaderRow)\n" + contentString
    } else {
        var existingContent: String
        do {
            existingContent = try String(contentsOfFile: path)
        } catch {
            fatalError("Failed to read existing collection: \(error.localizedDescription)")
        }
        
        if !existingContent.split(separator: "\n").first!.starts(with: "#schema_version") {
            let metadata = "#schema_version: \(schemaVersion)\n"
            existingContent.insert(contentsOf: metadata, at: existingContent.startIndex)
        } else {
            // TODO: migrations
        }
        
        contentString = existingContent + "\n" + contentString
        
        if backup {
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
