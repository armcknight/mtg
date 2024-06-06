//
//  ScryfallInfo.swift
//  mtg
//
//  Created by Andrew McKnight on 6/5/24.
//

import Foundation
import scryfall

public struct ScryfallInfo {
    var name: String?
    var printedName: String?
    var setName: String?
    var rarity: ScryfallRarity?
    var tcgPlayerID: Int?
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
    var setCode: String
    var url: URL
    var legalities: [ScryfallFormat: ScryfallLegality]
}

extension ScryfallInfo {
    public init(scryfallCard: ScryfallCard, fetchDate: Date) {
        self.name = scryfallCard.name
        self.printedName = scryfallCard.printed_name
        if let setName = scryfallCard.set_name {
            self.setName = setName
        } else {
            self.setName = scryfallCard.card_faces!.compactMap(\.set_name).first
        }
        if let rarity = scryfallCard.rarity {
            self.rarity = rarity
        } else {
            self.rarity = scryfallCard.card_faces!.compactMap(\.rarity).first
        }
        if let fullArt = scryfallCard.full_art {
            self.fullArt = [fullArt]
        } else {
            self.fullArt = scryfallCard.card_faces!.compactMap(\.full_art)
        }
        self.tcgPlayerID = scryfallCard.tcgplayer_id
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
        self.url = scryfallCard.scryfall_uri
        self.setCode = scryfallCard.set ?? scryfallCard.card_faces!.first!.set!
        self.legalities = scryfallCard.legalities
    }
    
