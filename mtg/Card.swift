//
//  Card.swift
//  mtg
//
//  Created by Andrew McKnight on 12/23/23.
//

import Foundation
import SwiftArmcknight

public struct Card {
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
        case promo = "Promo"
    }
    
    enum Printing: String {
        case normal = "Normal"
        case foil = "Foil"
    }
    
    struct TCGPlayerInfo {
        var productID: String
        var SKU: String
        var priceEach: Decimal
    }
    
    var name: String
    var simpleName: String
    var set: String
    var cardNumber: UInt
    var setCode: String
    var language: String
    
    var printing: Printing
    var condition: Condition
    var rarity: Rarity
    
    var tcgPlayerInfo: TCGPlayerInfo
    
    public init?(keyValues: [String: String]) {
        guard let name = keyValues["Name"] else { fatalError("failed to parse field") }
        self.name = name
        
        guard let simpleName = keyValues["Simple Name"] else { fatalError("failed to parse field") }
        self.simpleName = simpleName
        
        guard let set = keyValues["Set"] else { fatalError("failed to parse field") }
        self.set = set
        
        guard let cardNumber = keyValues["Card Number"]?.unsignedIntegerValue else { fatalError("failed to parse field") }
        self.cardNumber = cardNumber
        
        guard let setCode = keyValues["Set Code"] else { fatalError("failed to parse field") }
        self.setCode = setCode
        
        guard let language = keyValues["Language"] else { fatalError("failed to parse field") }
        self.language = language
        
        guard let rawValue = keyValues["Printing"], let printing = Printing(rawValue: rawValue) else { fatalError("failed to parse field") }
        self.printing = printing
        
        guard let rawValue = keyValues["Condition"], let condition = Condition(rawValue: rawValue) else { fatalError("failed to parse field") }
        self.condition = condition
        
        guard let rawValue = keyValues["Rarity"], let rarity = Rarity(rawValue: rawValue) else { fatalError("failed to parse field") }
        self.rarity = rarity
        
        guard let productID = keyValues["Product ID"] else { fatalError("failed to parse field") }
        guard let sku = keyValues["SKU"] else { fatalError("failed to parse field") }
        guard let string = keyValues["Price Each"]?.dropFirst(), let priceEach = Decimal(string: String(string)) else { fatalError("failed to parse field") }
        tcgPlayerInfo = TCGPlayerInfo(productID: productID, SKU: sku, priceEach: priceEach)
    }
}
