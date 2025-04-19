//
//  scryfall.swift
//  scryfall
//
//  Created by Andrew McKnight on 1/28/24.
//

import Foundation
import Progress
import Logging

let logger = Logger(label: "scryfall")

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

func scryfallSetCode(cardName: String?, cardSet: String, cardNumber: String) -> String {
    var setCode = cardSet.lowercased()
    
    guard let cardName else {
        // this is from an input with set and number only
        return setCode
    }
    
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
        else if cardName == "Ruthless Lawbringer" && cardNumber == "372" {
            return "otj"
        }
    }
    
    else {
        switch setCode {
        case "pre": // there is no prerelease set called "pre" in scryfall
            switch cardName {
            case "The Millennium Calendar": return "plci"
            case "Katilda and Lier": return "moc"
            default: break
            }
        case "ump":
            switch cardName {
            case "Chandra, Torch of Defiance": return "q06"
            case "Lotus Petal (Foil Etched)": return "p30m"
            case "Phyrexian Arena (Phyrexian) (ONE Bundle)": return "one"
            case "Queen Kayla bin-Kroog (Retro Frame) (BRO Bundle)": return "bro"
            case "Hit the Mother Lode (LCI Bundle)": return "lci"
            case "Powerbalance (MH3 Bundle)": return "pmh3"
            default: break
            }
        case "ohp":
            switch cardName {
            case "Drown in the Loch (Retro Frame)": return "pw23"
            default: break
            }
        case "ctd": return "cst" // tcgplayer calls the coldsnap theme deck set "ctd" but scryfall calls it "cst"
        case "game": return "sch" // TCGPlayer calls the "Game Day & Store Championship Promos" set by code "GAME", while Scryfall calls it "SCH"; go with Scryfall's, as it's more consistent and that's what we'll be using to query their API with anyways
        case "larp": return "pw24" // TCGPlayer's "Launch and Release Party" set is Scryfall's "Wizard's Play Network 2024"
        case "list": return "plst"
        case "mh2":
            // these cards belong to the collector booster subset "Modern Horizons 2 Timeshifts" that wasn't programmed into TCGPlayer as of time of scans
            switch cardName {
            case "Strike It Rich (Retro Frame)": return "h2r"
            case "Dress Down (Retro Frame)": return "h2r"
            case "Grief (Retro Frame)": return "h2r"
            case "Tireless Provisioner (Retro Frame)": return "h2r"
            case "Esper Sentinel (Retro Frame)": return "h2r"
            case "Hard Evidence (Retro Frame)": return "h2r"
            default: break
            }
        case "30a-p": return "p30a" // 30th anniversary play promo set
        default: break
        }
    }
    
    return setCode
}

