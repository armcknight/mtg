//
//  Card.swift
//  mtg
//
//  Created by Andrew McKnight on 12/23/23.
//

import Foundation
import SwiftArmcknight

/** Fields I get from the TCGPlayer scan app but aren't really TCGPlayer specific data. */
public enum CardCSVField: String, CaseIterable {
    case quantity = "Quantity"
    case name = "Name"
    case simpleName = "Simple Name"
    case set = "Set"
    case setCode = "Set Code"
    case cardNumber = "Card Number"
    case language = "Language"
    case finish = "Finish"
    case rarity = "Rarity"
}

public enum CardExtraField: String, CaseIterable {
    case notes = "Notes"
    case proxy = "Proxy"
}

public let csvHeaders = CardCSVField.allCases.map(\.rawValue) + TCGPlayerInfo.CSVHeader.allCases.map(\.rawValue) + ScryfallInfo.CSVHeader.allCases.map(\.rawValue) + CardExtraField.allCases.map(\.rawValue)

public let csvHeaderRow = csvHeaders.joined(separator: ",")

extension String {
    @available(macOS 13.0, iOS 16.0, *)
    var faceSplit: [String] {
        split(separator: Card.faceSeparator).map { String($0) }
    }

    @available(macOS 13.0, iOS 16.0, *)
    var valueSplit: [String] {
        split(separator: Card.valueSeparator).map { String($0) }
    }
    
    var unquoted: String {
        guard contains("\"") else { return self }
        if self == "\"\"" { return "" }
        return String(self[index(startIndex, offsetBy: 1)..<index(startIndex, offsetBy: count - 1)])
    }
}

public extension Array where Element == String {
    var faceJoin: String {
        joined(separator: Card.faceSeparator)
    }
    
    var valueJoin: String {
        joined(separator: Card.valueSeparator)
    }
}

/// The data structure for a card in our own managed CSV files. This describes all the information about a card that we're interested in keeping in our CSV/spreadsheet.
public struct Card {
    static let faceSeparator = " // "
    static let valueSeparator = ", "
    
    enum Condition: String {
        case mint = "Mint"
        case nearMint = "Near Mint"
        case lightlyPlayed = "Lightly Played"
        case moderatelyPlayed = "Moderately Played"
        case heavilyPlayed = "Heavily Played"
        case damaged = "Damaged"
    }
    
    enum Rarity: String {
        case common = "Common"
        case uncommon = "Uncommon"
        case rare = "Rare"
        case mythic = "Mythic"
        /** Some examples of this are Timeshifted and Kaladesh Inventions. */
        case special = "Special"
        /** Only declared in the TCGPlayer API. */
        case land = "Land"
        /** Only declared in the TCGPlayer API. */
        case promo = "Promo"
        /** Only declared in the Scryfall API. So far, the only cards that have this rarity level are the power 9 from the vintage masters set. As of 1-8-24, they are not available on TCGPlayer. */
        case bonus = "Bonus"
    }
    
    public enum Finish: String {
        case normal = "Normal"
        case foil = "Foil"
    }
    
    public var name: String?
    public var simpleName: String?
    var set: String?
    public var cardNumber: String
    public var setCode: String
    var language: String?
    var notes: String?
    
    public var finish: Finish
    var rarity: Rarity?
    
    var tcgPlayerInfo: TCGPlayerInfo?
    public var scryfallInfo: ScryfallInfo?
    
    public var proxy: Bool
    
    /**
     * - parameter finishes May be either `*F*` for foil, or `*<name>*` where `<name>` is from `ScryfallPromoType` or `ScryfallFrameEffect`
     */
    public init(name: String?, setCode: String, cardNumber: String, foil: Bool, proxy: Bool) {
        self.name = name
        self.simpleName = name
        self.setCode = setCode
        self.cardNumber = cardNumber
        self.proxy = proxy
        
        if foil {
            self.finish = .foil
        } else {
            self.finish = .normal
        }
    }
    
    public init?(tcgPlayerFetchDate: Date, keyValues: [String: String]) {
        guard let name = keyValues["Name"] else { fatalError("failed to parse \("Name")") }
        self.name = name.rfc4180CompliantFieldWithDoubleQuotes
        
        guard let simpleName = keyValues["Simple Name"] else { fatalError("failed to parse \("Simple Name")") }
        self.simpleName = simpleName.rfc4180CompliantFieldWithDoubleQuotes
        
        guard let set = keyValues["Set"] else { fatalError("failed to parse \("Set")") }
        self.set = set.rfc4180CompliantFieldWithDoubleQuotes
        
        guard let cardNumber = keyValues["Card Number"] else { fatalError("failed to parse \("Card Number")") }
        self.cardNumber = cardNumber
        
        guard let setCode = keyValues["Set Code"] else { fatalError("failed to parse \("Set Code")") }
        self.setCode = setCode
        
        guard let language = keyValues["Language"] else { fatalError("failed to parse \("Language")") }
        self.language = language
        
        guard let rawValue = keyValues["Printing"] else { fatalError("No value for Printing") }
        guard let finish = Finish(rawValue: rawValue) else { fatalError("Failed to parse Printing from \(rawValue)") }
        self.finish = finish
        
        guard let rawValue = keyValues["Rarity"] else { fatalError("No value for Rarity") }
        guard let rarity = Rarity(rawValue: rawValue) else { fatalError("failed to parse Rarity from \(rawValue)") }
        self.rarity = rarity
        
        guard let productIDString = keyValues["Product ID"], let productID = Int(productIDString) else { fatalError("failed to parse \("Product ID")") }
        guard let sku = keyValues["SKU"] else { fatalError("failed to parse \("SKU")") }
        guard let string = keyValues["Price Each"]?.dropFirst() else { fatalError("No value for Price Each")}
        guard let priceEach = Decimal(string: String(string)) else { fatalError("failed to parse TCGPlayer Price from \(string)") }

        tcgPlayerInfo = TCGPlayerInfo(productID: productID, SKU: sku, priceEach: priceEach, fetchDate: tcgPlayerFetchDate)
        
        self.proxy = false // could never scan a proxy with TCGPlayer
    }
    