    public init(managedCSVKeyValues keyValues: [String: String]) {
        guard let fetchDateValue = keyValues[CSVHeader.fetchDate.rawValue] else { fatalError("failed to parse \(CSVHeader.fetchDate.rawValue)") }
        guard let date = dateFormatter.date(from: fetchDateValue) else { fatalError("Failed to decode date from \(fetchDateValue)") }
        self.fetchDate = date
        
        guard let urlValue = keyValues[CSVHeader.scryfallURL.rawValue] else { fatalError("failed to parse \(CSVHeader.scryfallURL.rawValue)") }
        guard let url = URL(string: urlValue) else { fatalError("Failed to decode url from \(urlValue)") }
        self.url = url
        
        guard let setCodeValue = keyValues[CSVHeader.scryfallSetCode.rawValue] else { fatalError("Failed to parse \(CSVHeader.scryfallSetCode.rawValue)") }
        self.setCode = setCodeValue
        
        guard let boosterValue = keyValues[CSVHeader.booster.rawValue] else { fatalError("failed to parse \(CSVHeader.booster.rawValue)") }
        guard let booster = Bool(boosterValue) else { fatalError("Failed to decode booster value \(boosterValue)")}
        self.booster = booster
        
        guard let frameEffectsValue = keyValues[CSVHeader.frameEffects.rawValue] else { fatalError("failed to parse \(CSVHeader.frameEffects.rawValue)") }
        self.frameEffects = frameEffectsValue.unquoted.faceSplit.map({$0.split(separator: ", ").compactMap({ScryfallFrameEffect(rawValue: String($0))})})
        
        guard let fullArtValue = keyValues[CSVHeader.fullArt.rawValue] else { fatalError("failed to parse \(CSVHeader.fullArt.rawValue)") }
        self.fullArt = fullArtValue.faceSplit.map({
            guard let result = Bool(String($0)) else { fatalError("Failed to decode full art value from \($0)") }
            return result
        })
        
        guard let promoTypesValue = keyValues[CSVHeader.promoTypes.rawValue] else { fatalError("failed to parse \(CSVHeader.promoTypes.rawValue)") }
        self.promoTypes = promoTypesValue.unquoted.faceSplit.map({$0.valueSplit.compactMap({ScryfallPromoType(rawValue: $0)})})
        
        guard let setTypeValue = keyValues[CSVHeader.setType.rawValue] else { fatalError("failed to parse \(CSVHeader.setType.rawValue)") }
        self.setType = setTypeValue.faceSplit.map({
            guard let result = ScryfallSetType(rawValue: $0) else { fatalError("Failed to decode set type from \($0)") }
            return result
        })
        
        guard let colorIndicatorValue = keyValues[CSVHeader.colorIndicator.rawValue] else { fatalError("failed to parse \(CSVHeader.colorIndicator.rawValue)") }
        self.colorIndicator = colorIndicatorValue.faceSplit.map({$0.compactMap({ScryfallColor(rawValue: String($0))})})
        
        guard let manaCostValue = keyValues[CSVHeader.manaCost.rawValue] else { fatalError("failed to parse \(CSVHeader.manaCost.rawValue)") }
        self.manaCost = manaCostValue.faceSplit
        
        guard let typeLineValue = keyValues[CSVHeader.typeLine.rawValue] else { fatalError("failed to parse \(CSVHeader.typeLine.rawValue)") }
        self.typeLine = typeLineValue.faceSplit
        
        guard let oracleTextValue = keyValues[CSVHeader.oracleText.rawValue] else { fatalError("failed to parse \(CSVHeader.oracleText.rawValue)") }
        self.oracleText = oracleTextValue.valueOfRFC4180CompliantFieldWithDoubleQuotes.faceSplit
        
        guard let colorsValue = keyValues[CSVHeader.colors.rawValue] else { fatalError("failed to parse \(CSVHeader.colors.rawValue)") }
        self.colors = colorsValue.faceSplit.map({$0.compactMap({ScryfallColor(rawValue: String($0))})})
        
        guard let oracleIDValue = keyValues[CSVHeader.oracleID.rawValue] else { fatalError("failed to parse \(CSVHeader.oracleID.rawValue)") }
        self.oracleID = oracleIDValue.faceSplit.compactMap({UUID(uuidString: $0)})
        
        guard let layoutValue = keyValues[CSVHeader.layout.rawValue] else { fatalError("failed to parse \(CSVHeader.layout.rawValue)") }
        guard let layout = ScryfallLayout(rawValue: layoutValue) else { fatalError("Failed to decode scryfall layout value \(layoutValue)")}
        self.layout = layout
        
        self.arenaID = keyValues[CSVHeader.arenaID.rawValue]?.integerValue
        
        self.mtgoID = keyValues[CSVHeader.mtgoID.rawValue]?.integerValue
        
        self.multiverseIDs = keyValues[CSVHeader.multiverseIDs.rawValue]?.unquoted.valueSplit.map(\.integerValue)
        
        self.cardmarketID = keyValues[CSVHeader.cardmarketID.rawValue]?.integerValue
        
        guard let scryfallIDValue = keyValues[CSVHeader.scryfallID.rawValue] else { fatalError("failed to parse \(CSVHeader.scryfallID.rawValue)") }
        guard let scryfallID = UUID(uuidString: scryfallIDValue) else { fatalError("Failed to parse scryfall ID from \(scryfallIDValue)")}
        self.scryfallID = scryfallID
        
        self.defense = keyValues[CSVHeader.defense.rawValue]?.faceSplit
        
        self.loyalty = keyValues[CSVHeader.loyalty.rawValue]?.faceSplit
        
        self.power = keyValues[CSVHeader.power.rawValue]?.faceSplit
        
        self.toughness = keyValues[CSVHeader.toughness.rawValue]?.faceSplit
        
        guard let cmcValue = keyValues[CSVHeader.cmc.rawValue] else { fatalError("failed to parse \(CSVHeader.cmc.rawValue)") }
        self.cmc = cmcValue.faceSplit.map({
            guard let result = Decimal(string: $0) else { fatalError("Failed to decode cmc from \($0)")}
            return result
        })
        
        guard let colorIdentityValue = keyValues[CSVHeader.colorIdentity.rawValue] else { fatalError("failed to parse \(CSVHeader.colorIdentity.rawValue)") }
        self.colorIdentity = colorIdentityValue.faceSplit.map({$0.map({
            guard let result = ScryfallColor(rawValue: String($0)) else { fatalError("Failed to decode color from \($0)") }
            return result
        })})
        
        self.edhrecRank = keyValues[CSVHeader.edhrecRank.rawValue]?.integerValue
        
        guard let keywordsValue = keyValues[CSVHeader.keywords.rawValue] else { fatalError("failed to parse \(CSVHeader.keywords.rawValue)") }
        self.keywords = keywordsValue.faceSplit.map({$0.valueSplit})
        
        self.pennyRank = keyValues[CSVHeader.pennyRank.rawValue]?.integerValue
        
        guard let producedManaValue = keyValues[CSVHeader.producedMana.rawValue] else { fatalError("failed to parse \(CSVHeader.producedMana.rawValue)") }
        self.producedMana = producedManaValue.faceSplit.map({$0.compactMap({ScryfallManaType(rawValue: String($0))})})
        
        guard let reprintValue = keyValues[CSVHeader.reprint.rawValue] else { fatalError("failed to parse \(CSVHeader.reprint.rawValue)") }
        self.reprint = reprintValue.faceSplit.map({
            guard let result = Bool($0) else { fatalError("Failed to decode bool from \($0)")}
            return result
        })
        
        guard let reservedValue = keyValues[CSVHeader.reserved.rawValue] else { fatalError("failed to parse \(CSVHeader.reserved.rawValue)") }
        self.reserved = reservedValue.faceSplit.map({
            guard let result = Bool($0) else { fatalError("Failed to decode bool from \($0)")}
            return result
        })
        
        guard let standardValue = keyValues[CSVHeader.standard.rawValue] else { fatalError("failed to parse \(CSVHeader.standard.rawValue)") }
        guard let standardLegality = ScryfallLegality(rawValue: standardValue) else { fatalError("Failed to decode standard legality from \(standardValue)")}
        
        guard let futureValue = keyValues[CSVHeader.future.rawValue] else { fatalError("failed to parse \(CSVHeader.future.rawValue)") }
        guard let futureLegality = ScryfallLegality(rawValue: futureValue) else { fatalError("Failed to decode future legality from \(futureValue)")}
        guard let historicValue = keyValues[CSVHeader.historic.rawValue] else { fatalError("failed to parse \(CSVHeader.historic.rawValue)") }
        guard let historicLegality = ScryfallLegality(rawValue: historicValue) else { fatalError("Failed to decode historic legality from \(historicValue)")}
        guard let timelessValue = keyValues[CSVHeader.timeless.rawValue] else { fatalError("failed to parse \(CSVHeader.timeless.rawValue)") }
        guard let timelessLegality = ScryfallLegality(rawValue: timelessValue) else { fatalError("Failed to decode timeless legality from \(timelessValue)")}
        guard let gladiatorValue = keyValues[CSVHeader.gladiator.rawValue] else { fatalError("failed to parse \(CSVHeader.gladiator.rawValue)") }
        guard let gladiatorLegality = ScryfallLegality(rawValue: gladiatorValue) else { fatalError("Failed to decode gladiator legality from \(gladiatorValue)")}
        guard let pioneerValue = keyValues[CSVHeader.pioneer.rawValue] else { fatalError("failed to parse \(CSVHeader.pioneer.rawValue)") }
        guard let pioneerLegality = ScryfallLegality(rawValue: pioneerValue) else { fatalError("Failed to decode pioneer legality from \(pioneerValue)")}
        guard let explorerValue = keyValues[CSVHeader.explorer.rawValue] else { fatalError("failed to parse \(CSVHeader.explorer.rawValue)") }
        guard let explorerLegality = ScryfallLegality(rawValue: explorerValue) else { fatalError("Failed to decode explorer legality from \(explorerValue)")}
        guard let modernValue = keyValues[CSVHeader.modern.rawValue] else { fatalError("failed to parse \(CSVHeader.modern.rawValue)") }
        guard let modernLegality = ScryfallLegality(rawValue: modernValue) else { fatalError("Failed to decode modern legality from \(modernValue)")}
        guard let legacyValue = keyValues[CSVHeader.legacy.rawValue] else { fatalError("failed to parse \(CSVHeader.legacy.rawValue)") }
        guard let legacyLegality = ScryfallLegality(rawValue: legacyValue) else { fatalError("Failed to decode legacy legality from \(legacyValue)")}
        guard let pauperValue = keyValues[CSVHeader.pauper.rawValue] else { fatalError("failed to parse \(CSVHeader.pauper.rawValue)") }
        guard let pauperLegality = ScryfallLegality(rawValue: pauperValue) else { fatalError("Failed to decode pauper legality from \(pauperValue)")}
        guard let vintageValue = keyValues[CSVHeader.vintage.rawValue] else { fatalError("failed to parse \(CSVHeader.vintage.rawValue)") }
        guard let vintageLegality = ScryfallLegality(rawValue: vintageValue) else { fatalError("Failed to decode vintage legality from \(vintageValue)")}
        guard let pennyValue = keyValues[CSVHeader.penny.rawValue] else { fatalError("failed to parse \(CSVHeader.penny.rawValue)") }
        guard let pennyLegality = ScryfallLegality(rawValue: pennyValue) else { fatalError("Failed to decode penny legality from \(pennyValue)")}
        guard let commanderValue = keyValues[CSVHeader.commander.rawValue] else { fatalError("failed to parse \(CSVHeader.commander.rawValue)") }
        guard let commanderLegality = ScryfallLegality(rawValue: commanderValue) else { fatalError("Failed to decode commander legality from \(commanderValue)")}
        guard let oathbreakerValue = keyValues[CSVHeader.oathbreaker.rawValue] else { fatalError("failed to parse \(CSVHeader.oathbreaker.rawValue)") }
        guard let oathbreakerLegality = ScryfallLegality(rawValue: oathbreakerValue) else { fatalError("Failed to decode oathbreaker legality from \(oathbreakerValue)")}
        guard let brawlValue = keyValues[CSVHeader.brawl.rawValue] else { fatalError("failed to parse \(CSVHeader.brawl.rawValue)") }
        guard let brawlLegality = ScryfallLegality(rawValue: brawlValue) else { fatalError("Failed to decode brawl legality from \(brawlValue)")}
        guard let standardbrawlValue = keyValues[CSVHeader.standardbrawl.rawValue] else { fatalError("failed to parse \(CSVHeader.standardbrawl.rawValue)") }
        guard let standardbrawlLegality = ScryfallLegality(rawValue: standardbrawlValue) else { fatalError("Failed to decode historicbrawl legality from \(standardbrawlValue)")}
        guard let alchemyValue = keyValues[CSVHeader.alchemy.rawValue] else { fatalError("failed to parse \(CSVHeader.alchemy.rawValue)") }
        guard let alchemyLegality = ScryfallLegality(rawValue: alchemyValue) else { fatalError("Failed to decode alchemy legality from \(alchemyValue)")}
        guard let paupercommanderValue = keyValues[CSVHeader.paupercommander.rawValue] else { fatalError("failed to parse \(CSVHeader.paupercommander.rawValue)") }
        guard let paupercommanderLegality = ScryfallLegality(rawValue: paupercommanderValue) else { fatalError("Failed to decode paupercommander legality from \(paupercommanderValue)")}
        guard let duelValue = keyValues[CSVHeader.duel.rawValue] else { fatalError("failed to parse \(CSVHeader.duel.rawValue)") }
        guard let duelLegality = ScryfallLegality(rawValue: duelValue) else { fatalError("Failed to decode duel legality from \(duelValue)")}
        guard let oldschoolValue = keyValues[CSVHeader.oldschool.rawValue] else { fatalError("failed to parse \(CSVHeader.oldschool.rawValue)") }
        guard let oldschoolLegality = ScryfallLegality(rawValue: oldschoolValue) else { fatalError("Failed to decode oldschool legality from \(oldschoolValue)")}
        guard let premodernValue = keyValues[CSVHeader.premodern.rawValue] else { fatalError("failed to parse \(CSVHeader.premodern.rawValue)") }
        guard let premodernLegality = ScryfallLegality(rawValue: premodernValue) else { fatalError("Failed to decode premodern legality from \(premodernValue)")}
        guard let predhValue = keyValues[CSVHeader.predh.rawValue] else { fatalError("failed to parse \(CSVHeader.predh.rawValue)") }
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
    }
}

