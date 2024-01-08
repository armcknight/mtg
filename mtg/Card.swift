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
    case printing = "Printing"
    case rarity = "Rarity"
    case condition = "Condition"
}

/** Fields I get from the TCGPlayer scan app that are TCGPlayer specific data. */
public enum TCGPlayerField: String, CaseIterable {
    case productID = "TCGPlayer Product ID"
    case sku = "TCGPlayer SKU"
    case priceEach = "TCGPlayer Price Each"
    case fetchDate = "TCGPlayer Fetch Date"
}

/** Fields I get from Scryfall API calls. */
public enum ScryfallField: String, CaseIterable {
    case booster = "Booster"
//    case finishes = "Finishes"
    case frameEffects = "Frame Effects"
    case fullArt = "Full Art?"
    case promoTypes = "Promo Types"
    case setType = "Set Type"
    case colorIndicator = "Color Indicator"
    case manaCost = "Mana Cost"
    case typeLine = "Type Line"
    case oracleText = "Oracle Text"
    case colors = "Colors"
    case oracleID = "Oracle ID"
    case layout = "Layout"
    case arenaID = "Arena ID"
    case mtgoID = "MTGO ID"
    case multiverseIDs = "Multiverse IDs"
    case cardmarketID = "cardmarket ID"
    case scryfallID = "Scryfall ID"
//    case relatedCards = "Related"
    case defense = "Defense"
    case loyalty = "Loyalty"
    case power = "Power"
    case toughness = "Toughness"
    case cmc = "CMC"
    case colorIdentity = "Color Identity"
    case edhrecRank = "EDHREC Rank"
    case keywords = "Keywords"
    case pennyRank = "Penny Rank"
    case producedMana = "Produced Mana"
    case reprint = "Reprint?"
    case reserved = "Reserved?"
    case standard = "Standard Legal?"
    case future = "Future Legal?"
    case historic = "Historic Legal?"
    case timeless = "Timeless Legal?"
    case gladiator = "Gladiator Legal?"
    case pioneer = "Pioneer Legal?"
    case explorer = "Explorer Legal?"
    case modern = "Modern Legal?"
    case legacy = "Legacy Legal?"
    case pauper = "Pauper Legal?"
    case vintage = "Vintage Legal?"
    case penny = "Penny Legal?"
    case commander = "Commander Legal?"
    case oathbreaker = "Oathbreaker Legal?"
    case brawl = "Brawl Legal?"
    case historicbrawl = "Historic Brawl Legal?"
    case alchemy = "Alchemy Legal?"
    case paupercommander = "Pauper Commander Legal?"
    case duel = "Duel Legal?"
    case oldschool = "Old School Legal?"
    case premodern = "Premodern Legal?"
    case predh = "PreDH Legal?"
    case fetchDate = "Scryfall Fetch Date"
}

public let csvHeaderRow = (
    CardCSVField.allCases.map(\.rawValue)
    + TCGPlayerField.allCases.map(\.rawValue)
    + ScryfallField.allCases.map(\.rawValue)
).joined(separator: ",")

