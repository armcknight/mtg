//
//  Decks.swift
//  mtg
//
//  Created by Andrew McKnight on 8/30/24.
//

import Foundation

extension Array where Element == DeckAnalysis.CardInfo {
    var description: String {
        map(\.description).joined(separator: "\n")
    }
    
    var sortedByEDHRECRank: [Element] {
        sorted(by: { $0.edhrecRank < $1.edhrecRank })
    }
    
    var sortedDescription: String {
        sortedByEDHRECRank.map(\.description).joined(separator: "\n")
    }
    
    var totalSum: Int {
        reduce(0) { $0 + $1.quantity }
    }
}

public struct DeckAnalysis: CustomStringConvertible {
    public struct CardInfo: CustomStringConvertible {
        public let name: String
        public let oracleText: String
        public let quantity: Int
        public let edhrecRank: Int
        
        public init(name: String, oracleText: String, quantity: Int, edhrecRank: Int) {
            self.name = name
            self.oracleText = oracleText
            self.quantity = quantity
            self.edhrecRank = edhrecRank
        }
        
        public var description: String {
            return "\t\t\(quantity)x \(name): \(oracleText) (EDHREC \(edhrecRank))"
        }
        
        public var htmlDescription: String {
            return "<li>\(quantity)x \(name): \(oracleText) (EDHREC \(edhrecRank))</li>"
        }
    }
    
    public struct ManaProducing: CustomStringConvertible {
        public var basicLands = [CardInfo]()
        public var nonbasicLands = [CardInfo]()
        public var triggeredAbilities = [CardInfo]()
        public var staticAbilities = [CardInfo]()
        
        public var description: String {
            var components = [String]()
            var emptyCategories = [String]()
            
            if !basicLands.isEmpty {
                components.append(contentsOf: [
                    "\tBasic Lands (\(basicLands.totalSum))",
                    "\t-----------",
                    basicLands.description
                ])
            } else {
                emptyCategories.append("Basic Lands")
            }
            
            if !nonbasicLands.isEmpty {
                components.append(contentsOf: [
                    "\tNonbasic Lands (\(nonbasicLands.totalSum))",
                    "\t--------------",
                    nonbasicLands.sortedDescription
                ])
            } else {
                emptyCategories.append("Nonbasic Lands")
            }
            
            if !triggeredAbilities.isEmpty {
                components.append(contentsOf: [
                    "\tTriggered Abilities (\(triggeredAbilities.totalSum))",
                    "\t-------------------",
                    triggeredAbilities.sortedDescription
                ])
            } else {
                emptyCategories.append("Triggered Abilities")
            }
            
            if !staticAbilities.isEmpty {
                components.append(contentsOf: [
                    "\tStatic Abilities (\(staticAbilities.totalSum))",
                    "\t----------------",
                    staticAbilities.sortedDescription
                ])
            } else {
                emptyCategories.append("Static Abilities")
            }
            
            if !emptyCategories.isEmpty {
                components.append("\tEmpty Mana Producing Categories: \(emptyCategories.joined(separator: ", "))")
            }
            
            return components.joined(separator: "\n")
        }
        
        public var totalSum: Int {
            basicLands.totalSum + nonbasicLands.totalSum + triggeredAbilities.totalSum + staticAbilities.totalSum
        }
        
        public func htmlDescription() -> String {
            var html = "<h3>Mana Production (\(totalSum))</h3>"
            html += "<ul>"
            
            if !basicLands.isEmpty {
                html += "<li><input type='checkbox' id='basicLands'><label for='basicLands'>Basic Lands (\(basicLands.totalSum))</label><ul>"
                html += basicLands.map { $0.htmlDescription }.joined()
                html += "</ul></li>"
            }
            
            if !nonbasicLands.isEmpty {
                html += "<li><input type='checkbox' id='nonbasicLands'><label for='nonbasicLands'>Nonbasic Lands (\(nonbasicLands.totalSum))</label><ul>"
                html += nonbasicLands.sortedByEDHRECRank.map { $0.htmlDescription }.joined()
                html += "</ul></li>"
            }
            
            if !triggeredAbilities.isEmpty {
                html += "<li><input type='checkbox' id='triggeredAbilities'><label for='triggeredAbilities'>Triggered Abilities (\(triggeredAbilities.totalSum))</label><ul>"
                html += triggeredAbilities.sortedByEDHRECRank.map { $0.htmlDescription }.joined()
                html += "</ul></li>"
            }
            
            if !staticAbilities.isEmpty {
                html += "<li><input type='checkbox' id='staticAbilities'><label for='staticAbilities'>Static Abilities (\(staticAbilities.totalSum))</label><ul>"
                html += staticAbilities.sortedByEDHRECRank.map { $0.htmlDescription }.joined()
                html += "</ul></li>"
            }
            
            html += "</ul>"
            return html
        }
    }
    