extension ScryfallInfo {
    /** Fields I get from Scryfall API calls. */
    public enum CSVHeader: String, CaseIterable {
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
        case scryfallSetCode = "Scryfall Set Code"
        case scryfallURL = "Scryfall URL"
        
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
            "\(setCode)",
            "\(url)",
            
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

extension Card.Rarity {
    init(scryfallRarity: ScryfallRarity) {
        switch scryfallRarity {
        case .common: self = .common
        case .uncommon: self = .uncommon
        case .rare: self = .rare
        case .special: self = .special
        case .mythic: self = .mythic
        case .bonus: self = .bonus
        }
    }
}

extension Card {
    mutating func fixRarity(scryfallCard: ScryfallCard) {
        let scryfallRarity: [ScryfallRarity]
        if let rarity = scryfallCard.rarity {
            scryfallRarity = [rarity]
        } else {
            scryfallRarity = scryfallCard.card_faces!.compactMap(\.rarity)
        }
        guard Set(scryfallRarity.map({$0.rawValue})).count == 1 else { fatalError("Faces have different rarities!") }
        guard let scryfallRarity = scryfallRarity.first else { fatalError("No rarity from scryfall.") }
        if scryfallRarity == .bonus {
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
            else if let rarity = self.rarity {
                let raritiesAgree = (rarity == .common && scryfallRarity == .common)
                || (rarity == .uncommon && scryfallRarity == .uncommon)
                || (rarity == .rare && scryfallRarity == .rare)
                || (rarity == .mythic && scryfallRarity == .mythic)
                || (rarity == .special && scryfallRarity == .special)
                if !raritiesAgree {
                    logger.notice("TCGPlayer and Scryfall disagree on rarity level for TCGPlayer card \(name!) (\(setCode) \(cardNumber))!")
                }
            }
            else {
                self.rarity = Rarity(scryfallRarity: scryfallRarity)
            }
        }
    }
    
    public mutating func fetchScryfallInfo() {
        let request = cardRequest(cardName: name, cardSet: setCode, cardNumber: cardNumber)
        let result: Result<ScryfallCard, RequestError> = synchronouslyRequest(request: request)
        switch result {
        case .failure(let error):
            logger.notice("Failed to get Scryfall info for TCGPlayer card \(String(describing: name)) (\(setCode) \(cardNumber)): \(error)")
        case .success(let scryfallCard):
            fixRarity(scryfallCard: scryfallCard)
            self.scryfallInfo = ScryfallInfo(scryfallCard: scryfallCard, fetchDate: Date())
        }
    }
}