func scryfallCardNumber(cardName: String?, cardSet: String, cardNumber: String) -> String {
    guard let cardName else {
        // this is from an input with set and number only
        return cardNumber
    }
    
    switch cardSet {
    case "LIST": fatalError("use alternate name-keyed data structure to get plst cards instead of hardcoding a workaround for each card")
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

public func cardRequest(cardName: String?, cardSet: String, cardNumber: String) -> URLRequest {
    var urlString = "http://localhost:8080"
    
    let scryfallSetCode = scryfallSetCode(cardName: cardName, cardSet: cardSet, cardNumber: cardNumber)
    
    if scryfallSetCode != cardSet.lowercased() {
        logger.notice("Transformed set code for Scryfall compatibility: \(cardSet) -> \(scryfallSetCode)")
    }
    
    // TCGPlayer scans have their own numbering system for cards in The List set, and Scryfall has a different scheme. Find these by card name and set code instead of hardcoding each workaround
    if cardSet == "LIST" {
        precondition(cardName != nil, "Need a card name to use a cardByNameAndSet query")
        urlString.append("/cardByNameAndSet/\(cardName!)/\(scryfallSetCode)")
    } else {
        urlString.append("/cardBySetAndNumber/\(scryfallSetCode)/\(scryfallCardNumber(cardName: cardName, cardSet: cardSet, cardNumber: cardNumber))")
    }
    
    let urlComponents = URLComponents(string: urlString)
    guard let url = urlComponents?.url else {
        fatalError("Couldn't construct URL for \(urlString)")
    }
    
    return URLRequest(url: url)
}

public struct ScryfallBulkData: Decodable {
    /** A unique ID for this bulk item. */
    var `id`: UUID
    /** The Scryfall API URI for this file. */
    var uri: URL
    /** A computer-readable string for the kind of bulk item. */
    var type: String
    /** A human-readable name for this file. */
    public var name: String
    /** A human-readable description for this file. */
    var description: String
    /** The URI that hosts this bulk file for fetching. */
    public var download_uri: URL
    /** The time when this file was last updated. */
    public var updated_at: String
    /** The size of this file in integer bytes. */
    var size: Int
    /** The MIME type of this file. */
    var content_type: String
    /** The Content-Encoding encoding that will be used to transmit this file when you download it. */
    var content_encoding: String
}

public func bulkDataRequest() -> URLRequest {
    return URLRequest(url: URL(string: "https://api.scryfall.com/bulk-data/default-cards")!)
}

public enum RequestError: Error, CustomStringConvertible {
    case clientError(Error)
    case httpError(URLResponse)
    case noData
    case invalidData
    case resultError
    case noDownloadLocation
    case moveFailure(String, Error)
    
    public var description: String {
        switch self {
        case .clientError(let error): return "Request failed in client stack with error: \(error)."
        case .httpError(let response): return "Request failed with HTTP status \((response as! HTTPURLResponse).statusCode)."
        case .noData: return "Response contained no data."
        case .invalidData: return "Response data couldn't be decoded."
        case .resultError: return "The request completed successfully but a problem occurred returning the decoded response."
        case .noDownloadLocation: return "The download completed but no file location was reported."
        case .moveFailure(let path, let error): return "The temporary download file couldn't be moved to the specified location (\(path)): \(error)."
        }
    }
}

/**
 * Send a request to a local running scryfall bulk data HTTP server. See the project's `scryfall-local` target.
 */
public func synchronouslyRequest<T: Decodable>(request: URLRequest) -> Result<T, RequestError> {
    var result: T?
    var requestError: RequestError?
    
    let group = DispatchGroup()
    group.enter()
    urlSession.dataTask(with: request) { data, response, error in
        defer {
            group.leave()
        }
        
        guard error == nil else {
            requestError = RequestError.clientError(error!)
            return
        }
        
        let status = (response as! HTTPURLResponse).statusCode
        
        guard status >= 200 && status < 300 else {
            requestError = RequestError.httpError(response!)
            return
        }
        
        guard let data else {
            requestError = RequestError.noData
            return
        }
        
        do {
            result = try jsonDecoder.decode(T.self, from: data)
        } catch {
            guard let responseDataString = String(data: data, encoding: .utf8) else {
                logger.warning("Response data can't be decoded to a string for debugging error from decoding response data from request to \(String(describing: request.url)) (original error: \(error)")
                requestError = RequestError.invalidData
                return
            }
            logger.error("Failed decoding API response from request to \(String(describing: request.url)): \(error) (string contents: \(responseDataString))")
            requestError = RequestError.invalidData
        }
    }.resume()
    group.wait()
    
    if let requestError {
        return .failure(requestError)
    }
    
    guard let result else {
        return .failure(RequestError.resultError)
    }
    
    return .success(result)
}

public class DownloadProgressReporter: NSObject, URLSessionDownloadDelegate {
    var progressBar: ProgressBar?
    var progressBarConfiguration: [ProgressElementType]
    public var dispatchGroup: DispatchGroup?

    public init(progressBarConfiguration: [ProgressElementType]) {
        self.progressBarConfiguration = progressBarConfiguration
    }

    public func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
        progressBar?.finish()
    }

    public func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: (any Error)?) {
        progressBar?.finish()
    }

    public func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didWriteData bytesWritten: Int64, totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64) {
        if progressBar == nil {
            let totalBytesExpectedToWrite = totalBytesExpectedToWrite < 0 ? 0 : UInt64(totalBytesExpectedToWrite)
            progressBar = ProgressBar(count: totalBytesExpectedToWrite, configuration: progressBarConfiguration)
        }
        progressBar?.next()
    }
}

public func synchronouslyDownload(request: URLRequest, to: URL, delegate: DownloadProgressReporter? = nil) throws {
    var requestError: RequestError?
    
    let group = DispatchGroup()
    group.enter()
    let task: URLSessionDownloadTask
    if let delegate {
        task = urlSession.downloadTask(with: request)
        task.delegate = delegate
        delegate.dispatchGroup = group
    } else {
        task = urlSession.downloadTask(with: request) { location, response, error in
            defer {
                group.leave()
            }

            guard error == nil else {
                requestError = RequestError.clientError(error!)
                return
            }

            let status = (response as! HTTPURLResponse).statusCode

            guard status >= 200 && status < 300 else {
                requestError = RequestError.httpError(response!)
                return
            }

            guard let location else {
                requestError = RequestError.noDownloadLocation
                return
            }

            do {
                try FileManager.default.moveItem(at: location, to: to)
            } catch {
                requestError = RequestError.moveFailure(to.path, error)
            }

        }
    }
    task.resume()
    group.wait()
    
    if let requestError {
        throw requestError
    }
}