    public struct Interaction: CustomStringConvertible {
        public var spotRemoval = [CardInfo]()
        public var boardwipes = [CardInfo]()
        public var landHate = [CardInfo]()
        public var grouphug = [CardInfo]()
        public var control = [CardInfo]()
        public var buff = [CardInfo]()
        public var evasion = [CardInfo]()
        public var ramp = [CardInfo]()
        public var gowide = [CardInfo]()
        
        public var description: String {
            var components = [String]()
            var emptyCategories = [String]()
            
            if !spotRemoval.isEmpty {
                components.append(contentsOf: [
                    "\tSpot Removal (\(spotRemoval.totalSum))",
                    "\t-------------",
                    spotRemoval.sortedDescription
                ])
            } else {
                emptyCategories.append("Spot Removal")
            }
            
            if !boardwipes.isEmpty {
                components.append(contentsOf: [
                    "\tBoardwipes (\(boardwipes.totalSum))",
                    "\t----------",
                    boardwipes.sortedDescription
                ])
            } else {
                emptyCategories.append("Boardwipes")
            }
            
            if !landHate.isEmpty {
                components.append(contentsOf: [
                    "\tLand Hate (\(landHate.totalSum))",
                    "\t----------",
                    landHate.sortedDescription
                ])
            } else {
                emptyCategories.append("Land Hate")
            }
            
            if !grouphug.isEmpty {
                components.append(contentsOf: [
                    "\tGroup Hug (\(grouphug.totalSum))",
                    "\t----------",
                    grouphug.sortedDescription
                ])
            } else {
                emptyCategories.append("Group Hug")
            }
            
            if !control.isEmpty {
                components.append(contentsOf: [
                    "\tControl (\(control.totalSum))",
                    "\t---------",
                    control.sortedDescription
                ])
            } else {
                emptyCategories.append("Control")
            }
            
            if !buff.isEmpty {
                components.append(contentsOf: [
                    "\tBuff (\(buff.totalSum))",
                    "\t-------",
                    buff.sortedDescription
                ])
            } else {
                emptyCategories.append("Buff")
            }
            
            if !evasion.isEmpty {
                components.append(contentsOf: [
                    "\tEvasion (\(evasion.totalSum))",
                    "\t--------",
                    evasion.sortedDescription
                ])
            } else {
                emptyCategories.append("Evasion")
            }
            
            if !ramp.isEmpty {
                components.append(contentsOf: [
                    "\tRamp (\(ramp.totalSum))",
                    "\t-----",
                    ramp.sortedDescription
                ])
            } else {
                emptyCategories.append("Ramp")
            }
            
            if !gowide.isEmpty {
                components.append(contentsOf: [
                    "\tGo Wide (\(gowide.totalSum))",
                    "\t-------",
                    gowide.sortedDescription
                ])
            } else {
                emptyCategories.append("Go Wide")
            }
            
            if !emptyCategories.isEmpty {
                components.append("\tEmpty Interaction Categories: \(emptyCategories.joined(separator: ", "))")
            }
            
            return components.joined(separator: "\n")
        }
        
        public var totalSum: Int {
            spotRemoval.totalSum + boardwipes.totalSum + landHate.totalSum + grouphug.totalSum + control.totalSum + buff.totalSum + evasion.totalSum + ramp.totalSum + gowide.totalSum
        }
        
