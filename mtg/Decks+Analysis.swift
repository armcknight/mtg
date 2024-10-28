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
        let isMDFCLand = oracleText.count > 1 && (!isLand || isNonLand) // MDFC lands can have a non-land type from the other side
        let nonTriggeredAbility = ["add {", "add .* mana"].regexes
        if isMDFCLand {
            if oracleTextLowercased |? ": add {" {
                analysis.manaProducing.triggeredAbilities.insert(cardInfo)
                noStrategy = false
            } else if oracleTextLowercased |? nonTriggeredAbility {
                analysis.manaProducing.staticAbilities.insert(cardInfo)
                noStrategy = false
            }
        } else if oracleTextLowercased |? nonTriggeredAbility {
            analysis.manaProducing.other.insert(cardInfo)
            noStrategy = false
        }
        
        let linesWithRemovalKeywords = (oracleTextLowercased
            |> ["destroy", "exile", #"gets? \-?\+?[0-9x]?\/\-[0-9x]?"#, "opponent sacrifice"].regexes)
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
            ~> [/don't destroy/, /whenever .* deals combat damage/, /prevent all combat damage/, /toxic/, /infect/])
            |? ["creature", "planeswalker", "battle"] {
            analysis.interaction.spotRemoval.insert(cardInfo)
            noStrategy = false
        }
        
        if oracleTextLowercased |? ["destroy .* land", "land .* destroy", "land .* instead", "lands? do.*n.?t untap"].regexes {
            analysis.interaction.landHate.insert(cardInfo)
            noStrategy = false
        }
        
        if oracleTextLowercased |? ["counter target .* spell", "player .* discard"] {
            analysis.interaction.control.insert(cardInfo)
            noStrategy = false
        }
        
        if oracleTextLowercased |? ["hexproof", "shroud", "protection", "indestructible", "ward", "prevent all combat damage"] {
            analysis.interaction.protection.insert(cardInfo)
            noStrategy = false
        }
        
        if oracleTextLowercased |? ["explore", #"\+[0-9x]*\/\+[0-9x]*"#, #"\-[0-9x]*\/\+[0-9x]*"#, #"\+[0-9x]*\/\-[0-9x]*"#, "proliferate"] {
            analysis.interaction.buff.insert(cardInfo)
            noStrategy = false
        }
        
        if oracleTextLowercased |? ["indestructible", "flying", "fear", "shadow", "reach", "flanking", "horsemanship", "burrowing", "intimidate", "skulk", "daunt", "nimble", "menace", "trample", "protection", "islandwalk", "mountainwalk", "forestwalk", "plainswalk", "swampwalk", "landwalk", "can't be blocked"] {
            analysis.interaction.evasion.insert(cardInfo)
            noStrategy = false
        }
        
        if oracleTextLowercased |? ["poison", "toxic", "infect"] {
            analysis.interaction.poisonInfect.insert(cardInfo)
            noStrategy = false
        }
        
        let fetchesLand = oracleTextLowercased |? ["search.*library.*land", "search.*library.*gate"]
            || oracleTextLowercased
                |> "search your library"
                |? ["land", "wastes", "forest", "plains", "mountain", "swamp", "island"]
        if fetchesLand {
            analysis.interaction.landFetch.insert(cardInfo)
            noStrategy = false
        }
        
        let dorkOrRock = !isLand && oracleTextLowercased |? /add \{/
        
        if fetchesLand
            || oracleTextLowercased |? ["discover", "cascade", "explore", "without paying its mana cost", "create .* treasure token", "add .* mana", "you may cast .* from the top of your library", "compleated", "evoke", "affinity", "costs?.*less", "convoke", "additional.*land"].regexes
            || dorkOrRock {
            analysis.interaction.ramp.insert(cardInfo)
            noStrategy = false
        }
        
        if (oracleTextLowercased
            ~> [/create .* treasure token/, /create .* clue token/, /create .* blood token/, /create .* food token/])
            |? ["create .* token", "create .* copy"].regexes {
            analysis.interaction.goWide.insert(cardInfo)
            noStrategy = false
        }
        
        if (oracleTextLowercased ~> "land") |? "search .* library" {
            analysis.interaction.tutors.insert(cardInfo)
            noStrategy = false
        }
        
        if oracleTextLowercased |? /deals? .* damage/ {
            analysis.interaction.burn.insert(cardInfo)
            noStrategy = false
        }
        
        if oracleTextLowercased |? ["scry", "surveil", "put the revealed cards into your hand"] {
            analysis.interaction.libraryManipulation.insert(cardInfo)
            noStrategy = false
        }
        
        if oracleTextLowercased |? ["flashback", "encore", "persist", "delve", "collect evidence", "from your graveyard", "put .* from .* graveyard onto the battlefield", "when this creature dies, return it to the battlefield"].regexes {
            analysis.interaction.graveyardRecursion.insert(cardInfo)
            noStrategy = false
        }
        
        if (oracleTextLowercased ~> /exile .* from your graveyard/) |? ["exile .* graveyard", "graveyard .* exile"].regexes {
            analysis.interaction.graveyardHate.insert(cardInfo)
            noStrategy = false
        }
        
        if oracleTextLowercased |? ["create .* clue", "create .* food", "create .* blood", "create .* treasure", "it's an artifact", "create .* artifact", "treat .* as an artifact", "is an artifact .* in addition", "for each artifact"].regexes {
            analysis.interaction.affinity.insert(cardInfo)
            noStrategy = false
        }
        
        func producing(_ colors: String) -> String {
            var colors = [String]()
            for c in colors {
                colors.append("\\{\(c)\\}")
            }
            return ": add " + colors.joined(separator: ".*")
        }
        if oracleTextLowercased |? [
            "mana of any color",
            "mana .* combination of colors",
            "search .* library .* land",
            "search .* library .* gate",
            // 2 colors
            producing("WU"), producing("WB"), producing("WR"), producing("WG"),
            producing("UB"), producing("UR"), producing("UG"),
            producing("BR"), producing("BG"),
            producing("RG"),
            // 3 colors; starting with white
            producing("WUB"), producing("WUR"), producing("WUG"),
            producing("WBR"), producing("WBG"),
            producing("WRG"),
            // starting with blue
            producing("UBR"), producing("UBG"),
            producing("URG"),
            // starting with black
            producing("BBG"),
            // 4 colors
            producing("WUBR"), producing("WUBG"), producing("WURG"), producing("WBRG"), producing("UBRG"),
            // 5 colors
            producing("WUBRG"),
        ].regexes {
            analysis.interaction.colorFixing.insert(cardInfo)
            noStrategy = false
        }
        
        if oracleTextLowercased |? ["scry", "surveil", "discover", "reveal .* cards from the top of your library", "you may look at the top card of your library any time", "look at the top .* cards of your library"].regexes {
            analysis.interaction.libraryManipulation.insert(cardInfo)
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
            analysis.interaction.uncategorizedStrategy.insert(cardInfo)
        }
    }
    
    return analysis
}
