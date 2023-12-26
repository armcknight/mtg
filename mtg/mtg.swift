//
//  mtg.swift
//  mtg
//
//  Created by Andrew McKnight on 12/23/23.
//

import Foundation

public var dateFormatter: ISO8601DateFormatter = {
    let df = ISO8601DateFormatter()
    df.timeZone = Calendar.current.timeZone
    return df
}()
public let processInfo = ProcessInfo.processInfo
public let fileManager = FileManager.default
public let baseCollectionFile = "collection.csv"