        public func htmlDescription() -> String {
            var html = "<h3>Interaction (\(totalSum))</h3>"
            html += "<ul>"
            
            if !spotRemoval.isEmpty {
                html += "<li><input type='checkbox' id='spotRemoval'><label for='spotRemoval'>Spot Removal (\(spotRemoval.totalSum))</label><ul>"
                html += spotRemoval.sortedByEDHRECRank.map { $0.htmlDescription }.joined()
                html += "</ul></li>"
            }
            
            if !boardwipes.isEmpty {
                html += "<li><input type='checkbox' id='boardwipes'><label for='boardwipes'>Boardwipes (\(boardwipes.totalSum))</label><ul>"
                html += boardwipes.sortedByEDHRECRank.map { $0.htmlDescription }.joined()
                html += "</ul></li>"
            }
            
            if !landHate.isEmpty {
                html += "<li><input type='checkbox' id='landHate'><label for='landHate'>Land Hate (\(landHate.totalSum))</label><ul>"
                html += landHate.sortedByEDHRECRank.map { $0.htmlDescription }.joined()
                html += "</ul></li>"
            }
            
            if !grouphug.isEmpty {
                html += "<li><input type='checkbox' id='grouphug'><label for='grouphug'>Group Hug (\(grouphug.totalSum))</label><ul>"
                html += grouphug.sortedByEDHRECRank.map { $0.htmlDescription }.joined()
                html += "</ul></li>"
            }
            
            if !control.isEmpty {
                html += "<li><input type='checkbox' id='control'><label for='control'>Control (\(control.totalSum))</label><ul>"
                html += control.sortedByEDHRECRank.map { $0.htmlDescription }.joined()
                html += "</ul></li>"
            }
            
            if !buff.isEmpty {
                html += "<li><input type='checkbox' id='buff'><label for='buff'>Buff (\(buff.totalSum))</label><ul>"
                html += buff.sortedByEDHRECRank.map { $0.htmlDescription }.joined()
                html += "</ul></li>"
            }
            
            if !evasion.isEmpty {
                html += "<li><input type='checkbox' id='evasion'><label for='evasion'>Evasion (\(evasion.totalSum))</label><ul>"
                html += evasion.sortedByEDHRECRank.map { $0.htmlDescription }.joined()
                html += "</ul></li>"
            }
            
            if !ramp.isEmpty {
                html += "<li><input type='checkbox' id='ramp'><label for='ramp'>Ramp (\(ramp.totalSum))</label><ul>"
                html += ramp.sortedByEDHRECRank.map { $0.htmlDescription }.joined()
                html += "</ul></li>"
            }
            
            if !gowide.isEmpty {
                html += "<li><input type='checkbox' id='gowide'><label for='gowide'>Go Wide (\(gowide.totalSum))</label><ul>"
                html += gowide.sortedByEDHRECRank.map { $0.htmlDescription }.joined()
                html += "</ul></li>"
            }
            
            html += "</ul>"
            return html
        }
    }
    
    public var manaProducing = ManaProducing()
    public var creatures: [String: [CardInfo]] = [:]
    public var enchantments = [CardInfo]()
    public var artifacts = [CardInfo]()
    public var equipment = [CardInfo]()
    public var battles = [CardInfo]()
    public var planeswalkers = [CardInfo]()
    public var interaction = Interaction()
    public var uncategorized = [CardInfo]()
    
    public init() {}
    
    public var description: String {
        var components = [String]()
        var emptyCategories = [String]()
        
        if !manaProducing.basicLands.isEmpty || !manaProducing.nonbasicLands.isEmpty || !manaProducing.triggeredAbilities.isEmpty || !manaProducing.staticAbilities.isEmpty {
            components.append("Mana Production (\(manaProducing.totalSum))")
            components.append("----------------")
            components.append(manaProducing.description)
        } else {
            emptyCategories.append("Mana Production")
        }
        
        if !creatures.isEmpty {
            let totalCreatures = creatures.values.flatMap { $0 }.totalSum
            components.append("Creatures (\(totalCreatures))")
            components.append("---------")
            components.append(contentsOf: creatures.map { "\($0.key): \($0.value.sortedDescription)" })
        } else {
            emptyCategories.append("Creatures")
        }
        
        if !enchantments.isEmpty {
            components.append("Enchantments (\(enchantments.totalSum))")
            components.append("-------------")
            components.append(enchantments.sortedDescription)
        } else {
            emptyCategories.append("Enchantments")
        }
        
        if !artifacts.isEmpty {
            components.append("Artifacts (\(artifacts.totalSum))")
            components.append("---------")
            components.append(artifacts.sortedDescription)
        } else {
            emptyCategories.append("Artifacts")
        }
        
        if !equipment.isEmpty {
            components.append("Equipment (\(equipment.totalSum))")
            components.append("----------")
            components.append(equipment.sortedDescription)
        } else {
            emptyCategories.append("Equipment")
        }
        
        if !battles.isEmpty {
            components.append("Battles (\(battles.totalSum))")
            components.append("-------")
            components.append(battles.sortedDescription)
        } else {
            emptyCategories.append("Battles")
        }
        
        if !planeswalkers.isEmpty {
            components.append("Planeswalkers (\(planeswalkers.totalSum))")
            components.append("-------------")
            components.append(planeswalkers.sortedDescription)
        } else {
            emptyCategories.append("Planeswalkers")
        }
        
        if !interaction.spotRemoval.isEmpty || !interaction.boardwipes.isEmpty || !interaction.landHate.isEmpty || !interaction.grouphug.isEmpty || !interaction.control.isEmpty || !interaction.buff.isEmpty || !interaction.evasion.isEmpty || !interaction.ramp.isEmpty || !interaction.gowide.isEmpty {
            components.append("Interaction (\(interaction.totalSum))")
            components.append("-----------")
            components.append(interaction.description)
        } else {
            emptyCategories.append("Interaction")
        }
        if !uncategorized.isEmpty {
            components.append("Uncategorized (\(uncategorized.totalSum))")
            components.append("-------------")
            components.append(uncategorized.sortedDescription)
        } else {
            emptyCategories.append("Uncategorized")
        }
        
        if !emptyCategories.isEmpty {
            components.append("\nCategories with no entries:")
            components.append("----------------------------")
            components.append(emptyCategories.joined(separator: "\n"))
        }
        
        return components.joined(separator: "\n")
    }
    
