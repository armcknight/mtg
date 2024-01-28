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
    case standardbrawl = "Standard Brawl Legal?"
    case alchemy = "Alchemy Legal?"
    case paupercommander = "Pauper Commander Legal?"
    case duel = "Duel Legal?"
    case oldschool = "Old School Legal?"
    case premodern = "Premodern Legal?"
    case predh = "PreDH Legal?"
    case fetchDate = "Scryfall Fetch Date"
}

public let csvHeaders = CardCSVField.allCases.map(\.rawValue) + TCGPlayerField.allCases.map(\.rawValue) + ScryfallField.allCases.map(\.rawValue)

public let csvHeaderRow = csvHeaders.joined(separator: ",")

extension String {
    var faceSplit: [String] {
        split(separator: Card.faceSeparator).map { String($0) }
    }
    
    var valueSplit: [String] {
        split(separator: Card.valueSeparator).map { String($0) }
    }
    
    var unquoted: String {
        guard contains("\"") else { return self }
        if self == "\"\"" { return "" }
        return String(self[index(startIndex, offsetBy: 1)..<index(startIndex, offsetBy: count - 1)])
    }
}

extension Array where Element == String {
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
        
        init(managedCSVKeyValues keyValues: [String: String]) {
            guard let productID = keyValues[TCGPlayerField.productID.rawValue] else { fatalError("failed to parse \(TCGPlayerField.productID.rawValue)") }
            guard let sku = keyValues[TCGPlayerField.sku.rawValue] else { fatalError("failed to parse \(TCGPlayerField.sku.rawValue)") }
            guard let priceValue = keyValues[TCGPlayerField.priceEach.rawValue] else { fatalError("Failed to get price value") }
            guard let priceEach = Decimal(string: String(priceValue)) else { fatalError("failed to parse price") }
            guard let fetchDateString = keyValues[TCGPlayerField.fetchDate.rawValue] else { fatalError("Failed to get TCGPlayer fetch date string" )}
            guard let fetchDate = dateFormatter.date(from: fetchDateString) else { fatalError("failed to parse TCGPlayer fetch date") }
            self = TCGPlayerInfo(productID: productID, SKU: sku, priceEach: priceEach, fetchDate: fetchDate)
        }
    }
    
    public struct ScryfallInfo {
        var booster: Bool
        public var frameEffects: [[ScryfallFrameEffect]]?
        public var fullArt: [Bool]
        public var promoTypes: [[ScryfallPromoType]]?
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
        public var scryfallID: UUID
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
            if let typeLine = scryfallCard.type_line {
                self.typeLine = [typeLine]
            } else {
                self.typeLine = scryfallCard.card_faces!.compactMap(\.type_line)
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
                
        public init(managedCSVKeyValues keyValues: [String: String]) {
            guard let boosterValue = keyValues[ScryfallField.booster.rawValue] else { fatalError("failed to parse \(ScryfallField.booster.rawValue)") }
            guard let booster = Bool(boosterValue) else { fatalError("Failed to decode booster value \(boosterValue)")}
            self.booster = booster
            
            guard let frameEffectsValue = keyValues[ScryfallField.frameEffects.rawValue] else { fatalError("failed to parse \(ScryfallField.frameEffects.rawValue)") }
            self.frameEffects = frameEffectsValue.unquoted.faceSplit.map({$0.split(separator: ", ").compactMap({ScryfallFrameEffect(rawValue: String($0))})})
            
            guard let fullArtValue = keyValues[ScryfallField.fullArt.rawValue] else { fatalError("failed to parse \(ScryfallField.fullArt.rawValue)") }
            self.fullArt = fullArtValue.faceSplit.map({
                guard let result = Bool(String($0)) else { fatalError("Failed to decode full art value from \($0)") }
                        return result
            })
            
            guard let promoTypesValue = keyValues[ScryfallField.promoTypes.rawValue] else { fatalError("failed to parse \(ScryfallField.promoTypes.rawValue)") }
            self.promoTypes = promoTypesValue.unquoted.faceSplit.map({$0.valueSplit.compactMap({ScryfallPromoType(rawValue: $0)})})
            
            guard let setTypeValue = keyValues[ScryfallField.setType.rawValue] else { fatalError("failed to parse \(ScryfallField.setType.rawValue)") }
            self.setType = setTypeValue.faceSplit.map({
                guard let result = ScryfallSetType(rawValue: $0) else { fatalError("Failed to decode set type from \($0)") }
                return result
            })
            
            guard let colorIndicatorValue = keyValues[ScryfallField.colorIndicator.rawValue] else { fatalError("failed to parse \(ScryfallField.colorIndicator.rawValue)") }
            self.colorIndicator = colorIndicatorValue.faceSplit.map({$0.compactMap({ScryfallColor(rawValue: String($0))})})
            
            guard let manaCostValue = keyValues[ScryfallField.manaCost.rawValue] else { fatalError("failed to parse \(ScryfallField.manaCost.rawValue)") }
            self.manaCost = manaCostValue.faceSplit
            
            guard let typeLineValue = keyValues[ScryfallField.typeLine.rawValue] else { fatalError("failed to parse \(ScryfallField.typeLine.rawValue)") }
            self.typeLine = typeLineValue.faceSplit
            
            guard let oracleTextValue = keyValues[ScryfallField.oracleText.rawValue] else { fatalError("failed to parse \(ScryfallField.oracleText.rawValue)") }
            self.oracleText = oracleTextValue.unquoted.faceSplit
            
            guard let colorsValue = keyValues[ScryfallField.colors.rawValue] else { fatalError("failed to parse \(ScryfallField.colors.rawValue)") }
            self.colors = colorsValue.faceSplit.map({$0.compactMap({ScryfallColor(rawValue: String($0))})})
            
            guard let oracleIDValue = keyValues[ScryfallField.oracleID.rawValue] else { fatalError("failed to parse \(ScryfallField.oracleID.rawValue)") }
            self.oracleID = oracleIDValue.faceSplit.compactMap({UUID(uuidString: $0)})
            
            guard let layoutValue = keyValues[ScryfallField.layout.rawValue] else { fatalError("failed to parse \(ScryfallField.layout.rawValue)") }
            guard let layout = ScryfallLayout(rawValue: layoutValue) else { fatalError("Failed to decode scryfall layout value \(layoutValue)")}
            self.layout = layout
            
            self.arenaID = keyValues[ScryfallField.arenaID.rawValue]?.integerValue
            
            self.mtgoID = keyValues[ScryfallField.mtgoID.rawValue]?.integerValue
            
            self.multiverseIDs = keyValues[ScryfallField.multiverseIDs.rawValue]?.unquoted.valueSplit.map(\.integerValue)
            
            self.cardmarketID = keyValues[ScryfallField.cardmarketID.rawValue]?.integerValue
            
            guard let scryfallIDValue = keyValues[ScryfallField.scryfallID.rawValue] else { fatalError("failed to parse \(ScryfallField.scryfallID.rawValue)") }
            guard let scryfallID = UUID(uuidString: scryfallIDValue) else { fatalError("Failed to parse scryfall ID from \(scryfallIDValue)")}
            self.scryfallID = scryfallID
            
            self.defense = keyValues[ScryfallField.defense.rawValue]?.faceSplit
            
            self.loyalty = keyValues[ScryfallField.loyalty.rawValue]?.faceSplit
            
            self.power = keyValues[ScryfallField.power.rawValue]?.faceSplit
            
            self.toughness = keyValues[ScryfallField.toughness.rawValue]?.faceSplit
            
            guard let cmcValue = keyValues[ScryfallField.cmc.rawValue] else { fatalError("failed to parse \(ScryfallField.cmc.rawValue)") }
            self.cmc = cmcValue.faceSplit.map({
                guard let result = Decimal(string: $0) else { fatalError("Failed to decode cmc from \($0)")}
                return result
            })
            
            guard let colorIdentityValue = keyValues[ScryfallField.colorIdentity.rawValue] else { fatalError("failed to parse \(ScryfallField.colorIdentity.rawValue)") }
            self.colorIdentity = colorIdentityValue.faceSplit.map({$0.map({
                guard let result = ScryfallColor(rawValue: String($0)) else { fatalError("Failed to decode color from \($0)") }
                return result
            })})
            
            self.edhrecRank = keyValues[ScryfallField.edhrecRank.rawValue]?.integerValue
            
            guard let keywordsValue = keyValues[ScryfallField.keywords.rawValue] else { fatalError("failed to parse \(ScryfallField.keywords.rawValue)") }
            self.keywords = keywordsValue.faceSplit.map({$0.valueSplit})
            
            self.pennyRank = keyValues[ScryfallField.pennyRank.rawValue]?.integerValue
            
            guard let producedManaValue = keyValues[ScryfallField.producedMana.rawValue] else { fatalError("failed to parse \(ScryfallField.producedMana.rawValue)") }
            self.producedMana = producedManaValue.faceSplit.map({$0.compactMap({ScryfallManaType(rawValue: String($0))})})
            
            guard let reprintValue = keyValues[ScryfallField.reprint.rawValue] else { fatalError("failed to parse \(ScryfallField.reprint.rawValue)") }
            self.reprint = reprintValue.faceSplit.map({
                guard let result = Bool($0) else { fatalError("Failed to decode bool from \($0)")}
                return result
            })
            
            guard let reservedValue = keyValues[ScryfallField.reserved.rawValue] else { fatalError("failed to parse \(ScryfallField.reserved.rawValue)") }
            self.reserved = reservedValue.faceSplit.map({
                guard let result = Bool($0) else { fatalError("Failed to decode bool from \($0)")}
                return result
            })
            
            guard let standardValue = keyValues[ScryfallField.standard.rawValue] else { fatalError("failed to parse \(ScryfallField.standard.rawValue)") }
            guard let standardLegality = ScryfallLegality(rawValue: standardValue) else { fatalError("Failed to decode standard legality from \(standardValue)")}
            
            guard let futureValue = keyValues[ScryfallField.future.rawValue] else { fatalError("failed to parse \(ScryfallField.future.rawValue)") }
            guard let futureLegality = ScryfallLegality(rawValue: futureValue) else { fatalError("Failed to decode future legality from \(futureValue)")}
            guard let historicValue = keyValues[ScryfallField.historic.rawValue] else { fatalError("failed to parse \(ScryfallField.historic.rawValue)") }
            guard let historicLegality = ScryfallLegality(rawValue: historicValue) else { fatalError("Failed to decode historic legality from \(historicValue)")}
            guard let timelessValue = keyValues[ScryfallField.timeless.rawValue] else { fatalError("failed to parse \(ScryfallField.timeless.rawValue)") }
            guard let timelessLegality = ScryfallLegality(rawValue: timelessValue) else { fatalError("Failed to decode timeless legality from \(timelessValue)")}
            guard let gladiatorValue = keyValues[ScryfallField.gladiator.rawValue] else { fatalError("failed to parse \(ScryfallField.gladiator.rawValue)") }
            guard let gladiatorLegality = ScryfallLegality(rawValue: gladiatorValue) else { fatalError("Failed to decode gladiator legality from \(gladiatorValue)")}
            guard let pioneerValue = keyValues[ScryfallField.pioneer.rawValue] else { fatalError("failed to parse \(ScryfallField.pioneer.rawValue)") }
            guard let pioneerLegality = ScryfallLegality(rawValue: pioneerValue) else { fatalError("Failed to decode pioneer legality from \(pioneerValue)")}
            guard let explorerValue = keyValues[ScryfallField.explorer.rawValue] else { fatalError("failed to parse \(ScryfallField.explorer.rawValue)") }
            guard let explorerLegality = ScryfallLegality(rawValue: explorerValue) else { fatalError("Failed to decode explorer legality from \(explorerValue)")}
            guard let modernValue = keyValues[ScryfallField.modern.rawValue] else { fatalError("failed to parse \(ScryfallField.modern.rawValue)") }
            guard let modernLegality = ScryfallLegality(rawValue: modernValue) else { fatalError("Failed to decode modern legality from \(modernValue)")}
            guard let legacyValue = keyValues[ScryfallField.legacy.rawValue] else { fatalError("failed to parse \(ScryfallField.legacy.rawValue)") }
            guard let legacyLegality = ScryfallLegality(rawValue: legacyValue) else { fatalError("Failed to decode legacy legality from \(legacyValue)")}
            guard let pauperValue = keyValues[ScryfallField.pauper.rawValue] else { fatalError("failed to parse \(ScryfallField.pauper.rawValue)") }
            guard let pauperLegality = ScryfallLegality(rawValue: pauperValue) else { fatalError("Failed to decode pauper legality from \(pauperValue)")}
            guard let vintageValue = keyValues[ScryfallField.vintage.rawValue] else { fatalError("failed to parse \(ScryfallField.vintage.rawValue)") }
            guard let vintageLegality = ScryfallLegality(rawValue: vintageValue) else { fatalError("Failed to decode vintage legality from \(vintageValue)")}
            guard let pennyValue = keyValues[ScryfallField.penny.rawValue] else { fatalError("failed to parse \(ScryfallField.penny.rawValue)") }
            guard let pennyLegality = ScryfallLegality(rawValue: pennyValue) else { fatalError("Failed to decode penny legality from \(pennyValue)")}
            guard let commanderValue = keyValues[ScryfallField.commander.rawValue] else { fatalError("failed to parse \(ScryfallField.commander.rawValue)") }
            guard let commanderLegality = ScryfallLegality(rawValue: commanderValue) else { fatalError("Failed to decode commander legality from \(commanderValue)")}
            guard let oathbreakerValue = keyValues[ScryfallField.oathbreaker.rawValue] else { fatalError("failed to parse \(ScryfallField.oathbreaker.rawValue)") }
            guard let oathbreakerLegality = ScryfallLegality(rawValue: oathbreakerValue) else { fatalError("Failed to decode oathbreaker legality from \(oathbreakerValue)")}
            guard let brawlValue = keyValues[ScryfallField.brawl.rawValue] else { fatalError("failed to parse \(ScryfallField.brawl.rawValue)") }
            guard let brawlLegality = ScryfallLegality(rawValue: brawlValue) else { fatalError("Failed to decode brawl legality from \(brawlValue)")}
            guard let standardbrawlValue = keyValues[ScryfallField.standardbrawl.rawValue] else { fatalError("failed to parse \(ScryfallField.standardbrawl.rawValue)") }
            guard let standardbrawlLegality = ScryfallLegality(rawValue: standardbrawlValue) else { fatalError("Failed to decode historicbrawl legality from \(standardbrawlValue)")}
            guard let alchemyValue = keyValues[ScryfallField.alchemy.rawValue] else { fatalError("failed to parse \(ScryfallField.alchemy.rawValue)") }
            guard let alchemyLegality = ScryfallLegality(rawValue: alchemyValue) else { fatalError("Failed to decode alchemy legality from \(alchemyValue)")}
            guard let paupercommanderValue = keyValues[ScryfallField.paupercommander.rawValue] else { fatalError("failed to parse \(ScryfallField.paupercommander.rawValue)") }
            guard let paupercommanderLegality = ScryfallLegality(rawValue: paupercommanderValue) else { fatalError("Failed to decode paupercommander legality from \(paupercommanderValue)")}
            guard let duelValue = keyValues[ScryfallField.duel.rawValue] else { fatalError("failed to parse \(ScryfallField.duel.rawValue)") }
            guard let duelLegality = ScryfallLegality(rawValue: duelValue) else { fatalError("Failed to decode duel legality from \(duelValue)")}
            guard let oldschoolValue = keyValues[ScryfallField.oldschool.rawValue] else { fatalError("failed to parse \(ScryfallField.oldschool.rawValue)") }
            guard let oldschoolLegality = ScryfallLegality(rawValue: oldschoolValue) else { fatalError("Failed to decode oldschool legality from \(oldschoolValue)")}
            guard let premodernValue = keyValues[ScryfallField.premodern.rawValue] else { fatalError("failed to parse \(ScryfallField.premodern.rawValue)") }
            guard let premodernLegality = ScryfallLegality(rawValue: premodernValue) else { fatalError("Failed to decode premodern legality from \(premodernValue)")}
            guard let predhValue = keyValues[ScryfallField.predh.rawValue] else { fatalError("failed to parse \(ScryfallField.predh.rawValue)") }
            guard let predhLegality = ScryfallLegality(rawValue: predhValue) else { fatalError("Failed to decode predh legality from \(predhValue)")}
            self.legalities = [
                .standard: standardLegality,
                .future: futureLegality,
                .historic: historicLegality,
                .timeless: timelessLegality,
                .gladiator: gladiatorLegality,
                .pioneer: pioneerLegality,
                .explorer: explorerLegality,
                .modern: modernLegality,
                .legacy: legacyLegality,
                .pauper: pauperLegality,
                .vintage: vintageLegality,
                .penny: pennyLegality,
                .commander: commanderLegality,
                .oathbreaker: oathbreakerLegality,
                .brawl: brawlLegality,
                .standardbrawl: standardbrawlLegality,
                .alchemy: alchemyLegality,
                .paupercommander: paupercommanderLegality,
                .duel: duelLegality,
                .oldschool: oldschoolLegality,
                .premodern: premodernLegality,
                .predh: predhLegality,
            ]
            
            guard let fetchDateValue = keyValues[ScryfallField.fetchDate.rawValue] else { fatalError("failed to parse \(ScryfallField.fetchDate.rawValue)") }
            guard let date = dateFormatter.date(from: fetchDateValue) else { fatalError("Failed to decode date from \(fetchDateValue)") }
            self.fetchDate = date
        }
        
        public var csvRow: String {
            [
                "\(booster)",
                "\"\(frameEffects?.map({$0.map(\.rawValue).valueJoin}).faceJoin ?? "")\"",
                "\(fullArt.map(\.description).faceJoin)",
                "\"\(promoTypes?.map({$0.map(\.rawValue).valueJoin}).faceJoin ?? "")\"",
                "\(setType.map(\.rawValue).faceJoin)",
                "\(colorIndicator?.map({$0.map(\.rawValue).joined()}).faceJoin ?? "")",
                "\(manaCost?.faceJoin ?? "")",
                "\(typeLine.faceJoin)",
                "\"\(oracleText?.map({$0.replacingOccurrences(of: "\n", with: "; ")}).faceJoin ?? "")\"".rfc4180CompliantFieldWithDoubleQuotes,
                "\(colors?.map({$0.map(\.rawValue).joined()}).faceJoin ?? "")",
                "\(oracleID.map(\.uuidString).faceJoin)",
                "\(layout.rawValue)",
                "\(arenaID.map({String($0)}) ?? "" )",
                "\(mtgoID.map({String($0)}) ?? "" )",
                "\"\(multiverseIDs.map({$0.map({String($0)})})?.valueJoin ?? "")\"",
                "\(cardmarketID.map({String($0)}) ?? "" )",
                "\(scryfallID.uuidString)",
                "\(defense?.faceJoin ?? "")",
                "\(loyalty?.faceJoin ?? "")",
                "\(power?.faceJoin ?? "")",
                "\(toughness?.faceJoin ?? "")",
                "\(cmc.map(\.description).faceJoin)",
                "\(colorIdentity.map({$0.map(\.rawValue).joined()}).faceJoin)",
                "\(edhrecRank.map({String($0)}) ?? "" )",
                "\"\(keywords.map({$0.valueJoin}).faceJoin)\"",
                "\(pennyRank.map({String($0)}) ?? "" )",
                "\(producedMana?.map({$0.map(\.rawValue).joined()}).faceJoin ?? "")",
                "\(reprint.map(\.description).faceJoin)",
                "\(reserved.map(\.description).faceJoin)",
                
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
                "\(legalities[.standardbrawl]!)",
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
    public var cardNumber: String
    public var setCode: String
    var language: String
    
    public var finish: Finish
    var rarity: Rarity
    
    var tcgPlayerInfo: TCGPlayerInfo
    public var scryfallInfo: ScryfallInfo?
    
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
        
        guard let productID = keyValues["Product ID"] else { fatalError("failed to parse \("Product ID")") }
        guard let sku = keyValues["SKU"] else { fatalError("failed to parse \("SKU")") }
        guard let string = keyValues["Price Each"]?.dropFirst() else { fatalError("No value for Price Each")}
        guard let priceEach = Decimal(string: String(string)) else { fatalError("failed to parse TCGPlayer Price from \(string)") }

        tcgPlayerInfo = TCGPlayerInfo(productID: productID, SKU: sku, priceEach: priceEach, fetchDate: tcgPlayerFetchDate)
    }
    
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
        
        self.tcgPlayerInfo = TCGPlayerInfo(managedCSVKeyValues: keyValues)
        self.scryfallInfo = ScryfallInfo(managedCSVKeyValues: keyValues)
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
            "\(finish.rawValue)",
            "\(rarity.rawValue)",
            tcgPlayerInfo.csvRow,
        ]
        
        if let scryfallInfo {
            fields.append(scryfallInfo.csvRow)
        }
        
        return fields.joined(separator: ",")
    }
    
    var scryfallSetCode: String {
        var setCode = self.setCode.lowercased()
        
        if setCode.count == 5 && setCode.hasPrefix("pp") {
            setCode = "p" + setCode[setCode.index(setCode.startIndex, offsetBy: 2)...]
            
            // scryfall doesn't put these in promo sets even though they are promos
            if name == "Tanglespan Lookout" && cardNumber == "379" {
                setCode = "woe"
            }
            else if name == "Sleight of Hand" && cardNumber == "376" {
                setCode = "woe"
            }
            else if name == "Deep-Cavern Bat" && cardNumber == "406" {
                setCode = "lci"
            }
        }
        
        else {
            switch setCode {
            case "ctd": setCode = "cst" // tcgplayer calls the coldsnap theme deck set "ctd" but scryfall calls it "cst"
            case "game": setCode = "sch" // TCGPlayer calls the "Game Day & Store Championship Promos" set by code "GAME", while Scryfall calls it "SCH"; go with Scryfall's, as it's more consistent and that's what we'll be using to query their API with anyways
            case "list":
                setCode = "plist"
                switch name {
                case "Soothsaying": // there's no printing in "the list" set on scryfall for this card, just fall back to its original printing
                    setCode = "mmq"
                case "Direct Current": // there's no printing in "the list" set on scryfall for this card, just fall back to its original printing
                    setCode = "grn"
                case "Larger Than Life": // there's no printing in "the list" set on scryfall for this card, just fall back to its original printing and number
                    setCode = "kld"
                case "Territorial Hammerskull":
                    setCode = "xln"
                default: break
                }
            default:
                switch name {
                case "Lotus Petal (Foil Etched)": setCode = "p30m"
                case "Phyrexian Arena (Phyrexian) (ONE Bundle)": setCode = "one"
                case "Katilda and Lier": setCode = "moc"
                case "Drown in the Loch (Retro Frame)": setCode = "pw23"
                case "Queen Kayla bin-Kroog (Retro Frame) (BRO Bundle)": setCode = "bro"
                case "Hit the Mother Lode (LCI Bundle)": setCode = "lci"
                default: break
                }
            }
        }
        
        return setCode
    }
    
    var scryfallCardNumber: String {
        var cardNumber = self.cardNumber
        
        switch setCode.lowercased() {
        case "list": fatalError("use alternate data structure to get plst cards instead of hardcoding a workaround for each card")
        default:
            switch name {
            case "Lotus Petal (Foil Etched)":
                cardNumber = "2" // it's actually card #1 but because all the cards in P30M are 1, scryfall stores this one as 2
            default: break
            }
        }
        
        return cardNumber
    }
    
    public mutating func fetchScryfallInfo(scryfallCards: ScryfallCardLookups) {        
        let scryfallCard: ScryfallCard?
        
        // TCGPlayer scans have their own numbering system for cards in The List set, and Scryfall has a different scheme. Find it
        if setCode == "plst" {
            scryfallCard = scryfallCards.byNameAndSet[name]?["plst"]
        } else {
            scryfallCard = scryfallCards.bySetAndNumber[scryfallSetCode]?[scryfallCardNumber]
        }
        
        guard let scryfallCard else {
            print("[Scryfall] failed to get card info for TCGPlayer card \(name) (\(setCode) \(cardNumber))")
            return
        }
        
        // combine some properties with those that already existed from TCGPlayerInfo but with possibly slight differences
        
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
            if name == "Mind Stone" && setCode == "WOC" && cardNumber == "148" {
                self.rarity = .uncommon // this is incorrectly listed as common on scryfall
            } 
            else if name == "Dimir Signet" && setCode == "WOC" && cardNumber == "146" {
                self.rarity = .uncommon // this is incorrectly listed as common on tcgplayer
            } 
            else if name == "Wakening Sun's Avatar" && setCode == "LCC" && cardNumber == "139" {
                self.rarity = .mythic // this is incorrectly listed as rare on tcgplayer
            }
            else if name == "Cultivate" && setCode == "LCC" && cardNumber == "235" {
                self.rarity = .common // tcgplayer incorrectly lists it as uncommon
            }
            else if name == "Zacama, Primal Calamity" && setCode == "LCC" && cardNumber == "296" {
                self.rarity = .mythic // tcgplayer incorrectly lists it as rare
            }
            else if name == "Rampaging Brontodon" && setCode == "LCC" && cardNumber == "247" {
                self.rarity = .rare // tcgplayer incorrectly lists it as uncommon
            }
            else {
                let raritiesAgree = (self.rarity == .common && scryfallRarity.first == .common)
                || (self.rarity == .uncommon && scryfallRarity.first == .uncommon)
                || (self.rarity == .rare && scryfallRarity.first == .rare)
                || (self.rarity == .mythic && scryfallRarity.first == .mythic)
                || (self.rarity == .special && scryfallRarity.first == .special)
                if !raritiesAgree {
                    print("TCGPlayer and Scryfall disagree on rarity level for TCGPlayer card \(name) (\(setCode) \(cardNumber))!")
                }
            }
        }
        
        self.scryfallInfo = ScryfallInfo(scryfallCard: scryfallCard, fetchDate: Date())
    }
}
