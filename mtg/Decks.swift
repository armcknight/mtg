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
            var html = "<ul>"
            
            if !basicLands.isEmpty {
                html += "<li><h4 onclick=\"toggleSection(this)\">Basic Lands (\(basicLands.totalSum))</h4><div class=\"section\"><ul>"
                html += basicLands.map { $0.htmlDescription }.joined()
                html += "</ul></div></li>"
            }
            
            if !nonbasicLands.isEmpty {
                html += "<li><h4 onclick=\"toggleSection(this)\">Nonbasic Lands (\(nonbasicLands.totalSum))</h4><div class=\"section\"><ul>"
                html += nonbasicLands.sortedByEDHRECRank.map { $0.htmlDescription }.joined()
                html += "</ul></div></li>"
            }
            
            if !triggeredAbilities.isEmpty {
                html += "<li><h4 onclick=\"toggleSection(this)\">Triggered Abilities (\(triggeredAbilities.totalSum))</h4><div class=\"section\"><ul>"
                html += triggeredAbilities.sortedByEDHRECRank.map { $0.htmlDescription }.joined()
                html += "</ul></div></li>"
            }
            
            if !staticAbilities.isEmpty {
                html += "<li><h4 onclick=\"toggleSection(this)\">Static Abilities (\(staticAbilities.totalSum))</h4><div class=\"section\"><ul>"
                html += staticAbilities.sortedByEDHRECRank.map { $0.htmlDescription }.joined()
                html += "</ul></div></li>"
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
            var html = "<ul>"
            
            if !spotRemoval.isEmpty {
                html += "<li><h4 onclick=\"toggleSection(this)\">Spot Removal (\(spotRemoval.totalSum))</h4><div class=\"section\"><ul>"
                html += spotRemoval.sortedByEDHRECRank.map { $0.htmlDescription }.joined()
                html += "</ul></div></li>"
            }
            
            if !boardwipes.isEmpty {
                html += "<li><h4 onclick=\"toggleSection(this)\">Boardwipes (\(boardwipes.totalSum))</h4><div class=\"section\"><ul>"
                html += boardwipes.sortedByEDHRECRank.map { $0.htmlDescription }.joined()
                html += "</ul></div></li>"
            }
            
            if !landHate.isEmpty {
                html += "<li><h4 onclick=\"toggleSection(this)\">Land Hate (\(landHate.totalSum))</h4><div class=\"section\"><ul>"
                html += landHate.sortedByEDHRECRank.map { $0.htmlDescription }.joined()
                html += "</ul></div></li>"
            }
            
            if !grouphug.isEmpty {
                html += "<li><h4 onclick=\"toggleSection(this)\">Group Hug (\(grouphug.totalSum))</h4><div class=\"section\"><ul>"
                html += grouphug.sortedByEDHRECRank.map { $0.htmlDescription }.joined()
                html += "</ul></div></li>"
            }
            
            if !control.isEmpty {
                html += "<li><h4 onclick=\"toggleSection(this)\">Control (\(control.totalSum))</h4><div class=\"section\"><ul>"
                html += control.sortedByEDHRECRank.map { $0.htmlDescription }.joined()
                html += "</ul></div></li>"
            }
            
            if !buff.isEmpty {
                html += "<li><h4 onclick=\"toggleSection(this)\">Buff (\(buff.totalSum))</h4><div class=\"section\"><ul>"
                html += buff.sortedByEDHRECRank.map { $0.htmlDescription }.joined()
                html += "</ul></div></li>"
            }
            
            if !evasion.isEmpty {
                html += "<li><h4 onclick=\"toggleSection(this)\">Evasion (\(evasion.totalSum))</h4><div class=\"section\"><ul>"
                html += evasion.sortedByEDHRECRank.map { $0.htmlDescription }.joined()
                html += "</ul></div></li>"
            }
            
            if !ramp.isEmpty {
                html += "<li><h4 onclick=\"toggleSection(this)\">Ramp (\(ramp.totalSum))</h4><div class=\"section\"><ul>"
                html += ramp.sortedByEDHRECRank.map { $0.htmlDescription }.joined()
                html += "</ul></div></li>"
            }
            
            if !gowide.isEmpty {
                html += "<li><h4 onclick=\"toggleSection(this)\">Go Wide (\(gowide.totalSum))</h4><div class=\"section\"><ul>"
                html += gowide.sortedByEDHRECRank.map { $0.htmlDescription }.joined()
                html += "</ul></div></li>"
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
        h2, h3, h4 { margin: 20px 0 10px; cursor: pointer; }
        h3:before, h4:before { content: "\\25BC "; } /* ▼ */
        h3.collapsed:before, h4.collapsed:before { content: "\\25B6 "; } /* ► */
        ul { list-style-type: none; padding-left: 20px; }
        .section { display: block; }
        .collapsed + .section { display: none; }
    </style>
    <script>
        function toggleSection(header) {
            header.classList.toggle('collapsed');
            header.nextElementSibling.style.display = header.classList.contains('collapsed') ? 'none' : 'block';
        }
    </script>
    </head>
    <body>
    <h2 onclick="toggleSection(this)">Deck Composition Analysis</h2>
    <div class="section">
    """
        
        if !manaProducing.basicLands.isEmpty || !manaProducing.nonbasicLands.isEmpty || !manaProducing.triggeredAbilities.isEmpty || !manaProducing.staticAbilities.isEmpty {
            html += "<h3 onclick=\"toggleSection(this)\">Mana Production (\(manaProducing.totalSum))</h3><div class=\"section\">"
            html += manaProducing.htmlDescription()
            html += "</div>"
        }
        
        if !creatures.isEmpty {
            let totalCreatures = creatures.values.flatMap { $0 }.totalSum
            html += "<h3 onclick=\"toggleSection(this)\">Creatures (\(totalCreatures))</h3><div class=\"section\"><ul>"
            for (creatureType, creatureList) in creatures {
                html += "<li><h4 onclick=\"toggleSection(this)\">\(creatureType) (\(creatureList.totalSum))</h4><div class=\"section\"><ul>"
                html += creatureList.sortedByEDHRECRank.map { $0.htmlDescription }.joined()
                html += "</ul></div></li>"
            }
            html += "</ul></div>"
        }
        
        if !enchantments.isEmpty {
            html += "<h3 onclick=\"toggleSection(this)\">Enchantments (\(enchantments.totalSum))</h3><div class=\"section\"><ul>"
            html += enchantments.sortedByEDHRECRank.map { $0.htmlDescription }.joined()
            html += "</ul></div>"
        }
        
        if !artifacts.isEmpty {
            html += "<h3 onclick=\"toggleSection(this)\">Artifacts (\(artifacts.totalSum))</h3><div class=\"section\"><ul>"
            html += artifacts.sortedByEDHRECRank.map { $0.htmlDescription }.joined()
            html += "</ul></div>"
        }
        
        if !equipment.isEmpty {
            html += "<h3 onclick=\"toggleSection(this)\">Equipment (\(equipment.totalSum))</h3><div class=\"section\"><ul>"
            html += equipment.sortedByEDHRECRank.map { $0.htmlDescription }.joined()
            html += "</ul></div>"
        }
        
        if !battles.isEmpty {
            html += "<h3 onclick=\"toggleSection(this)\">Battles (\(battles.totalSum))</h3><div class=\"section\"><ul>"
            html += battles.sortedByEDHRECRank.map { $0.htmlDescription }.joined()
            html += "</ul></div>"
        }
        
        if !planeswalkers.isEmpty {
            html += "<h3 onclick=\"toggleSection(this)\">Planeswalkers (\(planeswalkers.totalSum))</h3><div class=\"section\"><ul>"
            html += planeswalkers.sortedByEDHRECRank.map { $0.htmlDescription }.joined()
            html += "</ul></div>"
        }
        
        if !interaction.spotRemoval.isEmpty || !interaction.boardwipes.isEmpty || !interaction.landHate.isEmpty || !interaction.grouphug.isEmpty || !interaction.control.isEmpty || !interaction.buff.isEmpty || !interaction.evasion.isEmpty || !interaction.ramp.isEmpty || !interaction.gowide.isEmpty {
            html += "<h3 onclick=\"toggleSection(this)\">Interaction (\(interaction.totalSum))</h3><div class=\"section\">"
            html += interaction.htmlDescription()
            html += "</div>"
        }
        
        if !uncategorized.isEmpty {
            html += "<h3 onclick=\"toggleSection(this)\">Uncategorized (\(uncategorized.totalSum))</h3><div class=\"section\"><ul>"
            html += uncategorized.sortedByEDHRECRank.map { $0.htmlDescription }.joined()
            html += "</ul></div>"
        }
        
        html += """
        </div>
        </body>
        </html>
        """
        
        return html.replacingOccurrences(of: "—", with: "-")
    }
}