    public func generateHTMLReport() -> String {
        var html = """
        <!DOCTYPE html>
        <html>
        <head>
        <title>Deck Analysis</title>
        <style>
            body { font-family: Arial, sans-serif; }
            h2, h3 { margin: 20px 0 10px; }
            ul { list-style-type: none; padding-left: 20px; }
            label { cursor: pointer; }
            input[type=checkbox] { display: none; }
            input[type=checkbox] + ul { display: none; }
            input[type=checkbox]:checked + ul { display: block; }
            input[type=checkbox]:checked + label:before { content: "\\25BC "; } /* ▼ */
            input[type=checkbox] + label:before { content: "\\25B6 "; } /* ► */
        </style>
        </head>
        <body>
        <h2>Deck Composition Analysis</h2>
        """
        
        if !manaProducing.basicLands.isEmpty || !manaProducing.nonbasicLands.isEmpty || !manaProducing.triggeredAbilities.isEmpty || !manaProducing.staticAbilities.isEmpty {
            html += manaProducing.htmlDescription()
        }
        
        if !creatures.isEmpty {
            let totalCreatures = creatures.values.flatMap { $0 }.totalSum
            html += "<h3>Creatures (\(totalCreatures))</h3><ul>"
            for (creatureType, creatureList) in creatures {
                html += "<li><input type='checkbox' id='\(creatureType)'><label for='\(creatureType)'>\(creatureType) (\(creatureList.totalSum))</label><ul>"
                html += creatureList.sortedByEDHRECRank.map { $0.htmlDescription }.joined()
                html += "</ul></li>"
            }
            html += "</ul>"
        }
        if !enchantments.isEmpty {
            html += "<h3>Enchantments (\(enchantments.totalSum))</h3><ul>"
            html += enchantments.sortedByEDHRECRank.map { $0.htmlDescription }.joined()
            html += "</ul>"
        }
        
        if !artifacts.isEmpty {
            html += "<h3>Artifacts (\(artifacts.totalSum))</h3><ul>"
            html += artifacts.sortedByEDHRECRank.map { $0.htmlDescription }.joined()
            html += "</ul>"
        }
        
        if !equipment.isEmpty {
            html += "<h3>Equipment (\(equipment.totalSum))</h3><ul>"
            html += equipment.sortedByEDHRECRank.map { $0.htmlDescription }.joined()
            html += "</ul>"
        }
        
        if !battles.isEmpty {
            html += "<h3>Battles (\(battles.totalSum))</h3><ul>"
            html += battles.sortedByEDHRECRank.map { $0.htmlDescription }.joined()
            html += "</ul>"
        }
        
        if !planeswalkers.isEmpty {
            html += "<h3>Planeswalkers (\(planeswalkers.totalSum))</h3><ul>"
            html += planeswalkers.sortedByEDHRECRank.map { $0.htmlDescription }.joined()
            html += "</ul>"
        }
        
        if !interaction.spotRemoval.isEmpty || !interaction.boardwipes.isEmpty || !interaction.landHate.isEmpty || !interaction.grouphug.isEmpty || !interaction.control.isEmpty || !interaction.buff.isEmpty || !interaction.evasion.isEmpty || !interaction.ramp.isEmpty || !interaction.gowide.isEmpty {
            html += interaction.htmlDescription()
        }
        
        if !uncategorized.isEmpty {
            html += "<h3>Uncategorized (\(uncategorized.totalSum))</h3><ul>"
            html += uncategorized.sortedByEDHRECRank.map { $0.htmlDescription }.joined()
            html += "</ul>"
        }
        
        html += """
        </body>
        </html>
        """
        
        return html.replacingOccurrences(of: "—", with: "-")
    }
}