/// The data structure for a card in our own managed CSV files. This describes all the information about a card that we're interested in keeping in our CSV/spreadsheet.
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
        /** Some examples of this are Timeshifted and Kaladesh Inventions. */
        case special = "Special"
        /** Only declared in the TCGPlayer API. */
        case land = "Land"
        /** Only declared in the TCGPlayer API. */
        case promo = "Promo"
        /** Only declared in the Scryfall API. So far, the only cards that have this rarity level are the power 9 from the vintage masters set. As of 1-8-24, they are not available on TCGPlayer. */
        case bonus = "Bonus"
    }
    
    enum Finish: String {
        case normal = "Normal"
        case foil = "Foil"
        /** Only declared in the Scryfall API. */
        case etched = "Etched"
        
        init(scryfallFinish: ScryfallFinish) {
            switch scryfallFinish {
            case .etched: self = .etched
            case .foil: self = .foil
            case .nonfoil: self = .normal
            }
        }
    }
    
    struct TCGPlayerInfo {
        var productID: String
        var SKU: String
        var priceEach: Decimal
        var fetchDate: Date
        
        var csvRow: String {
            [
                "\(productID)",
                "\(SKU)",
                "\(priceEach)",
                "\(dateFormatter.string(from: fetchDate))",
            ].joined(separator: ",")
        }
        
        init(productID: String, SKU: String, priceEach: Decimal, fetchDate: Date) {
            self.productID = productID
            self.SKU = SKU
            self.priceEach = priceEach
            self.fetchDate = fetchDate
        }
        
        init?(managedCSVKeyValues keyValues: [String: String]) {
            guard let productID = keyValues[TCGPlayerField.productID.rawValue] else { fatalError("failed to parse field") }
            guard let sku = keyValues[TCGPlayerField.sku.rawValue] else { fatalError("failed to parse field") }
            guard let string = keyValues[TCGPlayerField.priceEach.rawValue], let priceEach = Decimal(string: String(string)) else { fatalError("failed to parse field") }
            guard let fetchDateString = keyValues[TCGPlayerField.fetchDate.rawValue], let fetchDate = dateFormatter.date(from: fetchDateString) else { fatalError("failed to parse field")}
            self = TCGPlayerInfo(productID: productID, SKU: sku, priceEach: priceEach, fetchDate: fetchDate)
        }
    }
    
    public struct ScryfallInfo {
        var booster: Bool
        var frameEffects: [[ScryfallFrameEffect]]?
        var fullArt: [Bool]
        var promoTypes: [[ScryfallPromoType]]?
        var setType: [ScryfallSetType]
        var colorIndicator: [[ScryfallColor]]?
        var manaCost: [String]?
        var typeLine: [String]
        var oracleText: [String]?
        var colors: [[ScryfallColor]]?
        var oracleID: [UUID]
        var layout: ScryfallLayout
        var arenaID: Int?
        var mtgoID: Int?
        var multiverseIDs: [Int]?
        var cardmarketID: Int?
        var scryfallID: UUID
        var relatedCards: [ScryfallRelatedCard]?
        var defense: [String]?
        var loyalty: [String]?
        var power: [String]?
        var toughness: [String]?
        var cmc: [Decimal]
        var colorIdentity: [[ScryfallColor]]
        var edhrecRank: Int?
        var keywords: [[String]]
        var pennyRank: Int?
        var producedMana: [[ScryfallManaType]]?
        var reserved: [Bool]
        var fetchDate: Date
        var reprint: [Bool]
        var legalities: [ScryfallFormat: ScryfallLegality]
        
        public init(scryfallCard: ScryfallCard, fetchDate: Date) {
            self.booster = scryfallCard.booster ?? scryfallCard.card_faces!.first!.booster!
            if let frameEffects = scryfallCard.frame_effects {
                self.frameEffects = [frameEffects]
            } else {
                self.frameEffects = scryfallCard.card_faces?.compactMap(\.frame_effects)
            }
            if let fullArt = scryfallCard.full_art {
                self.fullArt = [fullArt]
            } else {
                self.fullArt = scryfallCard.card_faces!.compactMap(\.full_art)
            }
            if let promoTypes = scryfallCard.promo_types {
                self.promoTypes = [promoTypes]
            } else {
                self.promoTypes = scryfallCard.card_faces?.compactMap(\.promo_types)
            }
            if let setType = scryfallCard.set_type {
                self.setType = [setType]
            } else {
                self.setType = scryfallCard.card_faces!.compactMap(\.set_type)
            }
            if let colorIndicator = scryfallCard.card_faces?.compactMap(\.color_indicator) {
                self.colorIndicator = colorIndicator
            } else {
                self.colorIndicator = scryfallCard.color_indicator == nil ? nil : [scryfallCard.color_indicator!]
            }
            if let manaCost = scryfallCard.card_faces?.compactMap(\.mana_cost) {
                self.manaCost = manaCost
            } else {
                self.manaCost = scryfallCard.mana_cost == nil ? nil : [scryfallCard.mana_cost!]
            }
            if let typeLine = scryfallCard.card_faces?.map(\.type_line) {
                self.typeLine = typeLine
            } else {
                self.typeLine = [scryfallCard.type_line!]
            }
            if let oracleText = scryfallCard.card_faces?.compactMap(\.oracle_text) {
                self.oracleText = oracleText
            } else {
                self.oracleText = scryfallCard.oracle_text == nil ? nil : [scryfallCard.oracle_text!]
            }
            if let colors = scryfallCard.card_faces?.compactMap(\.colors) {
                self.colors = colors
            } else {
                self.colors = scryfallCard.colors == nil ? nil : [scryfallCard.colors!]
            }
            if let oracleID = scryfallCard.oracle_id {
                self.oracleID = [oracleID]
            } else {
                self.oracleID = scryfallCard.card_faces!.compactMap(\.oracle_id)
            }
            self.layout = scryfallCard.layout
            self.arenaID = scryfallCard.arena_id
            self.mtgoID = scryfallCard.mtgo_id
            self.multiverseIDs = scryfallCard.multiverse_ids
            self.cardmarketID = scryfallCard.cardmarket_id
            self.scryfallID = scryfallCard.id
            self.relatedCards = scryfallCard.all_parts
            if let defense = scryfallCard.defense {
                self.defense = [defense]
            } else {
                self.defense = scryfallCard.card_faces?.compactMap(\.defense)
            }
            if let loyalty = scryfallCard.loyalty {
                self.loyalty = [loyalty]
            } else {
                self.loyalty = scryfallCard.card_faces?.compactMap(\.loyalty)
            }
            if let power = scryfallCard.power {
                self.power = [power]
            } else {
                self.power = scryfallCard.card_faces?.compactMap(\.power)
            }
            if let toughness = scryfallCard.toughness {
                self.toughness = [toughness]
            } else {
                self.toughness = scryfallCard.card_faces?.compactMap(\.toughness)
            }
            if let cmc = scryfallCard.cmc {
                self.cmc = [cmc]
            } else {
                self.cmc = scryfallCard.card_faces!.compactMap(\.cmc)
            }
            if let colorIdentity = scryfallCard.card_faces?.compactMap(\.color_identity) {
                self.colorIdentity = colorIdentity
            } else {
                self.colorIdentity = [scryfallCard.color_identity]
            }
            self.edhrecRank = scryfallCard.edhrec_rank
            if let keywords = scryfallCard.card_faces?.compactMap(\.keywords) {
                self.keywords = keywords
            } else {
                self.keywords = [scryfallCard.keywords]
            }
            self.pennyRank = scryfallCard.penny_rank
            if let producedMana = scryfallCard.produced_mana {
                self.producedMana = [producedMana]
            } else {
                self.producedMana = scryfallCard.card_faces?.compactMap(\.produced_mana)
            }
            if let reserved = scryfallCard.card_faces?.compactMap(\.reserved) {
                self.reserved = reserved
            } else {
                self.reserved = [scryfallCard.reserved]
            }
            self.fetchDate = fetchDate
            if let reprint = scryfallCard.reprint {
                self.reprint = [reprint]
            } else {
                self.reprint = scryfallCard.card_faces!.compactMap(\.reprint)
            }
            self.legalities = scryfallCard.legalities
        }
        
        public var csvRow: String {
            [
                "\(booster)",
                "\(frameEffects?.map({$0.map(\.rawValue).joined(separator: ", ")}).joined(separator: " // ").rfc4180CompliantFieldWithDoubleQuotes ?? "")",
                "\(fullArt.map(\.description).joined(separator: " // "))",
                "\(promoTypes?.map({$0.map(\.rawValue).joined(separator: ", ")}).joined(separator: " // ").rfc4180CompliantFieldWithDoubleQuotes ?? "")",
                "\(setType.map(\.rawValue).joined(separator: " // "))",
                "\(colorIndicator?.map({$0.map(\.rawValue).joined()}).joined(separator: " // ") ?? "")",
                "\(manaCost?.joined(separator: " // ") ?? "")",
                "\(typeLine.joined(separator: " // "))",
                "\"\(oracleText?.joined(separator: "\n//\n").rfc4180CompliantFieldWithDoubleQuotes ?? "")\"",
                "\(colors?.map({$0.map(\.rawValue).joined()}).joined(separator: " // ") ?? "")",
                "\(oracleID.map(\.uuidString).joined(separator: " // "))",
                "\(layout.rawValue)",
                "\(arenaID.map({String($0)}) ?? "" )",
                "\(mtgoID.map({String($0)}) ?? "" )",
                "\(multiverseIDs.map({$0.map({String($0)})})?.joined(separator: ", ").rfc4180CompliantFieldWithDoubleQuotes ?? "")",
                "\(cardmarketID.map({String($0)}) ?? "" )",
                "\(scryfallID.uuidString)",
                //                "\(relatedCards)", // TODO: flatten info eg related card name, scryfall ID, etc?
                "\(defense?.joined(separator: " // ") ?? "")",
                "\(loyalty?.joined(separator: " // ") ?? "")",
                "\(power?.joined(separator: " // ") ?? "")",
                "\(toughness?.joined(separator: " // ") ?? "")",
                "\(cmc.map(\.description).joined(separator: " // "))",
                "\(colorIdentity.map({$0.map(\.rawValue).joined()}).joined(separator: " // "))",
                "\(edhrecRank.map({String($0)}) ?? "" )",
                "\(keywords.map({$0.joined(separator: ", ")}).joined(separator: " // ").rfc4180CompliantFieldWithDoubleQuotes)",
                "\(pennyRank.map({String($0)}) ?? "" )",
                "\(producedMana?.map({$0.map(\.rawValue).joined()}).joined(separator: " // ") ?? "")",
                "\(reprint.map(\.description).joined(separator: " // "))",
                "\(reserved.map(\.description).joined(separator: " // "))",
                
                "\(legalities[.standard]!)",
                "\(legalities[.future]!)",
                "\(legalities[.historic]!)",
                "\(legalities[.timeless]!)",
                "\(legalities[.gladiator]!)",
                "\(legalities[.pioneer]!)",
                "\(legalities[.explorer]!)",
                "\(legalities[.modern]!)",
                "\(legalities[.legacy]!)",
                "\(legalities[.pauper]!)",
                "\(legalities[.vintage]!)",
                "\(legalities[.penny]!)",
                "\(legalities[.commander]!)",
                "\(legalities[.oathbreaker]!)",
                "\(legalities[.brawl]!)",
                "\(legalities[.historicbrawl]!)",
                "\(legalities[.alchemy]!)",
                "\(legalities[.paupercommander]!)",
                "\(legalities[.duel]!)",
                "\(legalities[.oldschool]!)",
                "\(legalities[.premodern]!)",
                "\(legalities[.predh]!)",
                
                "\(dateFormatter.string(from: fetchDate))",
            ].joined(separator: ",")
        }
    }
    
    var name: String
    var simpleName: String
    var set: String
    var cardNumber: UInt
    var setCode: String
    var language: String
    
    var printing: [Finish]
    var condition: Condition
    var rarity: Rarity
    
    var tcgPlayerInfo: TCGPlayerInfo
    var scryfallInfo: ScryfallInfo?
    
    public init?(tcgPlayerFetchDate: Date, keyValues: [String: String]) {
        guard let name = keyValues["Name"] else { fatalError("failed to parse field") }
        self.name = name.rfc4180CompliantFieldWithDoubleQuotes
        
        guard let simpleName = keyValues["Simple Name"] else { fatalError("failed to parse field") }
        self.simpleName = simpleName.rfc4180CompliantFieldWithDoubleQuotes
        
        guard let set = keyValues["Set"] else { fatalError("failed to parse field") }
        self.set = set.rfc4180CompliantFieldWithDoubleQuotes
        
        guard let cardNumber = keyValues["Card Number"]?.unsignedIntegerValue else { fatalError("failed to parse field") }
        self.cardNumber = cardNumber
        
        guard var setCode = keyValues["Set Code"] else { fatalError("failed to parse field") }
        if setCode == "GAME" {
            setCode = "SCH" // TCGPlayer calls the "Game Day & Store Championship Promos" set by code "GAME", while Scryfall calls it "SCH"; go with Scryfall's, as it's more consistent and that's what we'll be using to query their API with anyways
        }
        self.setCode = setCode
        
        guard let language = keyValues["Language"] else { fatalError("failed to parse field") }
        self.language = language
        
        guard let rawValue = keyValues["Printing"], let printing = Finish(rawValue: rawValue) else { fatalError("failed to parse field") }
        self.printing = [printing]
        
        guard let rawValue = keyValues["Condition"], let condition = Condition(rawValue: rawValue) else { fatalError("failed to parse field") }
        self.condition = condition
        
        guard let rawValue = keyValues["Rarity"], let rarity = Rarity(rawValue: rawValue) else { fatalError("failed to parse field") }
        self.rarity = rarity
        
        guard let productID = keyValues["Product ID"] else { fatalError("failed to parse field") }
        guard let sku = keyValues["SKU"] else { fatalError("failed to parse field") }
        guard let string = keyValues["Price Each"]?.dropFirst(), let priceEach = Decimal(string: String(string)) else { fatalError("failed to parse field") }
        tcgPlayerInfo = TCGPlayerInfo(productID: productID, SKU: sku, priceEach: priceEach, fetchDate: tcgPlayerFetchDate)
    }
    
    public init?(managedCSVKeyValues keyValues: [String: String]) {
        guard let name = keyValues[CardCSVField.name.rawValue] else { fatalError("failed to parse field") }
        self.name = name
        
        guard let simpleName = keyValues[CardCSVField.simpleName.rawValue] else { fatalError("failed to parse field") }
        self.simpleName = simpleName
        
        guard let set = keyValues[CardCSVField.set.rawValue] else { fatalError("failed to parse field") }
        self.set = set
        
        guard let cardNumber = keyValues[CardCSVField.cardNumber.rawValue]?.unsignedIntegerValue else { fatalError("failed to parse field") }
        self.cardNumber = cardNumber
        
        guard let setCode = keyValues[CardCSVField.setCode.rawValue] else { fatalError("failed to parse field") }
        self.setCode = setCode
        
        guard let language = keyValues[CardCSVField.language.rawValue] else { fatalError("failed to parse field") }
        self.language = language
        
        guard let rawValue = keyValues[CardCSVField.printing.rawValue] else { fatalError("failed to parse field") }
        let printing = rawValue.components(separatedBy: ",").compactMap({ Finish(rawValue: $0) })
        guard !printing.isEmpty else { fatalError("failed to parse field") }
        self.printing = printing
        
        guard let rawValue = keyValues[CardCSVField.condition.rawValue], let condition = Condition(rawValue: rawValue) else { fatalError("failed to parse field") }
        self.condition = condition
        
        guard let rawValue = keyValues[CardCSVField.rarity.rawValue], let rarity = Rarity(rawValue: rawValue) else { fatalError("failed to parse field") }
        self.rarity = rarity
        
        guard let tcgPlayerInfo = TCGPlayerInfo(managedCSVKeyValues: keyValues) else { fatalError("failed to parse TCGPlayer Info")}
        self.tcgPlayerInfo = tcgPlayerInfo
    }
    
    public func csvRow(quantity: UInt) -> String {
        var fields = [
            "\(quantity)",
            "\"\(name)\"",
            "\"\(simpleName)\"",
            "\"\(set)\"",
            "\(setCode)",
            "\(cardNumber)",
            "\(language)",
            "\"\(printing.map({$0.rawValue}).joined(separator: ","))\"",
            "\(rarity.rawValue)",
            "\(condition.rawValue)",
            tcgPlayerInfo.csvRow,
        ]
        
        if let scryfallInfo {
            fields.append(scryfallInfo.csvRow)
        }
        
        return fields.joined(separator: ",")
    }
    
    public mutating func fetchScryfallInfo() {
        let name = self.name
        let setCode = self.setCode.lowercased()
        let number = self.cardNumber
        
        var scryfallCard: ScryfallCard?
        let group = DispatchGroup()
        group.enter()
        urlSession.dataTask(with: requestFor(cardSet: setCode, cardNumber: cardNumber)) { data, response, error in
            defer {
                usleep(rateLimit)
                group.leave()
            }
            
            guard error == nil else {
                print("[Scryfall] Failed to fetch card: \(name) (\(setCode) \(number)): \(String(describing: error))")
                return
            }
            
            let status = (response as! HTTPURLResponse).statusCode
            
            guard status != 404 else {
                print("[Scryfall] Card not found: \(name) (\(setCode) \(number))")
                return
            }
            
            guard status >= 200 && status < 300 else {
                print("[Scryfall] Unexpected error fetching card: \(name) (\(setCode) \(number))")
                return
            }
            
            guard let data else {
                print("[Scryfall] Request to fetch card succeeded but response data was empty: \(name) (\(setCode) \(number))")
                return
            }
            
            do {
                scryfallCard = try jsonDecoder.decode(ScryfallCard.self, from: data)
            } catch {
                guard let responseDataString = String(data: data, encoding: .utf8) else {
                    print("[Scryfall] Response data can't be decoded to a string for debugging: \(name) (\(setCode) \(number))")
                    return
                }
                print("[Scryfall] Failed decoding API response for: \(name) (\(setCode) \(number)): \(error) (string contents: \(responseDataString)")
            }
        }.resume()
        group.wait()
        
        guard let scryfallCard else {
            print("[Scryfall] failed to get card info for \(name)")
            return
        }
        
        // combine some properties with those that already existed from TCGPlayerInfo but with possibly slight differences
        
        let scryfallFinishes: [[ScryfallFinish]]?
        if let finishes = scryfallCard.card_faces?.compactMap(\.finishes) {
            scryfallFinishes = finishes
        } else {
            scryfallFinishes = scryfallCard.finishes == nil ? nil : [scryfallCard.finishes!]
        }
        if let scryfallFinish = scryfallFinishes?.first {
            self.printing = scryfallFinish.map({ Finish(scryfallFinish: $0) })
        let scryfallRarity: [ScryfallRarity]
        if let rarity = scryfallCard.rarity {
            scryfallRarity = [rarity]
        } else {
            scryfallRarity = scryfallCard.card_faces!.compactMap(\.rarity)
        }
        guard Set(scryfallRarity.map({$0.rawValue})).count == 1 else { fatalError("Faces have different rarities!") }
        if scryfallRarity.first == .bonus {
            self.rarity = .bonus
        } else if self.rarity != .promo && self.rarity != .land {
            guard self.rarity == .common && scryfallRarity.first == .common
                    || self.rarity == .uncommon && scryfallRarity.first == .uncommon
                    || self.rarity == .rare && scryfallRarity.first == .rare
                    || self.rarity == .mythic && scryfallRarity.first == .mythic
                    || self.rarity == .special && scryfallRarity.first == .special
            else { fatalError("TCGPlayer and Scryfall disagree on rarity level!")}
        }
        
        self.scryfallInfo = ScryfallInfo(scryfallCard: scryfallCard, fetchDate: Date())
    }
}
