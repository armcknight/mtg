//
//  Decks.swift
//  mtg
//
//  Created by Andrew McKnight on 8/30/24.
//

import Foundation

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
        logger.debug("cardName: \(cardName); edhrecRank: \(edhrecRank); cmc: \(cmc)")
        
        let cardInfo = DeckAnalysis.CardInfo(name: cardName, oracleText: oracleText.faceJoin, quantity: quantity, edhrecRank: edhrecRank, cmc: Int(ceil(cmc)))
        
        // analyze card type
        
        if cardType.contains("Land") {
            if cardType.contains("Basic") {
                analysis.manaProducing.basicLands.append(cardInfo)
                noType = false
            } else {
                analysis.manaProducing.nonbasicLands.append(cardInfo)
                noType = false
            }
        }
        
        if cardType.contains("Creature") {
            // Add creature type analysis here
            if analysis.creatures[cardType] == nil {
                analysis.creatures[cardType] = [cardInfo]
            } else {
                analysis.creatures[cardType]?.append(cardInfo)
            }
            noType = false
        }
        
        if cardType.contains("Enchantment") {
            analysis.enchantments.append(cardInfo)
            noType = false
        }
        
        if cardType.contains("Artifact") {
            analysis.artifacts.append(cardInfo)
            noType = false
        }
        
        if cardType.contains("Equipment") {
            analysis.equipment.append(cardInfo)
            noType = false
        }
        
        if cardType.contains("Battle") {
            analysis.battles.append(cardInfo)
            noType = false
        }
        
        if cardType.contains("Planeswalker") {
            analysis.planeswalkers.append(cardInfo)
            noType = false
        }
        
        if cardType.contains("Instant") {
            analysis.instants.append(cardInfo)
            noType = false
        }
        
        if cardType.contains("Sorcery") {
            analysis.sorceries.append(cardInfo)
            noType = false
        }
        
        
        // analyze card play strategy
        
        let oracleTextLowercased = oracleText.map({$0.lowercased()})
        
        func oracleTextContainsLineContaining(query: String) -> Bool {
            oracleTextLowercased.contains(where: { $0.contains(query) })
        }
        
        if !cardType.contains("Land") && oracleTextContainsLineContaining(query: "add {") {
            analysis.manaProducing.triggeredAbilities.append(cardInfo)
            noStrategy = false
        }
        
        // TODO: also check for -1/-1, -X/-X etc
        if oracleTextContainsLineContaining(query: "all") && (oracleTextContainsLineContaining(query: "destroy") || oracleTextContainsLineContaining(query: "exile")) {
            analysis.interaction.boardWipes.append(cardInfo)
            noStrategy = false
        } else if oracleTextContainsLineContaining(query: "destroy") || oracleTextContainsLineContaining(query: "exile") {
            analysis.interaction.spotRemoval.append(cardInfo)
            noStrategy = false
        }
        if oracleTextContainsLineContaining(query: "deal") && oracleTextContainsLineContaining(query: "damage") &&
           (oracleTextContainsLineContaining(query: "creature") || 
            oracleTextContainsLineContaining(query: "planeswalker") || 
            oracleTextContainsLineContaining(query: "battle")) {
            analysis.interaction.spotRemoval.append(cardInfo)
            noStrategy = false
        }
        
        
        if oracleTextContainsLineContaining(query: "land") && (oracleTextContainsLineContaining(query: "destroy") || oracleTextContainsLineContaining(query: "exile")) {
            analysis.interaction.landHate.append(cardInfo)
            noStrategy = false
        }
        
        if oracleTextLowercased.contains("each player") || oracleTextLowercased.contains("each opponent") {
            analysis.interaction.groupHug.append(cardInfo)
            noStrategy = false
        }
        
        if oracleTextContainsLineContaining(query: "counter") && oracleTextContainsLineContaining(query: "spell") {
            analysis.interaction.control.append(cardInfo)
            noStrategy = false
        }
        
        if oracleTextLowercased.contains("+1/+1") || oracleTextLowercased.contains("gets +") {
            analysis.interaction.buff.append(cardInfo)
            noStrategy = false
        }
        
        if oracleTextContainsLineContaining(query: "flying") || oracleTextContainsLineContaining(query: "fear") || oracleTextContainsLineContaining(query: "shadow") || oracleTextContainsLineContaining(query: "reach") || oracleTextContainsLineContaining(query: "flanking") {
            analysis.interaction.evasion.append(cardInfo)
            noStrategy = false
        }
        
        if oracleTextLowercased.contains("search your library") &&
            (oracleTextContainsLineContaining(query: "land")
             || oracleTextContainsLineContaining(query: "wastes")
             || oracleTextContainsLineContaining(query: "forest")
             || oracleTextContainsLineContaining(query: "plains")
             || oracleTextContainsLineContaining(query: "mountain")
             || oracleTextContainsLineContaining(query: "swamp")
             || oracleTextContainsLineContaining(query: "island"))
        {
            analysis.interaction.ramp.append(cardInfo)
            noStrategy = false
        }
        
        if oracleTextContainsLineContaining(query: "create") && oracleTextContainsLineContaining(query: "token") {
            analysis.interaction.goWide.append(cardInfo)
            noStrategy = false
        }
        
        if oracleTextContainsLineContaining(query: "land") && oracleTextContainsLineContaining(query: "additional") {
            analysis.interaction.ramp.append(cardInfo)
            noStrategy = false
        }
        
        if oracleTextContainsLineContaining(query: "draw") {
            analysis.interaction.cardDraw.append(cardInfo)
            noStrategy = false
        }
        
        // collect cards that didn't meet any criteria
        if noType {
            analysis.uncategorizedType.append(cardInfo)
        }
        if noStrategy {
            analysis.uncategorizedStrategy.append(cardInfo)
        }
    }
    
    return analysis
}

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
        public let cmc: Int // scryfall stores these as decimals b/c some cards have fractional components (likely no tournament-legal ones, like unfinity) but we'll just take the integer value rounded up
        
        public init(name: String, oracleText: String, quantity: Int, edhrecRank: Int, cmc: Int) {
            self.name = name
            self.oracleText = oracleText
            self.quantity = quantity
            self.edhrecRank = edhrecRank
            self.cmc = cmc
        }
        
        public var description: String {
            return "\t\t\(quantity)x \(name): \(oracleText) (EDHREC \(edhrecRank))"
        }
        
        public var htmlDescription: String {
            return """
            <li>
                <div class="card-info">
                    <span class="card-header">\(quantity)x \(name) (EDHREC \(edhrecRank))</span>
                    <div class="oracle-text">
                        \(oracleText.split(separator: ";").enumerated().map { index, text in
                            let trimmedText = text.trimmingCharacters(in: .whitespaces)
                            return index == 0 ? "<p>\(trimmedText)</p>" : "<p class=\"hanging-indent\">\(trimmedText)</p>"
                        }.joined())
                    </div>
                </div>
            </li>
            """
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
        public var boardWipes = [CardInfo]()
        public var landHate = [CardInfo]()
        public var groupHug = [CardInfo]()
        public var control = [CardInfo]()
        public var buff = [CardInfo]()
        public var evasion = [CardInfo]()
        public var ramp = [CardInfo]()
        public var goWide = [CardInfo]() // tokens, TODO: copying
        public var cardDraw = [CardInfo]()
        public var burn = [CardInfo]() // TODO: implement ("damage to target")
        public var protection = [CardInfo]() // TODO: implement ("prevent all combat damage")
        public var deckManipulation = [CardInfo]() // TODO: implement (scry, surveil, sylvan library)
        public var graveyardRecursion = [CardInfo]() // TODO: implement
        public var graveyardHate = [CardInfo]() // TODO: implement
        
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
        
        public var totalSum: Int {
            spotRemoval.totalSum + boardWipes.totalSum + landHate.totalSum + groupHug.totalSum + control.totalSum + buff.totalSum + evasion.totalSum + ramp.totalSum + goWide.totalSum
        }
        
        public func htmlDescription() -> String {
            var html = "<ul>"
            
            if !spotRemoval.isEmpty {
                html += "<li><h4 onclick=\"toggleSection(this)\">Spot Removal (\(spotRemoval.totalSum))</h4><div class=\"section\"><ul>"
                html += spotRemoval.sortedByEDHRECRank.map { $0.htmlDescription }.joined()
                html += "</ul></div></li>"
            }
            
            if !boardWipes.isEmpty {
                html += "<li><h4 onclick=\"toggleSection(this)\">Boardwipes (\(boardWipes.totalSum))</h4><div class=\"section\"><ul>"
                html += boardWipes.sortedByEDHRECRank.map { $0.htmlDescription }.joined()
                html += "</ul></div></li>"
            }
            
            if !landHate.isEmpty {
                html += "<li><h4 onclick=\"toggleSection(this)\">Land Hate (\(landHate.totalSum))</h4><div class=\"section\"><ul>"
                html += landHate.sortedByEDHRECRank.map { $0.htmlDescription }.joined()
                html += "</ul></div></li>"
            }
            
            if !groupHug.isEmpty {
                html += "<li><h4 onclick=\"toggleSection(this)\">Group Hug (\(groupHug.totalSum))</h4><div class=\"section\"><ul>"
                html += groupHug.sortedByEDHRECRank.map { $0.htmlDescription }.joined()
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
            
            if !goWide.isEmpty {
                html += "<li><h4 onclick=\"toggleSection(this)\">Go Wide (\(goWide.totalSum))</h4><div class=\"section\"><ul>"
                html += goWide.sortedByEDHRECRank.map { $0.htmlDescription }.joined()
                html += "</ul></div></li>"
            }
            
            html += "</ul>"
            return html
        }
    }
    
    // card strategy information
    public var manaProducing = ManaProducing()
    public var interaction = Interaction()
    
    // card type information
    public var creatures: [String: [CardInfo]] = [:]
    public var enchantments = [CardInfo]()
    public var artifacts = [CardInfo]()
    public var equipment = [CardInfo]()
    public var battles = [CardInfo]()
    public var planeswalkers = [CardInfo]()
    public var instants = [CardInfo]()
    public var sorceries = [CardInfo]()
    
    public var uncategorizedStrategy = [CardInfo]()
    public var uncategorizedType = [CardInfo]()
    
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
        
        if !interaction.spotRemoval.isEmpty || !interaction.boardWipes.isEmpty || !interaction.landHate.isEmpty || !interaction.groupHug.isEmpty || !interaction.control.isEmpty || !interaction.buff.isEmpty || !interaction.evasion.isEmpty || !interaction.ramp.isEmpty || !interaction.goWide.isEmpty {
            components.append("Interaction (\(interaction.totalSum))")
            components.append("-----------")
            components.append(interaction.description)
        } else {
            emptyCategories.append("Interaction")
        }
        
        if !uncategorizedStrategy.isEmpty {
            components.append("Uncategorized type (\(uncategorizedType.totalSum))")
            components.append("-------------")
            components.append(uncategorizedType.sortedDescription)
        }
        
        if !uncategorizedStrategy.isEmpty {
            components.append("Uncategorized strategy (\(uncategorizedStrategy.totalSum))")
            components.append("-------------")
            components.append(uncategorizedStrategy.sortedDescription)
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
    <meta charset="UTF-8">
    <title>Deck Analysis</title>
    <script src="https://cdn.jsdelivr.net/npm/chart.js"></script>
    <style>
        body { font-family: Arial, sans-serif; max-width: 1200px; margin: 0 auto; }
        h2, h3, h4 { margin: 20px 0 10px; cursor: pointer; }
        h3:before, h4:before { content: "\\25BC "; }
        h3.collapsed:before, h4.collapsed:before { content: "\\25B6 "; }
        ul { list-style-type: none; padding-left: 20px; }
        .section { display: block; }
        .collapsed + .section { display: none; }
        .card-info { margin-bottom: 10px; }
        .card-header { font-weight: bold; }
        .oracle-text p { margin: 5px 0; }
        .hanging-indent { padding-left: 20px; }
        .chart-container { width: 45%; height: 400px; display: inline-block; margin: 20px 2%; vertical-align: top; }
        .chart-title { font-weight: bold; margin-bottom: 10px; text-align: center; }
    </style>
    <script>
        function toggleSection(header) {
            header.classList.toggle('collapsed');
            header.nextElementSibling.style.display = header.classList.contains('collapsed') ? 'none' : 'block';
        }
    </script>
    </head>
    <body>
    <h2>Deck Composition Analysis</h2>
    <div class="chart-container">
        <div class="chart-title">Card Types</div>
        <canvas id="cardTypeChart"></canvas>
    </div>
    <div class="chart-container">
        <div class="chart-title">Mana Production</div>
        <canvas id="manaProductionChart"></canvas>
    </div>
    <div class="chart-container">
        <div class="chart-title">Interaction Types</div>
        <canvas id="interactionChart"></canvas>
    </div>
    <div class="chart-container">
        <div class="chart-title">Card Types by Mana Cost</div>
        <canvas id="cardTypesByManaCostChart"></canvas>
    </div>
    <div class="chart-container">
        <div class="chart-title">Card Quantity vs Mana Cost vs EDHREC Rank</div>
        <canvas id="cardQuantityManaCostRankChart"></canvas>
    </div>
    
    <script>
    // Card Type Chart
    {
        const labels = ['Creatures', 'Enchantments', 'Artifacts', 'Equipment', 'Battles', 'Planeswalkers', 'Other'];
        const data = [\(creatures.values.flatMap { $0 }.totalSum), \(enchantments.totalSum), \(artifacts.totalSum), \(equipment.totalSum), \(battles.totalSum), \(planeswalkers.totalSum), \(uncategorizedStrategy.totalSum)];
        const colors = ['#FF6384', '#36A2EB', '#FFCE56', '#4BC0C0', '#9966FF', '#FF9F40', '#C9CBCF'];
        
        const filteredData = data.map((value, index) => ({ value, label: labels[index], color: colors[index] }))
                                 .filter(item => item.value > 0);
        
        new Chart(document.getElementById('cardTypeChart'), {
            type: 'pie',
            data: {
                labels: filteredData.map(item => item.label),
                datasets: [{
                    data: filteredData.map(item => item.value),
                    backgroundColor: filteredData.map(item => item.color)
                }]
            },
            options: {
                responsive: true,
                plugins: {
                    legend: {
                        position: 'bottom',
                    }
                }
            }
        });
    }

    // Mana Production Chart
    {
        const labels = ['Basic Lands', 'Nonbasic Lands', 'Triggered Abilities', 'Static Abilities'];
        const data = [\(manaProducing.basicLands.totalSum), \(manaProducing.nonbasicLands.totalSum), \(manaProducing.triggeredAbilities.totalSum), \(manaProducing.staticAbilities.totalSum)];
        const colors = ['#FF6384', '#36A2EB', '#FFCE56', '#4BC0C0'];
        
        const filteredData = data.map((value, index) => ({ value, label: labels[index], color: colors[index] }))
                                 .filter(item => item.value > 0);
        
        new Chart(document.getElementById('manaProductionChart'), {
            type: 'pie',
            data: {
                labels: filteredData.map(item => item.label),
                datasets: [{
                    data: filteredData.map(item => item.value),
                    backgroundColor: filteredData.map(item => item.color)
                }]
            },
            options: {
                responsive: true,
                plugins: {
                    legend: {
                        position: 'bottom',
                    }
                }
            }
        });
    }

    // Interaction Chart (Radar)
    {
        const interactionTypes = ['Spot Removal', 'Board Wipes', 'Land Hate', 'Group Hug', 'Control', 'Buff', 'Evasion', 'Ramp', 'Go Wide'];
        const data = [\(interaction.spotRemoval.totalSum), \(interaction.boardWipes.totalSum), \(interaction.landHate.totalSum), \(interaction.groupHug.totalSum), \(interaction.control.totalSum), \(interaction.buff.totalSum), \(interaction.evasion.totalSum), \(interaction.ramp.totalSum), \(interaction.goWide.totalSum)];

        new Chart(document.getElementById('interactionChart'), {
            type: 'radar',
            data: {
                labels: interactionTypes,
                datasets: [{
                    label: 'Interaction Balance',
                    data: data,
                    fill: true,
                    backgroundColor: Chart.helpers.color('#FF6384').alpha(0.2).rgbString(),
                    borderColor: '#FF6384',
                    pointBackgroundColor: '#FF6384',
                    pointBorderColor: '#fff',
                    pointHoverBackgroundColor: '#fff',
                    pointHoverBorderColor: '#FF6384'
                }]
            },
            options: {
                responsive: true,
                elements: {
                    line: { borderWidth: 3 }
                }
            }
        });
    }

    // Card Types by Mana Cost (Stacked Bar Chart)
    {
        const manaCosts = [0, 1, 2, 3, 4, 5, 6, '7+'];
        const cardTypes = ['Creature', 'Enchantment', 'Artifact', 'Instant', 'Sorcery', 'Planeswalker', 'Land'];
        const data = [
            \(generateCardTypesByManaCostData())
        ];

        new Chart(document.getElementById('cardTypesByManaCostChart'), {
            type: 'bar',
            data: {
                labels: manaCosts,
                datasets: cardTypes.map((type, index) => ({
                    label: type,
                    data: data[index],
                    backgroundColor: Chart.helpers.color(Chart.defaults.color).alpha(0.5).rgbString()
                }))
            },
            options: {
                responsive: true,
                scales: {
                    x: { stacked: true },
                    y: { stacked: true }
                }
            }
        });
    }

    // Card Quantity vs Mana Cost vs EDHREC Rank (Bubble Chart)
    {
        const cardData = [
            \(generateCardQuantityManaCostRankData())
        ];

        new Chart(document.getElementById('cardQuantityManaCostRankChart'), {
            type: 'bubble',
            data: {
                datasets: [{
                    label: 'Cards',
                    data: cardData.map(d => ({
                        x: d[0],
                        y: d[1],
                        r: d[2]
                    })),
                    backgroundColor: Chart.helpers.color('#FF6384').alpha(0.5).rgbString()
                }]
            },
            options: {
                responsive: true,
                scales: {
                    x: {
                        title: {
                            display: true,
                            text: 'Mana Cost'
                        }
                    },
                    y: {
                        title: {
                            display: true,
                            text: 'EDHREC Rank'
                        },
                        reverse: true  // Higher EDHREC rank is actually lower on the chart
                    }
                }
            }
        });
    }

    // Interaction Balance (Radar Chart)
    {
        const interactionTypes = ['Spot Removal', 'Board Wipes', 'Land Hate', 'Group Hug', 'Control', 'Buff', 'Evasion', 'Ramp', 'Go Wide'];
        const data = [\(interaction.spotRemoval.totalSum), \(interaction.boardWipes.totalSum), \(interaction.landHate.totalSum), \(interaction.groupHug.totalSum), \(interaction.control.totalSum), \(interaction.buff.totalSum), \(interaction.evasion.totalSum), \(interaction.ramp.totalSum), \(interaction.goWide.totalSum)];

        new Chart(document.getElementById('interactionChart'), {
            type: 'radar',
            data: {
                labels: interactionTypes,
                datasets: [{
                    label: 'Interaction Balance',
                    data: data,
                    fill: true,
                    backgroundColor: Chart.helpers.color('#FF6384').alpha(0.2).rgbString(),
                    borderColor: '#FF6384',
                    pointBackgroundColor: '#FF6384',
                    pointBorderColor: '#fff',
                    pointHoverBackgroundColor: '#fff',
                    pointHoverBorderColor: '#FF6384'
                }]
            },
            options: {
                responsive: true,
                elements: {
                    line: { borderWidth: 3 }
                }
            }
        });
    }

    // Card Types by Mana Cost (Stacked Bar Chart)
    {
        const manaCosts = [0, 1, 2, 3, 4, 5, 6, '7+'];
        const cardTypes = ['Creature', 'Enchantment', 'Artifact', 'Instant', 'Sorcery', 'Planeswalker', 'Land'];
        const data = [
            \(generateCardTypesByManaCostData())
        ];

        new Chart(document.getElementById('cardTypesByManaCostChart'), {
            type: 'bar',
            data: {
                labels: manaCosts,
                datasets: cardTypes.map((type, index) => ({
                    label: type,
                    data: data[index],
                    backgroundColor: Chart.helpers.color(Chart.defaults.color).alpha(0.5).rgbString()
                }))
            },
            options: {
                responsive: true,
                scales: {
                    x: { stacked: true },
                    y: { stacked: true }
                }
            }
        });
    }

    // Card Quantity vs Mana Cost vs EDHREC Rank (Bubble Chart)
    {
        const cardData = [
            \(generateCardQuantityManaCostRankData())
        ];

        new Chart(document.getElementById('cardQuantityManaCostRankChart'), {
            type: 'bubble',
            data: {
                datasets: [{
                    label: 'Cards',
                    data: cardData.map(d => ({
                        x: d[0],
                        y: d[1],
                        r: d[2] * 2  // Adjust multiplier as needed for bubble size
                    })),
                    backgroundColor: Chart.helpers.color('#FF6384').alpha(0.5).rgbString()
                }]
            },
            options: {
                responsive: true,
                scales: {
                    x: {
                        title: {
                            display: true,
                            text: 'Mana Cost'
                        }
                    },
                    y: {
                        title: {
                            display: true,
                            text: 'EDHREC Rank'
                        },
                        reverse: true  // Higher EDHREC rank is actually lower on the chart
                    }
                }
            }
        });
    }
    </script>

    <h2 onclick="toggleSection(this)">Detailed Analysis</h2>
    <div class="section">
    """
        
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
        
        if !interaction.spotRemoval.isEmpty || !interaction.boardWipes.isEmpty || !interaction.landHate.isEmpty || !interaction.groupHug.isEmpty || !interaction.control.isEmpty || !interaction.buff.isEmpty || !interaction.evasion.isEmpty || !interaction.ramp.isEmpty || !interaction.goWide.isEmpty {
            html += "<h3 onclick=\"toggleSection(this)\">Interaction (\(interaction.totalSum))</h3><div class=\"section\">"
            html += interaction.htmlDescription()
            html += "</div>"
        }
        
        if !uncategorizedStrategy.isEmpty {
            html += "<h3 onclick=\"toggleSection(this)\">Uncategorized by strategy (\(uncategorizedStrategy.totalSum))</h3><div class=\"section\"><ul>"
            html += uncategorizedStrategy.sortedByEDHRECRank.map { $0.htmlDescription }.joined()
            html += "</ul></div>"
        }
        
        if !uncategorizedType.isEmpty {
            html += "<h3 onclick=\"toggleSection(this)\">Uncategorized by type (\(uncategorizedType.totalSum))</h3><div class=\"section\"><ul>"
            html += uncategorizedType.sortedByEDHRECRank.map { $0.htmlDescription }.joined()
            html += "</ul></div>"
        }
        
        html += """
        </div>
        </body>
        </html>
        """
        
        return html
    }

private func generateCardTypesByManaCostData() -> String {
    let typeData: [(String, [CardInfo])] = [
        ("Creature", creatures.values.flatMap { $0 }),
        ("Enchantment", enchantments),
        ("Artifact", artifacts),
        ("Instant", instants),
        ("Sorcery", sorceries),
        ("Planeswalker", planeswalkers),
        ("Land", manaProducing.basicLands + manaProducing.nonbasicLands)
    ]
    
    let manaCostData = typeData.map { (type, cards) -> [Int] in
        var counts = Array(repeating: 0, count: 8)
        for card in cards {
            let index = min(card.cmc, 7)
            counts[index] += Int(card.quantity)
        }
        return counts
    }
    
    return manaCostData.map { "[" + $0.map(String.init).joined(separator: ", ") + "]" }.joined(separator: ",\n            ")
}

private func generateCardQuantityManaCostRankData() -> String {
    let allCards = creatures.values.flatMap { $0 } +
                   enchantments +
                   artifacts +
                   instants +
                   sorceries +
                   planeswalkers +
                   manaProducing.basicLands +
                   manaProducing.nonbasicLands +
                   uncategorizedType
    
    var uniqueCards: [String: CardInfo] = [:]
    for card in allCards {
        uniqueCards[card.name] = card
    }

    let cardData = uniqueCards.values.compactMap { cardInfo -> [String]? in
        return [String(cardInfo.cmc), String(cardInfo.edhrecRank), String(cardInfo.quantity)]
    }
    
    logger.debug("cardData for quantity x edhrec x cmc chart: \(cardData)")
    
    return cardData.map { "[" + $0.joined(separator: ", ") + "]" }.joined(separator: ",\n            ")
}

}