    @available(macOS 13.0, iOS 16.0, *)
    public init?(managedCSVKeyValues keyValues: [String: String]) {
        guard let name = keyValues[CardCSVField.name.rawValue] else { fatalError("failed to parse \(CardCSVField.name.rawValue)") }
        self.name = name
        
        guard let simpleName = keyValues[CardCSVField.simpleName.rawValue] else { fatalError("failed to parse \(CardCSVField.simpleName.rawValue)") }
        self.simpleName = simpleName
        
        guard let set = keyValues[CardCSVField.set.rawValue] else { fatalError("failed to parse \(CardCSVField.set.rawValue)") }
        self.set = set
        
        guard let cardNumber = keyValues[CardCSVField.cardNumber.rawValue] else { fatalError("failed to parse \(CardCSVField.cardNumber.rawValue)") }
        self.cardNumber = cardNumber
        
        guard let setCode = keyValues[CardCSVField.setCode.rawValue] else { fatalError("failed to parse \(CardCSVField.setCode.rawValue)") }
        self.setCode = setCode
        
        guard let language = keyValues[CardCSVField.language.rawValue] else { fatalError("failed to parse \(CardCSVField.language.rawValue)") }
        self.language = language
        
        guard let rawValue = keyValues[CardCSVField.finish.rawValue] else { fatalError("No value found for \(CardCSVField.finish.rawValue)") }
        guard let finish = Finish(rawValue: rawValue) else { fatalError("failed to parse \(CardCSVField.finish.rawValue) from \(rawValue)") }
        self.finish = finish
                
        guard let rawValue = keyValues[CardCSVField.rarity.rawValue] else { fatalError("No value found for \(CardCSVField.rarity.rawValue)") }
        guard let rarity = Rarity(rawValue: rawValue) else { fatalError("failed to parse \(CardCSVField.rarity.rawValue) from \(rawValue)") }
        self.rarity = rarity
        
        self.notes = keyValues[CardExtraField.notes.rawValue]
        
        self.tcgPlayerInfo = TCGPlayerInfo(managedCSVKeyValues: keyValues)
        self.scryfallInfo = ScryfallInfo(managedCSVKeyValues: keyValues)
        
        self.proxy = keyValues[CardExtraField.proxy.rawValue] == "PROXY"
    }
    
    public func csvRow(quantity: UInt) -> String {
        precondition(name != nil, "Must have a name to write")
        precondition(name != nil, "Must have a simple name to write")
        var fields = [
            "\(quantity)",
            "\"\(name ?? "")\"",
            "\"\(simpleName ?? "")\"",
            "\"\(set ?? "")\"",
            "\(setCode.uppercased())",
            "\(cardNumber)",
            "\(language ?? "")",
            "\(finish.rawValue)",
            "\(rarity?.rawValue ?? "")",
        ]
        
        if let tcgPlayerInfo {
            fields.append(tcgPlayerInfo.csvRow)
        } else {
            fields.append(String(repeating: ",", count: TCGPlayerInfo.CSVHeader.allCases.count - 1))
        }
        
        if let scryfallInfo {
            fields.append(scryfallInfo.csvRow)
        } else {
            fields.append(String(repeating: ",", count: ScryfallInfo.CSVHeader.allCases.count - 1))
        }
        
        fields.append(notes ?? "")
        fields.append(proxy ? "PROXY" : "")
        
        return fields.joined(separator: ",")
    }
    
    public func moxfieldRow(quantity: UInt) -> String {
        precondition(name != nil, "Must have a name to write")
        var result = "\(quantity) \(name!) (\(setCode.uppercased())) \(cardNumber)"
        if finish == .foil {
            result += " *F*"
        }
        if proxy {
            result += " PROXY"
        }
        return result
    }
}

extension Card {
    func compareCSVOrder(other: Card) -> Bool {
        guard let name = name, let nameOther = other.name else {
            fatalError("Should have card names by now")
        }
        switch name.compare(nameOther) {
        case .orderedAscending: return true
        case .orderedDescending: return false
        case .orderedSame:
            switch setCode.compare(other.setCode) {
            case .orderedAscending: return true
            case .orderedDescending: return false
            case .orderedSame:
                switch cardNumber.compare(other.cardNumber) {
                case .orderedAscending: return true
                case .orderedDescending: return false
                case .orderedSame:
                    if proxy != other.proxy { return false }
                    
                    // foil version of otherwise same cards come after their nonfoil counterparts
                    precondition(finish != other.finish, "Should not have equal cards of same printing to compare, they should've been combined in the consolidation step")
                    if finish == .foil && other.finish == .normal { return false }
                    
                    else if finish == .normal && other.finish == .foil { return true }
                    else { fatalError("Should not be reachable, if everything else is the same at this point, the two cards must be different printings. Something else might've gone wrong in consolidation.") }
                }
            }
        }
    }
}
