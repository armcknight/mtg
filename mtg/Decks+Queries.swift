//
//  Decks+Queries.swift
//  mtg
//
//  Created by Andrew McKnight on 10/12/24.
//

import Foundation

precedencegroup OracleTextFiltering {
    higherThan: LogicalConjunctionPrecedence
    associativity: left
}

// MARK: Operators

/// Filter for elements matching **any** members of query
infix operator |>: OracleTextFiltering

/// Check existence of elements matching **any** members of query
infix operator |?: OracleTextFiltering

/// Filter for elements matching **all** members of query
infix operator &>: OracleTextFiltering

/// Check existence of elements matching **all** members of query
infix operator &?: OracleTextFiltering

/// Filter for elements not matching not matching **any** members of query
infix operator ~>: OracleTextFiltering

// MARK: Operator impls

// MARK: ⊢ operator ~>

func ~>(lhs: [String], rhs: String) -> [String] {
    lhs.elements(notContaining: rhs)
}
@available(macOS 13.0, iOS 16.0, *)
public func ~>(lhs: [String], rhs: Regex<Substring>) -> [String] {
    lhs.elements(notContaining: rhs)
}
func ~>(lhs: [String], rhs: [String]) -> [String] {
    lhs.elements(notContainingAnyOf: rhs)
}
@available(macOS 13.0, iOS 16.0, *)
func ~>(lhs: [String], rhs: [Regex<Substring>]) -> [String] {
    lhs.elements(notContainingAnyOf: rhs)
}

// MARK: ⊢ operator |>
func |>(lhs: [String], rhs: String) -> [String] {
    lhs.elements(containing: rhs)
}
@available(macOS 13.0, iOS 16.0, *)
func |>(lhs: [String], rhs: [String: Regex<Substring>]) -> [String] {
    lhs.elements(containingAnyOf: rhs)
}
func |>(lhs: [String], rhs: [String]) -> [String] {
    lhs.elements(containingAnyOf: rhs)
}

// MARK: ⊢ operator |?
func |?(lhs: [String], rhs: String) -> Bool {
    lhs.hasAtLeastOneElement(containing: rhs)
}
@available(macOS 13.0, iOS 16.0, *)
func |?(lhs: [String], rhs: Regex<Substring>) -> Bool {
    lhs.hasAtLeastOneElement(containing: rhs)
}
func |?(lhs: [String], rhs: [String]) -> Bool {
    lhs.hasAtLeastOneElement(containingOneOf: rhs)
}
@available(macOS 13.0, iOS 16.0, *)
func |?(lhs: [String], rhs: [String: Regex<Substring>]) -> Bool {
    lhs.hasAtLeastOneElement(containingOneOf: rhs)
}

// MARK: ∟ operator &>
@available(macOS 13.0, iOS 16.0, *)
func &>(lhs: [String], rhs: [Regex<Substring>]) -> [String] {
    lhs.elements(containingAllOf: rhs)
}
func &>(lhs: [String], rhs: [String]) -> [String] {
    lhs.elements(containingAllOf: rhs)
}

func &?(lhs: [String], rhs: [String]) -> Bool {
    lhs.hasAtLeastOneElement(containingAllOf: rhs)
}

// MARK: Query functions

extension Array where Element == String {
    // MARK: Singular queries
    
    func elements(notContaining keyword: String) -> [String] {
        filter({ element in
            !element.contains(keyword)
        })
    }

    @available(macOS 13.0, iOS 16.0, *)
    func elements(notContaining keyword: Regex<Substring>) -> [String] {
        filter({ element in
            !element.contains(keyword)
        })
    }
    
    func elements(containing keyword: String) -> [String] {
        filter({ element in
            element.contains(keyword)
        })
    }
    
    func hasAtLeastOneElement(containing keyword: String) -> Bool {
        filter({ element in
            element.contains(keyword)
        }).count > 0
    }

    @available(macOS 13.0, iOS 16.0, *)
    func hasAtLeastOneElement(containing keyword: Regex<Substring>) -> Bool {
        filter({ element in
            element.contains(keyword)
        }).count > 0
    }
    
    // MARK: Plural queries
    
    func elements(notContainingAnyOf keywords: [String]) -> [String] {
        filter({ element in
            !keywords.contains(where: {
                element.contains($0)
            })
        })
    }

    @available(macOS 13.0, iOS 16.0, *)
    func elements(notContainingAnyOf keywords: [Regex<Substring>]) -> [String] {
        filter({ element in
            !keywords.contains(where: {
                element.contains($0)
            })
        })
    }

    @available(macOS 13.0, iOS 16.0, *)
    func elements(containingAnyOf keywords: [String: Regex<Substring>]) -> [String] {
        filter({ element in
            keywords.contains(where: {
                let doesMatch = element.contains($0.value)
                if doesMatch {
                    logger.debug("\"\(element)\" contains \"\($0.key)\"")
                } else {
                    logger.debug("\"\(element)\" does not contain \"\($0.key)\"")
                }
                return doesMatch
            })
        })
    }
    
    func elements(containingAnyOf keywords: [String]) -> [String] {
        filter({ element in
            keywords.contains(where: {
                element.contains($0)
            })
        })
    }

    @available(macOS 13.0, iOS 16.0, *)
    func elements(containingAllOf keywords: [Regex<Substring>]) -> [String] {
        filter({ element in
            keywords.filter({
                element.contains($0)
            }).count == keywords.count
        })
    }
    
    func elements(containingAllOf keywords: [String]) -> [String] {
        filter({ element in
            keywords.filter({
                element.contains($0)
            }).count == keywords.count
        })
    }
    
    func hasAtLeastOneElement(containingOneOf keywords: [String]) -> Bool {
        filter({ element in
            keywords.contains(where: {
                element.contains($0)
            })
        }).count > 0
    }

    @available(macOS 13.0, iOS 16.0, *)
    func hasAtLeastOneElement(containingOneOf keywords: [String: Regex<Substring>]) -> Bool {
        filter({ element in
            keywords.contains(where: {
                let doesMatch = element.contains($0.value)
                if doesMatch {
                    logger.debug("\"\(element)\" contains \"\($0.key)\"")
                } else {
                    logger.debug("\"\(element)\" does not contain \"\($0.key)\"")
                }
                return doesMatch
            })
        }).count > 0
    }
    
    func hasAtLeastOneElement(containingAllOf keywords: [String]) -> Bool {
        filter({ element in
            keywords.filter({
                element.contains($0)
            }).count == keywords.count
        }).count > 0
    }
}

@available(macOS 13.0, iOS 16.0, *)
extension Array where Element == String {
    var regexes: [String: Regex<Substring>] {
        return reduce(into: [String: Regex<Substring>]()) { partialResult, next in
            do {
                let regex = try Regex<Substring>(next)
                partialResult[next] = regex
            } catch {
                logger.warning("Could not build a regex from the pattern: \"\(next)\"")
            }
        }
    }
}
