//
//  scryfall.swift
//  scryfall
//
//  Created by Andrew McKnight on 1/28/24.
//

import Foundation

public typealias SetCode = String
public typealias CardNumber = String
public typealias ScryfallCardsBySetAndNumber = [SetCode: [CardNumber: ScryfallCard]]
public typealias ScryfallCardsByNameAndSet = [String: [SetCode: ScryfallCard]]
public typealias ScryfallCardLookups = (bySetAndNumber: ScryfallCardsBySetAndNumber, byNameAndSet: ScryfallCardsByNameAndSet)
public func parseScryfallDataDump(path: String, progressInit: ((Int) -> Void)?, progress: (() -> Void)?) -> ScryfallCardLookups {
    let data: Data
    do {
        data = try Data(contentsOf: URL(filePath: path))
    } catch {
        fatalError("Failed to read scryfall data dump file")
    }
    
    do {
        let cardArray = try JSONDecoder().decode([ScryfallCard].self, from: data)
        progressInit?(cardArray.count)
        return cardArray.reduce(into: (bySetAndNumber: ScryfallCardsBySetAndNumber(), byNameAndSet: ScryfallCardsByNameAndSet())) { partialResult, nextCard in
            progress?()
            let set = nextCard.set ?? nextCard.card_faces!.first!.set!
            let cardNumber = nextCard.collector_number ?? nextCard.card_faces!.first!.collector_number!
            let name = nextCard.name
            
            if partialResult.bySetAndNumber[set] != nil {
                partialResult.bySetAndNumber[set]![cardNumber] = nextCard
            } else {
                partialResult.bySetAndNumber[set] = [cardNumber: nextCard]
            }
            
            if partialResult.byNameAndSet[name] != nil {
                partialResult.byNameAndSet[name]![set] = nextCard
            } else {
                partialResult.byNameAndSet[name] = [set: nextCard]
            }
        }
    } catch {
        fatalError("Failed to decode scryfall data dump file: \(error)")
    }
}

func scryfallSetCode(cardName: String, cardSet: String, cardNumber: String) -> String {
    var setCode = cardSet.lowercased()
    
    if setCode.count == 5 && setCode.hasPrefix("pp") {
        setCode = "p" + setCode[setCode.index(setCode.startIndex, offsetBy: 2)...]
        
        // scryfall doesn't put these in promo sets even though they are promos
        if cardName == "Tanglespan Lookout" && cardNumber == "379" {
            return "woe"
        }
        else if cardName == "Sleight of Hand" && cardNumber == "376" {
            return "woe"
        }
        else if cardName == "Deep-Cavern Bat" && cardNumber == "406" {
            return "lci"
        }
    }
    
    else {
        switch setCode {
        case "ctd": return "cst" // tcgplayer calls the coldsnap theme deck set "ctd" but scryfall calls it "cst"
        case "game": return "sch" // TCGPlayer calls the "Game Day & Store Championship Promos" set by code "GAME", while Scryfall calls it "SCH"; go with Scryfall's, as it's more consistent and that's what we'll be using to query their API with anyways
        case "list": return "plst"
        default:
            switch cardName {
            case "Lotus Petal (Foil Etched)": return "p30m"
            case "Phyrexian Arena (Phyrexian) (ONE Bundle)": return "one"
            case "Katilda and Lier": return "moc"
            case "Drown in the Loch (Retro Frame)": return "pw23"
            case "Queen Kayla bin-Kroog (Retro Frame) (BRO Bundle)": return "bro"
            case "Hit the Mother Lode (LCI Bundle)": return "lci"
            default: break
            }
        }
    }
    
    return cardSet
}

func scryfallCardNumber(cardName: String, cardSet: String, cardNumber: String) -> String {
    switch cardSet.lowercased() {
    case "list": fatalError("use alternate data structure to get plst cards instead of hardcoding a workaround for each card")
    default:
        switch cardName {
        case "Lotus Petal (Foil Etched)": return "2" // it's actually card #1 but because all the cards in P30M are 1, scryfall stores this one as 2
        default: break
        }
    }
    
    return cardNumber
}

let jsonDecoder = JSONDecoder()
let urlSession = URLSession(configuration: URLSessionConfiguration.default)

/**
 * Send a request to a local running scryfall bulk data HTTP server. See the project's `scryfall-local` target.
 */
public func synchronouslyRequest(cardName: String, cardSet: String, cardNumber: String) -> ScryfallCard? {
    var scryfallCard: ScryfallCard?
    
    var urlString = "https://localhost:8080"
    
    // TCGPlayer scans have their own numbering system for cards in The List set, and Scryfall has a different scheme. Find these by card name and set code instead of hardcoding each workaround
    if cardSet == "LIST" {
        urlString.append("/cardsByNameAndSet/\(cardName)/\(cardSet)")
    } else {
        urlString.append("/cardsBySetAndNumber/\(cardSet)/\(cardNumber)")
    }
    
    let urlComponents = URLComponents(string: urlString)
    guard let url = urlComponents?.url else {
        fatalError("Couldn't construct URL for \(urlString)")
    }
    
    let group = DispatchGroup()
    group.enter()
    urlSession.dataTask(with: URLRequest(url: url)) { data, response, error in
        defer {
            group.leave()
        }
        
        guard error == nil else {
            print("[Scryfall] Failed to fetch card: \(cardName) (\(cardSet) \(cardNumber)): \(String(describing: error))")
//            requestError = RequestError.clientError
            return
        }
        
        let status = (response as! HTTPURLResponse).statusCode
        
        guard status != 404 else {
            print("[Scryfall] Card not found: \(cardName) (\(cardSet) \(cardNumber))")
//            requestError = RequestError.httpNotFound
            return
        }
        
        guard status >= 200 && status < 300 else {
            print("[Scryfall] Unexpected error fetching card: \(cardName) (\(cardSet) \(cardNumber))")
//            requestError = RequestError.httpError
            return
        }
        
        guard let data else {
            print("[Scryfall] Request to fetch card succeeded but response data was empty: \(cardName) (\(cardSet) \(cardNumber)")
//            requestError = RequestError.noData
            return
        }
        
        do {
            scryfallCard = try jsonDecoder.decode(ScryfallCard.self, from: data)
        } catch {
            guard let responseDataString = String(data: data, encoding: .utf8) else {
                print("[Scryfall] Response data can't be decoded to a string for debugging error: \(cardName) (\(cardSet) \(cardNumber)) (original error: \(error)")
//                requestError = RequestError.invalidData
                return
            }
            print("[Scryfall] Failed decoding API response for: \(cardName) (\(cardSet) \(cardNumber)): \(error) (string contents: \(responseDataString))")
//            requestError = RequestError.invalidData
        }
    }.resume()
    group.wait()
    
//    if let requestError {
//        return .failure(requestError)
//    }
//    
//    guard let scryfallCard else {
//        return .failure(RequestError.resultError)
//    }
//    
//    return .success(scryfallCard)
    return scryfallCard
}
