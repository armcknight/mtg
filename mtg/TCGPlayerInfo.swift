//
//  TCGPlayerInfo.swift
//  mtg
//
//  Created by Andrew McKnight on 6/5/24.
//

import Foundation

public struct TCGPlayerInfo {
    /** Fields I get from the TCGPlayer scan app that are TCGPlayer specific data. */
    public enum CSVHeader: String, CaseIterable {
        case productID = "TCGPlayer Product ID"
        case sku = "TCGPlayer SKU"
        case priceEach = "TCGPlayer Price Each"
        case fetchDate = "TCGPlayer Fetch Date"
    }
    
    var productID: Int?
    var SKU: String?
    var priceEach: Decimal?
    var fetchDate: Date?
    
    var csvRow: String {
        [
            "\(productID == nil ? "" : String(describing: productID!))",
            "\(SKU ?? "")",
            "\(priceEach == nil ? "" : String(describing: priceEach!))",
            "\(fetchDate == nil ? "" : dateFormatter.string(from: fetchDate!))",
        ].joined(separator: ",")
    }
    
    init(productID: Int?, SKU: String? = nil, priceEach: Decimal? = nil, fetchDate: Date? = nil) {
        self.productID = productID
        self.SKU = SKU
        self.priceEach = priceEach
        self.fetchDate = fetchDate
    }
    
    init(managedCSVKeyValues keyValues: [String: String]) {
        var productID: Int?
        if let productIDString = keyValues[CSVHeader.productID.rawValue] {
            productID = Int(productIDString)
        }
        
        let sku = keyValues[CSVHeader.sku.rawValue]
        
        var priceEach: Decimal?
        if let priceValue = keyValues[CSVHeader.priceEach.rawValue] {
            priceEach = Decimal(string: String(priceValue))
        }

        var fetchDate: Date?
        if let fetchDateString = keyValues[CSVHeader.fetchDate.rawValue] {
            fetchDate = dateFormatter.date(from: fetchDateString)
        }
        self = TCGPlayerInfo(productID: productID, SKU: sku, priceEach: priceEach, fetchDate: fetchDate)
    }
}
