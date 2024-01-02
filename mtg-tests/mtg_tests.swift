//
//  mtg_tests.swift
//  mtg-tests
//
//  Created by Andrew McKnight on 12/30/23.
//

import mtg
import XCTest

final class mtg_tests: XCTestCase {
    func testDecodingVariousCardLayouts() throws {
        let decoder = JSONDecoder()
        let bundle = Bundle(for: mtg_tests.self)
        let resourcePath = try XCTUnwrap(bundle.resourcePath)
        let resources = try XCTUnwrap(URL(filePath: resourcePath))
        for layout in [
            ScryfallLayout.normal,
            ScryfallLayout.split,
            ScryfallLayout.flip,
            ScryfallLayout.transform,
            ScryfallLayout.modal_dfc,
            ScryfallLayout.meld,
            ScryfallLayout.leveler,
            ScryfallLayout.`class`,
            ScryfallLayout.saga,
            ScryfallLayout.adventure,
            ScryfallLayout.mutate,
            ScryfallLayout.prototype,
//            ScryfallLayout.battle,
//            ScryfallLayout.planar,
//            ScryfallLayout.scheme,
//            ScryfallLayout.vanguard,
//            ScryfallLayout.token,
//            ScryfallLayout.double_faced_token,
//            ScryfallLayout.emblem,
//            ScryfallLayout.augment,
//            ScryfallLayout.host,
//            ScryfallLayout.art_series,
            ScryfallLayout.reversible_card,
        ] {
            let url = resources.appending(component: "\(layout.rawValue).json")
            let data = try Data(contentsOf: url)
            do {
                let card = try decoder.decode(ScryfallCard.self, from: data)
                print("Successfully decoded \(layout.rawValue)")
                XCTAssertEqual(card.layout, layout)
                let scryfallInfo = Card.ScryfallInfo(scryfallCard: card, fetchDate: Date())
                print("\n\(scryfallInfo.csvRow)\n")
            } catch {
                XCTFail("Couldn't decode \(layout.rawValue): \(error)")
            }
        }
    }
}
