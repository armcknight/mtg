//
//  Decks+HTMLReport.swift
//  mtg
//
//  Created by Andrew McKnight on 9/19/24.
//

import Foundation

extension DeckAnalysis.CardInfo {
    public var htmlDescription: String {
        return """
        <li>
            <div class="card-info">
                <span class="card-header">\(quantity)x \(name)</span> (CMC: \(cmc); EDHREC \(edhrecRank))
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

func sectionHTMLDescription(title: String, sectionContents: Set<DeckAnalysis.CardInfo>) -> String {
    var html = "<li><h4 onclick=\"toggleSection(this)\">\(title) (\(sectionContents.totalSum))</h4><div class=\"section\"><ul>"
    html += sectionContents.sorted(by: { $0.edhrecRank < $1.edhrecRank }).map { $0.htmlDescription }.joined()
    html += "</ul></div></li>"
    return html
}

extension DeckAnalysis.ManaProducing {
    public func htmlDescription() -> String {
        var html = "<ul>" 

        var emptySections = Set<String>()
        
        [
            "Basic Lands": basicLands, 
            "Nonbasic Lands": nonbasicLands, 
            "Triggered Abilities": triggeredAbilities, 
            "Static Abilities": staticAbilities
        ].forEach { (title, sectionContents) in
            if !sectionContents.isEmpty {
                html += sectionHTMLDescription(title: title, sectionContents: sectionContents)
            } else {
                emptySections.insert(title)
            }
        }

        if !emptySections.isEmpty {
            html += "<li><h4>Empty Categories</h4><ul>"
            emptySections.forEach { emptySection in
                html += "<li>\(emptySection)</li>"
            }
            html += "</ul></li>"
        }
        
        html += "</ul>"
        return html
    }
}

extension DeckAnalysis.Interaction {
    public func htmlDescription() -> String {
        var html = "<ul>"

        var emptySections = Set<String>()
        [
            "Spot Removal": spotRemoval, 
            "Board Wipes": boardWipes, 
            "Land Hate": landHate,
            "Group Hug": groupHug,
            "Control": control, 
            "Buff": buff, 
            "Evasion": evasion, 
            "Ramp": ramp, 
            "Go Wide": goWide,
            "Protection": protection,
            "Graveyard Recursion": graveyardRecursion,
            "Graveyard Gate": graveyardHate,
            "Sacrifice Outlet": sacrificeOutlet,
            "Library Manipulation": libraryManipulation,
            "Burn": burn,
            "Card Draw": cardDraw,
            "Tutors": tutors,
            "Color Fixing": colorFixing,
            "Land Fetch": landFetch,
            "Storm": storm,
        ].forEach { (title, sectionContents) in
            if !sectionContents.isEmpty {
                html += sectionHTMLDescription(title: title, sectionContents: sectionContents)
            } else {
                emptySections.insert(title)
            }
        }
        
        if !emptySections.isEmpty {
            html += "<li><h4 onclick=\"toggleSection(this)\">Empty Categories</h4><ul>"
            emptySections.forEach { emptySection in
                html += "<li>\(emptySection)</li>"
            }
            html += "</ul></li>"
        }
        
        html += "</ul>"
        return html
    }
}

extension DeckAnalysis {
    var head: String {
        """
        <head>
            <meta charset="UTF-8">
            <title>Deck Analysis</title>
            <script src="https://cdn.jsdelivr.net/npm/chart.js@4"></script>
            <script src="https://cdn.jsdelivr.net/npm/chartjs-chart-matrix@2"></script>
            <style>
                body { font-family: Arial, sans-serif; max-width: 1200px; margin: 0 auto; }
                h2, h3, h4 { margin: 20px 0 10px; cursor: pointer; }
                h2:before, h3:before, h4:before { content: "\\25BC "; }
                h2.collapsed:before, h3.collapsed:before, h4.collapsed:before { content: "\\25B6 "; }
                ul { list-style-type: none; padding-left: 20px; }
                .section { display: block; }
                .collapsed + .section { display: none; }
                .card-info { margin-bottom: 10px; }
                .card-header { font-weight: bold; }
                .oracle-text p { margin: 5px 0; }
                .hanging-indent { padding-left: 20px; }
                .chart-container-small { width: 30%; display: inline-block; vertical-align: top; }
                .chart-container-large { width: 40%; display: inline-block; vertical-align: top; }
                .chart-title { font-weight: bold; margin-bottom: 10px; text-align: center; }
            </style>
            <script>
                function toggleSection(header) {
                    header.classList.toggle('collapsed');
                    header.nextElementSibling.style.display = header.classList.contains('collapsed') ? 'none' : 'block';
                }
            </script>
        </head>
        """
    }
    
    var deckComposition: String {
        """
        <h2>Deck Composition Analysis</h2>
        <center>
            <div class="chart-container-small">
                <div class="chart-title">Card Types</div>
                <canvas id="cardTypeChart"></canvas>
            </div>
            <div class="chart-container-small">
                <div class="chart-title">Mana Production</div>
                <canvas id="manaProductionChart"></canvas>
            </div>
            <div class="chart-container-large">
                <div class="chart-title">Deck Balance (Interaction and Non-land Mana Production)</div>
                <canvas id="interactionChart"></canvas>
            </div>
            <br />
            <br />
            <br />
            <br />
            <div class="chart-container-large">
                <div class="chart-title">Card Types by Mana Cost</div>
                <canvas id="cardTypesByManaCostChart"></canvas>
            </div>
            <div class="chart-container-large">
                <div class="chart-title">Card Quantity vs Mana Cost vs EDHREC Rank</div>
                <canvas id="cardQuantityManaCostRankChart"></canvas>
            </div>
            <div class="chart-container-small">
                <div class="chart-title">Color Breakdown</div>
                <canvas id="colorBreakdownChart"></canvas>
            </div>
            <div class="chart-container-large">
                <div class="chart-title">Mana Curve by Color</div>
                <canvas id="manaCurveChart"></canvas>
            </div>
        </center>
        \(chartScript)
        """
    }

    var manaCurveByColorData: String {
        var manaCurveData = [
            "White": [Int](repeating: 0, count: 8),
            "Blue": [Int](repeating: 0, count: 8),
            "Black": [Int](repeating: 0, count: 8),
            "Red": [Int](repeating: 0, count: 8),
            "Green": [Int](repeating: 0, count: 8),
            "Colorless": [Int](repeating: 0, count: 8),
            "Generic": [Int](repeating: 0, count: 8)
        ]

        cards.forEach { card in
            let cmc = min(7, Int(card.cmc))
            if card.colors.isEmpty {
                manaCurveData["Generic"]![cmc] += card.quantity
            } else {
                if card.colors.contains(.W) { manaCurveData["White"]![cmc] += card.quantity }
                if card.colors.contains(.U) { manaCurveData["Blue"]![cmc] += card.quantity }
                if card.colors.contains(.B) { manaCurveData["Black"]![cmc] += card.quantity }
                if card.colors.contains(.R) { manaCurveData["Red"]![cmc] += card.quantity }
                if card.colors.contains(.G) { manaCurveData["Green"]![cmc] += card.quantity }
                if card.colors.contains(.C) { manaCurveData["Colorless"]![cmc] += card.quantity }
            }
        }

        let dataStrings = manaCurveData.map { color, counts in
            "{\n" +
            "    label: '\(color)',\n" +
            "    data: [\(counts.map(String.init).joined(separator: ", "))],\n" +
            "    backgroundColor: '\(colorToHex(color))'\n" +
            "}"
        }

        return "[\n" + dataStrings.joined(separator: ",\n") + "\n]"
    }
    
    private func colorToHex(_ color: String) -> String {
        switch color {
        case "White": return "#F8F6D8"
        case "Blue": return "#0E68AB"
        case "Black": return "#150B00"
        case "Red": return "#D3202A"
        case "Green": return "#00733E"
        case "Colorless": return "#CCCCCC"
        case "Generic": return "#996633"
        default: return "#000000"
        }
    }
    
    var chartScript: String {
        """
        <script>
        
        // Card Type Chart
        {
            const cardTypeData = \(generateCardTypeData());

            new Chart(document.getElementById('cardTypeChart'), {
                type: 'pie',
                data: {
                    labels: cardTypeData.labels,
                    datasets: [{
                        data: cardTypeData.data,
                        backgroundColor: [
                            '#FF6384', '#36A2EB', '#FFCE56', '#4BC0C0', '#9966FF',
                            '#FF9F40', '#C9CBCF', '#FF6B6B', '#4ECDC4', '#45B7D1',
                            '#F7DC6F', '#B8E994', '#D980FA', '#FDA7DF', '#9AECDB'
                        ]
                    }]
                },
                options: {
                    responsive: true,
                    plugins: {
                        legend: {
                            maxHeight: 400, // Make legend scrollable
                            overflow: 'auto',
                            position: 'right',
                            labels: {
                                boxWidth: 15 // Reduce the size of color boxes
                            },
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
        
        // Interaction and Mana Production Chart (Radar)
        {
            const categories = [
                'Spot Removal', 'Board Wipes', 'Land Hate', 'Group Hug', 'Control',
                'Buff', 'Evasion', 'Ramp', 'Go Wide',
                'Triggered Mana', 'Static Mana'
            ];
            const data = [
                \(interaction.spotRemoval.totalSum), \(interaction.boardWipes.totalSum),
                \(interaction.landHate.totalSum), \(interaction.groupHug.totalSum),
                \(interaction.control.totalSum), \(interaction.buff.totalSum),
                \(interaction.evasion.totalSum), \(interaction.ramp.totalSum),
                \(interaction.goWide.totalSum),
                \(manaProducing.triggeredAbilities.totalSum), \(manaProducing.staticAbilities.totalSum)
            ];

            new Chart(document.getElementById('interactionChart'), {
                type: 'radar',
                data: {
                    labels: categories,
                    datasets: [{
                        label: 'Deck Balance',
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
                    },
                    plugins: {
                        legend: {
                            display: false
                        },
                        tooltip: {
                            callbacks: {
                                label: function(context) {
                                    return `${context.label}: ${context.raw}`;
                                }
                            }
                        }
                    },
                    scales: {
                        r: {
                            angleLines: {
                                display: true,
                                color: 'rgba(0, 0, 0, 0.1)'
                            },
                            suggestedMin: 0
                        }
                    }
                }
            });
        }
        
        // Card Types by Mana Cost (Stacked Bar Chart)
        {
            const cardTypes = ['Creature', 'Enchantment', 'Artifact', 'Instant', 'Sorcery', 'Planeswalker'];
            const colors = ['#FF6384', '#36A2EB', '#FFCE56', '#4BC0C0', '#9966FF', '#FF9F40'];
            const data = \(generateCardTypesByManaCostData());
        
            new Chart(document.getElementById('cardTypesByManaCostChart'), {
                type: 'bar',
                data: {
                    labels: data.labels,
                    datasets: cardTypes.map((type, index) => ({
                        label: type,
                        data: data.datasets[index],
                        backgroundColor: colors[index]
                    }))
                },
                options: {
                    responsive: true,
                    scales: {
                        x: { stacked: true },
                        y: { stacked: true }
                    },
                    plugins: {
                        legend: {
                            position: 'bottom'
                        }
                    }
                }
            });
        }
        
        // EDHREC Rank vs Mana Cost (Matrix Chart)
        {
            const matrixData = \(generateEDHRECRankVsManaCostData());
        
            new Chart(document.getElementById('cardQuantityManaCostRankChart'), {
                type: 'matrix',
                data: {
                    datasets: [{
                        label: 'Card Distribution',
                        data: matrixData,
                        backgroundColor(context) {
                            const value = context.dataset.data[context.dataIndex].v;
                            const alpha = Math.min(value / 5, 1); // Adjust this divisor to change color intensity
                            return `rgba(255, 99, 132, ${alpha})`;
                        },
                        borderColor: 'rgb(255, 99, 132)',
                        borderWidth: 1,
                        width: ({ chart }) => (chart.chartArea || {}).width / 8 - 1,
                        height: ({ chart }) => (chart.chartArea || {}).height / 10 - 1
                    }]
                },
                options: {
                    responsive: true,
                    plugins: {
                        legend: {
                            display: false
                        },
                        tooltip: {
                            callbacks: {
                                title(context) {
                                    const item = context[0].dataset.data[context[0].dataIndex];
                                    return `CMC: ${item.x}, EDHREC Rank: ${item.y}k-${item.y + 1}k`;
                                },
                                label(context) {
                                    return `Cards: ${context.dataset.data[context.dataIndex].v}`;
                                }
                            }
                        }
                    },
                    scales: {
                        x: {
                            type: 'linear',
                            offset: true,
                            min: 0,
                            max: 7,
                            ticks: {
                                stepSize: 1
                            },
                            title: {
                                display: true,
                                text: 'Mana Cost'
                            }
                        },
                        y: {
                            type: 'linear',
                            offset: true,
                            reverse: true,
                            title: {
                                display: true,
                                text: 'EDHREC Rank'
                            },
                            ticks: {
                                callback: (value) => value * 1000
                            }
                        }
                    }
                }
            });
        }
        
        // Color Breakdown Chart (Horizontal Bar)
        {
            const colorData = \(colorBreakdownData);

            new Chart(document.getElementById('colorBreakdownChart'), {
                type: 'bar',
                data: {
                    labels: Object.keys(colorData),
                    datasets: [{
                        data: Object.values(colorData),
                        backgroundColor: [
                            '#F8F6D8', // White (slightly off-white)
                            '#0E68AB', // Blue (slightly darker)
                            '#150B00', // Black (very dark brown, easier to see than pure black)
                            '#D3202A', // Red (slightly darker)
                            '#00733E', // Green (forest green)
                            '#CCCCCC',  // Colorless (light gray, unchanged)
                            '#996633'  // Generic (brownish color display)
                        ]
                    }]
                },
                options: {
                    responsive: true,
                    plugins: {
                        legend: {
                            display: false,
                        },
                        title: {
                            display: false,
                        },
                        tooltip: {
                            callbacks: {
                                label: function(context) {
                                    const value = context.raw;
                                    const total = context.chart.data.datasets[0].data.reduce((a, b) => a + b, 0);
                                    const percentage = Math.round((value / total) * 100);
                                    return `${value} cards (${percentage}%)`;
                                }
                            }
                        }
                    },
                    scales: {
                        y: {
                            beginAtZero: true,
                            title: {
                                display: true,
                                text: 'Number of Cards'
                            }
                        }
                    }
                }
            });
        }

        // Mana Curve Chart
        {
            new Chart(document.getElementById('manaCurveChart'), {
                type: 'bar',
                data: {
                    labels: ['0', '1', '2', '3', '4', '5', '6', '7+'],
                    datasets: \(manaCurveByColorData)
                },
                options: {
                    responsive: true,
                    plugins: {
                        title: {
                            display: true,
                            text: 'Mana Curve by Color'
                        },
                        tooltip: {
                            mode: 'index',
                            intersect: false
                        }
                    },
                    scales: {
                        x: {
                            stacked: true,
                            title: {
                                display: true,
                                text: 'Mana Value'
                            }
                        },
                        y: {
                            stacked: true,
                            title: {
                                display: true,
                                text: 'Number of Cards'
                            }
                        }
                    }
                }
            });
        }
        </script>
        """
    }
    
    var colorBreakdownData: String {
        """
        {
            White: \(cards.filter { $0.colors.contains(.W) }.count),
            Blue: \(cards.filter { $0.colors.contains(.U) }.count),
            Black: \(cards.filter { $0.colors.contains(.B) }.count),
            Red: \(cards.filter { $0.colors.contains(.R) }.count),
            Green: \(cards.filter { $0.colors.contains(.G) }.count),
            Colorless: \(cards.filter { $0.colors.contains(.C) }.count),
            Generic: \(cards.filter { $0.colors.isEmpty }.count)
        }
        """
    }
    
    var cardTypeHTML: String {
        var cardTypeHTML = ""
        var emptySections = Set<String>()
        [
            "Creatures": creatures.values.reduce(into: Set<CardInfo>(), { partialResult, creatures in
                partialResult.formUnion(creatures)
            }),
            "Enchantments": enchantments,
            "Artifacts": artifacts,
            "Equipment": equipment,
            "Battles": battles,
            "Planeswalkers": planeswalkers,
            "Instants": instants,
            "Sorceries": sorceries
        ].forEach { (title, cards) in
            if !cards.isEmpty {
                cardTypeHTML += sectionHTMLDescription(title: title, sectionContents: cards)
            } else {
                emptySections.insert(title)
            }
        }
        
        if !uncategorizedType.isEmpty {
            cardTypeHTML += sectionHTMLDescription(title: "Uncategorized Types (\(uncategorizedType.totalSum))", sectionContents: uncategorizedType)
        }
        
        if !emptySections.isEmpty {
            cardTypeHTML += "<li><h4 onclick=\"toggleSection(this)\">Empty Categories</h4><ul>"
            emptySections.forEach { emptySection in
                cardTypeHTML += "<li>\(emptySection)</li>"
            }
        }
        
        return cardTypeHTML
    }
    
    public func generateHTMLReport() -> String {
        """
        <!DOCTYPE html>
        <html>
            \(head)
            <body>
                \(deckComposition)
                <h2 onclick="toggleSection(this)">Card Types</h2>
                <div class="section">
                    \(cardTypeHTML)
                </div>
                <h2 onclick="toggleSection(this)">Mana Production</h2>
                <div class="section">
                    \(manaProducing.htmlDescription())
                </div>
                <h2 onclick="toggleSection(this)">Interaction</h2>
                <div class="section">
                    \(interaction.htmlDescription())
                </div>
            </body>
        </html>
        """
    }
    
    private func generateCardTypeData() -> String {
        var cardTypes: [String: Int] = [:]

        // Function to add cards to the cardTypes dictionary
        func addCards(_ cards: [CardInfo], type: String) {
            let sum = cards.reduce(0) { $0 + $1.quantity }
            if sum > 0 {
                cardTypes[type] = (cardTypes[type] ?? 0) + Int(sum)
            }
        }

        // Add all card types
        addCards(creatures.values.flatMap { $0 }, type: "Creatures")
        addCards(Array(enchantments), type: "Enchantments")
        addCards(Array(artifacts), type: "Artifacts")
        addCards(Array(equipment), type: "Equipment")
        addCards(Array(battles), type: "Battles")
        addCards(Array(planeswalkers), type: "Planeswalkers")
        addCards(Array(instants), type: "Instants")
        addCards(Array(sorceries), type: "Sorceries")
        addCards(Array(manaProducing.basicLands), type: "Basic Lands")
        addCards(Array(manaProducing.nonbasicLands), type: "Nonbasic Lands")
        addCards(Array(uncategorizedType), type: "Other")

        let sortedTypes = cardTypes.sorted { $0.value > $1.value }
        let labels = sortedTypes.map { "\"\($0.key) (\($0.value))\"" }.joined(separator: ", ")
        let data = sortedTypes.map { $0.value }.map(String.init).joined(separator: ", ")

        return """
        {
            labels: [\(labels)],
            data: [\(data)]
        }
        """
    }
    
    private func generateCardTypesByManaCostData() -> String {
        let typeData: [(String, [CardInfo])] = [
            ("Creature", creatures.values.flatMap { $0 }),
            ("Enchantment", Array(enchantments)),
            ("Artifact", Array(artifacts)),
            ("Instant", Array(instants)),
            ("Sorcery", Array(sorceries)),
            ("Planeswalker", Array(planeswalkers)),
        ]
        
        var manaCostData: [[Int]] = Array(repeating: Array(repeating: 0, count: 8), count: typeData.count)
        var totalsByManaCost: [Int] = Array(repeating: 0, count: 8)
        
        for (typeIndex, (_, cards)) in typeData.enumerated() {
            for card in cards {
                let cmcIndex = min(Int(card.cmc), 7)
                manaCostData[typeIndex][cmcIndex] += card.quantity
                totalsByManaCost[cmcIndex] += card.quantity
            }
        }
        
        let nonEmptyIndices = totalsByManaCost.enumerated().compactMap { $0.element > 0 ? $0.offset : nil }
        let filteredData = manaCostData.map { typeData in
            nonEmptyIndices.map { typeData[$0] }
        }
        
        let labels = nonEmptyIndices.map { $0 == 7 ? "'7+'" : String($0) }.joined(separator: ", ")
        let joinedData = filteredData.map { "[" + $0.map(String.init).joined(separator: ", ") + "]" }.joined(separator: ",\n              ")
        
        return "{\n" +
               "    labels: [" + labels + "],\n" +
               "    datasets: [" + joinedData + "]\n" +
               "}"
    }

    private func generateEDHRECRankVsManaCostData() -> String {
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

        var matrixData: [String] = []
        for card in uniqueCards.values {
            let edhrecRank = card.edhrecRank
            let cmc = min(card.cmc, 7) // Group all 7+ CMC cards together
            let rankBucket = edhrecRank / 1000 // Group ranks into thousands
            
            matrixData.append("{ x: \(cmc), y: \(rankBucket), v: \(card.quantity) }")
        }

        return "[\n            " + matrixData.joined(separator: ",\n            ") + "\n        ]"
    }
}
