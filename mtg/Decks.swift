//
//  Decks.swift
//  mtg
//
//  Created by Andrew McKnight on 8/30/24.
//

import Foundation
import scryfall

extension Set where Element == DeckAnalysis.CardInfo {
    var totalSum: Int {
        reduce(0) { $0 + $1.quantity }
    }
}

extension Array where Element == DeckAnalysis.CardInfo {
    var totalSum: Int {
        reduce(0) { $0 + $1.quantity }
    }
}

public struct DeckAnalysis {
    public struct CardInfo: Hashable {
        public let name: String
        public let oracleText: String
        public let quantity: Int
        public let edhrecRank: Int
        public let colors: Set<ScryfallColor>
        public let pips: [ScryfallColor]
        public let isLand: Bool
        public let cmc: Int // scryfall stores these as decimals b/c some cards have fractional components (likely no tournament-legal ones, like unfinity) but we'll just take the integer value rounded up
        
        public init(name: String, oracleText: String, quantity: Int, edhrecRank: Int, cmc: Int, colors: Set<ScryfallColor>, isLand: Bool, pips: [ScryfallColor]) {
            self.name = name
            self.oracleText = oracleText
            self.quantity = quantity
            self.edhrecRank = edhrecRank
            self.cmc = cmc
            self.colors = colors
            self.isLand = isLand
            self.pips = pips
        }
    }
    
    public struct ManaProducing {
        public var triggeredAbilities: [String: Set<CardInfo>] = [:]
        public var staticAbilities: [String: Set<CardInfo>] = [:]
        
        public var totalSum: Int {
            basicLands.totalSum
            + nonbasicLands.totalSum
            + triggeredAbilities.totalSum
            + staticAbilities.totalSum
        }
         
        public func sections() -> [(String, Set<CardInfo>)] {
            [
                ("Basic Lands", basicLands),
                ("Nonbasic Lands", nonbasicLands),
                ("Triggered Abilities", triggeredAbilities),
                ("Static Abilities", staticAbilities),
            ]
        }
    }

    // TODO: repeatable vs one-time (etb/ltb, tap, sac, "once per turn"?) effects
    public struct Interaction {
        public var spotRemoval = Set<CardInfo>()
        public var boardWipes = Set<CardInfo>()
        public var landHate = Set<CardInfo>()
        public var control = Set<CardInfo>()
        public var buff = Set<CardInfo>()
        public var evasion = Set<CardInfo>()
        public var ramp = Set<CardInfo>()
        public var cardDraw = Set<CardInfo>()
        public var groupHug = Set<CardInfo>() // TODO: implement
        public var goWide = Set<CardInfo>()
        public var tutors = Set<CardInfo>()
        public var burn = Set<CardInfo>()
        public var protection = Set<CardInfo>()
        public var libraryManipulation = Set<CardInfo>() // TODO: sylvan library, scroll rack
        public var graveyardRecursion = Set<CardInfo>() // TODO: virtue of persistence
        public var graveyardHate = Set<CardInfo>() // TODO: bojuka bog, leyline of the void
        public var sacrificeOutlet = Set<CardInfo>() // TODO: implement
        public var colorFixing = Set<CardInfo>() // TODO: multicolored lands
        public var landFetch = Set<CardInfo>()
        public var storm = Set<CardInfo>() // TODO: storm, suspend, morph, disguise, manifest, cascade, discover, cloak, plot; mana-positive spells like pyretic ritual, dark ritual, cabal ritual
        public var poisonInfect = Set<CardInfo>()
        public var affinity = Set<CardInfo>()
        public var costReduction = Set<CardInfo>()
        public var forcedDiscard = Set<CardInfo>()
        
        public var uncategorizedStrategy = Set<CardInfo>()
        
        public var totalSum: Int {
            spotRemoval.totalSum
            + boardWipes.totalSum
            + landHate.totalSum 
            + control.totalSum 
            + buff.totalSum 
            + evasion.totalSum 
            + ramp.totalSum 
            + cardDraw.totalSum 
            + groupHug.totalSum 
            + goWide.totalSum 
            + tutors.totalSum 
            + burn.totalSum 
            + protection.totalSum 
            + libraryManipulation.totalSum 
            + graveyardRecursion.totalSum 
            + graveyardHate.totalSum 
            + sacrificeOutlet.totalSum 
            + colorFixing.totalSum 
            + landFetch.totalSum 
            + storm.totalSum
            + poisonInfect.totalSum
            + affinity.totalSum
            + costReduction.totalSum
            + forcedDiscard.totalSum
        }
        
        public func sections() -> [(String, Set<CardInfo>)] {
            [
                ("Spot Removal", spotRemoval),
                ("Board Wipes", boardWipes),
                ("Land Hate", landHate),
                ("Control", control),
                ("Buff", buff),
                ("Evasion", evasion),
                ("Ramp", ramp),
                ("Card Draw", cardDraw),
                ("Group Hug", groupHug),
                ("Go Wide", goWide),
                ("Tutors", tutors),
                ("Burn", burn),
                ("Protection", protection),
                ("Library Manipulation", libraryManipulation),
                ("Graveyard Recursion", graveyardRecursion),
                ("Graveyard Hate", graveyardHate),
                ("Sacrifice Outlet", sacrificeOutlet),
                ("Color Fixing", colorFixing),
                ("Land Fetch", landFetch),
                ("Storm", storm),
                ("Poison", poisonInfect),
                ("Affinity", affinity),
                ("Cost Reduction", costReduction),
                ("Forced Discard", forcedDiscard),
            ]
        }
    }
    
    // card strategy information
    public var manaProducing = ManaProducing()
    public var interaction = Interaction()
    
    // card type information
    public var creatures: [String: Set<CardInfo>] = [:]
    public var enchantments = Set<CardInfo>()
    public var artifacts = Set<CardInfo>()
    public var equipment = Set<CardInfo>()
    public var battles = Set<CardInfo>()
    public var planeswalkers = Set<CardInfo>()
    public var instants = Set<CardInfo>()
    public var sorceries = Set<CardInfo>()
    
    public var uncategorizedType = Set<CardInfo>()
    
    public var cards = Set<CardInfo>()
    
    public init() {}
}
