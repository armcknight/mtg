//
//  Decks+Analysis.swift
//  mtg
//
//  Created by Andrew McKnight on 9/19/24.
//

import Foundation
import scryfall

public func analyzeDeckComposition(cards: [CardQuantity]) -> DeckAnalysis {
    var analysis = DeckAnalysis()
    
    for cardQuantity in cards {
        var noType = true
        var noStrategy = true
        let card = cardQuantity.card
        let quantity = Int(cardQuantity.quantity)
        
        guard let cardName = card.name else {
            logger.notice("No card name.")
            continue
        }
        guard let oracleText = card.scryfallInfo?.oracleText else {
            logger.notice("No oracle text.")
            continue
        }
        guard let cardType = card.scryfallInfo?.typeLine.faceJoin else {
            logger.notice("No card type line.")
            continue
        }
        guard let edhrecRank = card.scryfallInfo?.edhrecRank else {
            logger.notice("No edhrec rank.")
            continue
        }
        guard let cmc = (card.scryfallInfo?.cmc.first as? NSDecimalNumber)?.doubleValue else {
            logger.notice("No converted mana cost.")
            continue
        }

        guard let colors = card.scryfallInfo?.colors else {
            logger.notice("No colors.")
            continue
        }
        logger.debug("cardName: \(cardName); edhrecRank: \(edhrecRank); cmc: \(cmc); colors: \(colors)")
        
        let colorSet = colors.reduce(into: Set<ScryfallColor>(), { partialResult, colors in
            colors.forEach { partialResult.insert($0) }
        })
        
        let cardInfo = DeckAnalysis.CardInfo(name: cardName, oracleText: oracleText.faceJoin, quantity: quantity, edhrecRank: edhrecRank, cmc: Int(ceil(cmc)), colors: colorSet)
        analysis.cards.insert(cardInfo)
        
        // MARK: analyze card types
        
        let isLand = cardType.contains("Land")
        if isLand {
            if cardType.contains("Basic") {
                analysis.manaProducing.basicLands.insert(cardInfo)
            } else {
                analysis.manaProducing.nonbasicLands.insert(cardInfo)
            }
            noType = false
            noStrategy = false
        }
        
        let isCreature = cardType.contains("Creature")
        if isCreature {
            // Add creature type analysis here
            if analysis.creatures[cardType] == nil {
                analysis.creatures[cardType] = Set<DeckAnalysis.CardInfo>([cardInfo])
            } else {
                analysis.creatures[cardType]?.insert(cardInfo)
            }
            noType = false
        }
        
        let isEnchantment = cardType.contains("Enchantment")
        if isEnchantment {
            analysis.enchantments.insert(cardInfo)
            noType = false
        }
        
        let isArtifact = cardType.contains("Artifact")
        if isArtifact {
            analysis.artifacts.insert(cardInfo)
            noType = false
        }
        
        let isEquipment = cardType.contains("Equipment")
        if isEquipment {
            analysis.equipment.insert(cardInfo)
            noType = false
        }
        
        let isBattle = cardType.contains("Battle")
        if isBattle {
            analysis.battles.insert(cardInfo)
            noType = false
        }
        
        let isPlaneswalker = cardType.contains("Planeswalker")
        if isPlaneswalker {
            analysis.planeswalkers.insert(cardInfo)
            noType = false
        }
        
        let isInstant = cardType.contains("Instant")
        if isInstant {
            analysis.instants.insert(cardInfo)
            noType = false
        }
        
        let isSorcery = cardType.contains("Sorcery")
        if isSorcery {
            analysis.sorceries.insert(cardInfo)
            noType = false
        }
        
        // MARK: analyze card strategies
        
        let oracleTextLowercased = oracleText.faceJoin.split(separator: ";").map({$0.lowercased()})
        
        let isNonLand = isCreature || isEnchantment || isArtifact || isEquipment || isBattle || isPlaneswalker || isInstant || isSorcery
        let isMDFCLand = !isLand || isNonLand // MDFC lands have a non-land type from the other side
        if isMDFCLand {
            if oracleTextLowercased |? ": add {" {
                analysis.manaProducing.triggeredAbilities.insert(cardInfo)
                noStrategy = false
            } else if oracleTextLowercased |? [/add {/, /add .* mana/] {
                analysis.manaProducing.staticAbilities.insert(cardInfo)
                noStrategy = false
            }
        }
        
        let linesWithRemovalKeywords = (oracleTextLowercased
            |> [/destroy/, /exile/, /gets? \-?\+?[0-9]*X?\/\-[0-9]*X?/, /opponent sacrifice/])
            ~> [/don't destroy/, /exile target player's/, /if .* would die, exile it instead/, /destroy .* land/]
        if linesWithRemovalKeywords |? "all" {
            analysis.interaction.boardWipes.insert(cardInfo)
            noStrategy = false
        } else if linesWithRemovalKeywords |? "target" {
            analysis.interaction.spotRemoval.insert(cardInfo)
            noStrategy = false
        }
        
        if ((oracleTextLowercased
            |> ["deal", "damage"])
            ~> [/don't destroy/, /whenever .* deals combat damage/, /prevent all combat damage/])
            |? ["creature", "planeswalker", "battle"] {
            analysis.interaction.spotRemoval.insert(cardInfo)
            noStrategy = false
        }
        
        if oracleTextLowercased |? /destroy .* land/ {
            analysis.interaction.landHate.insert(cardInfo)
            noStrategy = false
        }
        
        if oracleTextLowercased &? ["counter", "spell"] {
            analysis.interaction.control.insert(cardInfo)
            noStrategy = false
        }
        
        if oracleTextLowercased |? ["hexproof", "shroud", "protection", "prevent all combat damage"] {
            analysis.interaction.protection.insert(cardInfo)
            noStrategy = false
        }
        
        if oracleTextLowercased |? [/explore/, /gets? \+[0-9]*X?\/\+[0-9]*X?/, /\+[0-9]*X?\/\+[0-9]*X? counter/] {
            analysis.interaction.buff.insert(cardInfo)
            noStrategy = false
        }
        
        if isCreature && oracleTextLowercased |? ["flying", "fear", "shadow", "reach", "flanking", "horsemanship", "burrowing", "intimidate", "skulk", "daunt", "nimble", "menace", "trample", "protection", "islandwalk", "mountainwalk", "forestwalk", "plainswalk", "swampwalk", "can't be blocked"] {
            analysis.interaction.evasion.insert(cardInfo)
            noStrategy = false
        }
        
        if oracleTextLowercased
            |> "search your library"
            |? ["land", "wastes", "forest", "plains", "mountain", "swamp", "island"] {
            analysis.interaction.ramp.insert(cardInfo)
            analysis.interaction.tutors.insert(cardInfo)
            noStrategy = false
        }
        
        if oracleTextLowercased |? "search your library" {
            analysis.interaction.tutors.insert(cardInfo)
            noStrategy = false
        }
        
        if (oracleTextLowercased
            ~> /create .* treasure token/)
            |? [/create .* token/, /create .* copy/] {
            analysis.interaction.goWide.insert(cardInfo)
            noStrategy = false
        }
        
        if oracleTextLowercased |? /search .* library/ {
            analysis.interaction.tutors.insert(cardInfo)
            noStrategy = false
        }
        
        if oracleTextLowercased |? /deals? .* damage/ {
            analysis.interaction.burn.insert(cardInfo)
            noStrategy = false
        }
        
        if oracleTextLowercased |? ["scry", "surveil"] {
            analysis.interaction.libraryManipulation.insert(cardInfo)
            noStrategy = false
        }
        
        if oracleTextLowercased |? ["flashback", "encore", "persist"] {
            analysis.interaction.graveyardRecursion.insert(cardInfo)
            noStrategy = false
        }
        
        if oracleTextLowercased |? [/exile .* graveyard/, /graveyard .* exile/] {
            analysis.interaction.graveyardHate.insert(cardInfo)
            noStrategy = false
        }
        
        if oracleTextLowercased |? [/discover/, /explore/, /without paying its mana cost/, /create a treasure token/, /spells you cast cost .* less to cast/, /add one mana of any color/, /you may cast .* from the top of your library/, /put .* onto the battlefield/, /put the revealed cards into your hand/]
            || oracleTextLowercased &? ["land", "additional"] {
            analysis.interaction.ramp.insert(cardInfo)
            noStrategy = false
        }
        
        if oracleTextLowercased |? [/scry/, /surveil/, /discover/, /reveal .* cards from the top of your library/, /you may look at the top card of your library any time/, /look at the top .* cards of your library/] {
            analysis.interaction.libraryManipulation.insert(cardInfo)
            noStrategy = false
        }
        
        if oracleTextLowercased |? ["flashback", "from your graveyard"] {
            analysis.interaction.graveyardRecursion.insert(cardInfo)
            noStrategy = false
        }
        
        if oracleTextLowercased |? "draw" {
            analysis.interaction.cardDraw.insert(cardInfo)
            noStrategy = false
        }
        
        // collect cards that didn't meet any criteria
        if noType {
            analysis.uncategorizedType.insert(cardInfo)
        }
        if noStrategy {
            analysis.uncategorizedStrategy.insert(cardInfo)
        }
    }
    
    return analysis
}
