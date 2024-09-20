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

extension DeckAnalysis.ManaProducing {
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

extension DeckAnalysis.Interaction {
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

extension DeckAnalysis {
    public func generateHTMLReport() -> String {
        var html = """
    <!DOCTYPE html>
    <html>
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
        .chart-container-small { width: 20%; display: inline-block; vertical-align: top; }
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
    <body>
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
    <div class="chart-container-small">
        <div class="chart-title">Interaction Types</div>
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
        </center>
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
                },
                plugins: {
                    legend: {
                        display: false
                    }
                },
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
    </script>
    """
        
        html += """
        <h2 onclick="toggleSection(this)">Card Types</h2>
            <div class="section">
                <h3 onclick="toggleSection(this)">Creatures (\(creatures.values.flatMap { $0 }.totalSum))</h3>
                <div class="section">
                    \(generateCardTypeSection(creatures.values.reduce(into: Set<DeckAnalysis.CardInfo>(), { partialResult, creatures in
                        partialResult.formUnion(creatures)
                    })))
                </div>
        
                <h3 onclick="toggleSection(this)">Enchantments (\(enchantments.totalSum))</h3>
                <div class="section">
                    \(generateCardTypeSection(enchantments))
                </div>
        
                <h3 onclick="toggleSection(this)">Artifacts (\(artifacts.totalSum))</h3>
                <div class="section">
                    \(generateCardTypeSection(artifacts))
                </div>
        
                <h3 onclick="toggleSection(this)">Equipment (\(equipment.totalSum))</h3>
                <div class="section">
                    \(generateCardTypeSection(equipment))
                </div>
        
                <h3 onclick="toggleSection(this)">Battles (\(battles.totalSum))</h3>
                <div class="section">
                    \(generateCardTypeSection(battles))
                </div>
        
                <h3 onclick="toggleSection(this)">Planeswalkers (\(planeswalkers.totalSum))</h3>
                <div class="section">
                    \(generateCardTypeSection(planeswalkers))
                </div>
        
                <h3 onclick="toggleSection(this)">Instants (\(instants.totalSum))</h3>
                <div class="section">
                    \(generateCardTypeSection(instants))
                </div>
        
                <h3 onclick="toggleSection(this)">Sorceries (\(sorceries.totalSum))</h3>
                <div class="section">
                    \(generateCardTypeSection(sorceries))
                </div>
        """
        
        if !uncategorizedType.isEmpty {
            html += "<h3 onclick=\"toggleSection(this)\">Uncategorized by type (\(uncategorizedType.totalSum))</h3><div class=\"section\"><ul>"
            html += uncategorizedType.sortedByEDHRECRank.map { $0.htmlDescription }.joined()
            html += "</ul></div>"
        }
        
        html += """
            </div>

            <h2 onclick="toggleSection(this)">Interaction Types</h2>
            <div class="section">
                <h3 onclick="toggleSection(this)">Spot Removal (\(interaction.spotRemoval.totalSum))</h3>
                <div class="section">
                    \(generateCardTypeSection(interaction.spotRemoval))
                </div>

                <h3 onclick="toggleSection(this)">Board Wipes (\(interaction.boardWipes.totalSum))</h3>
                <div class="section">
                    \(generateCardTypeSection(interaction.boardWipes))
                </div>

                <h3 onclick="toggleSection(this)">Land Hate (\(interaction.landHate.totalSum))</h3>
                <div class="section">
                    \(generateCardTypeSection(interaction.landHate))
                </div>

                <h3 onclick="toggleSection(this)">Control (\(interaction.control.totalSum))</h3>
                <div class="section">
                    \(generateCardTypeSection(interaction.control))
                </div>

                <h3 onclick="toggleSection(this)">Buff (\(interaction.buff.totalSum))</h3>
                <div class="section">
                    \(generateCardTypeSection(interaction.buff))
                </div>

                <h3 onclick="toggleSection(this)">Evasion (\(interaction.evasion.totalSum))</h3>
                <div class="section">
                    \(generateCardTypeSection(interaction.evasion))
                </div>

                <h3 onclick="toggleSection(this)">Ramp (\(interaction.ramp.totalSum))</h3>
                <div class="section">
                    \(generateCardTypeSection(interaction.ramp))
                </div>

                <h3 onclick="toggleSection(this)">Go Wide (\(interaction.goWide.totalSum))</h3>
                <div class="section">
                    \(generateCardTypeSection(interaction.goWide))
                </div>
        """
        
        if !uncategorizedStrategy.isEmpty {
            html += "<h3 onclick=\"toggleSection(this)\">Uncategorized by strategy (\(uncategorizedStrategy.totalSum))</h3><div class=\"section\"><ul>"
            html += uncategorizedStrategy.sortedByEDHRECRank.map { $0.htmlDescription }.joined()
            html += "</ul></div>"
        }
        
        html += """
        </div>
        </body>
        </html>
        """
        
        return html
    }
    
    private func generateCardTypeSection(_ cards: Set<CardInfo>) -> String {
        let sorted = Array(cards).sorted { $0.edhrecRank < $1.edhrecRank }
        let divs: [String] = sorted.map { card -> String in
            """
            <div class="card-info">
                <div><span class="card-header">\(card.quantity)x \(card.name)</span> (CMC: \(card.cmc); EDHREC: \(card.edhrecRank))</div>
                <div class="oracle-text">\(formatOracleText(card.oracleText))</div>
            </div>
            """
        }
            return divs.joined(separator: "\n")
    }

    private func formatOracleText(_ text: String) -> String {
        return text.components(separatedBy: "\n").map { "<p>\($0)</p>" }.joined()
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
