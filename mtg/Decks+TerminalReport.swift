//
//  Decks+TerminalReport.swift
//  mtg
//
//  Created by Andrew McKnight on 9/19/24.
//

import Foundation

extension Set where Element == DeckAnalysis.CardInfo {
    var description: String {
        map(\.description).joined(separator: "\n")
    }
    
    var sortedByEDHRECRank: [Element] {
        sorted(by: { $0.edhrecRank < $1.edhrecRank })
    }
    
    var sortedDescription: String {
        sortedByEDHRECRank.map(\.description).joined(separator: "\n")
    }
}

extension DeckAnalysis.CardInfo: CustomStringConvertible {
    public var description: String {
        return "\t\t\(quantity)x \(name): \(oracleText) (EDHREC \(edhrecRank))"
    }
}

extension DeckAnalysis.ManaProducing: CustomStringConvertible {
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
        
        if !other.isEmpty {
            components.append(contentsOf: [
                "\tOther (\(other.totalSum))",
                "\t----------------",
                other.sortedDescription
            ])
        } else {
            emptyCategories.append("Other")
        }
        
        if !emptyCategories.isEmpty {
            components.append("\tEmpty Mana Producing Categories: \(emptyCategories.joined(separator: ", "))")
        }
        
        return components.joined(separator: "\n")
    }
}

extension DeckAnalysis.Interaction: CustomStringConvertible {
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
        
        if !boardWipes.isEmpty {
            components.append(contentsOf: [
                "\tBoard Wipes (\(boardWipes.totalSum))",
                "\t----------",
                boardWipes.sortedDescription
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
        
        if !groupHug.isEmpty {
            components.append(contentsOf: [
                "\tGroup Hug (\(groupHug.totalSum))",
                "\t----------",
                groupHug.sortedDescription
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
        
        if !goWide.isEmpty {
            components.append(contentsOf: [
                "\tGo Wide (\(goWide.totalSum))",
                "\t-------",
                goWide.sortedDescription
            ])
        } else {
            emptyCategories.append("Go Wide")
        }
        
        if !emptyCategories.isEmpty {
            components.append("\tEmpty Interaction Categories: \(emptyCategories.joined(separator: ", "))")
        }
        
        return components.joined(separator: "\n")
    }
}

extension DeckAnalysis: CustomStringConvertible {
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
        
        if !interaction.spotRemoval.isEmpty || !interaction.boardWipes.isEmpty || !interaction.landHate.isEmpty || !interaction.groupHug.isEmpty || !interaction.control.isEmpty || !interaction.buff.isEmpty || !interaction.evasion.isEmpty || !interaction.ramp.isEmpty || !interaction.goWide.isEmpty {
            components.append("Interaction (\(interaction.totalSum))")
            components.append("-----------")
            components.append(interaction.description)
        } else {
            emptyCategories.append("Interaction")
        }
        
        if !interaction.uncategorizedStrategy.isEmpty {
            components.append("Uncategorized type (\(uncategorizedType.totalSum))")
            components.append("-------------")
            components.append(uncategorizedType.sortedDescription)
        }
        
        if !interaction.uncategorizedStrategy.isEmpty {
            components.append("Uncategorized strategy (\(interaction.uncategorizedStrategy.totalSum))")
            components.append("-------------")
            components.append(interaction.uncategorizedStrategy.sortedDescription)
        }
        
        if !emptyCategories.isEmpty {
            components.append("\nCategories with no entries:")
            components.append("----------------------------")
            components.append(emptyCategories.joined(separator: "\n"))
        }
        
        return components.joined(separator: "\n")
    }
}
