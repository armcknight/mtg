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
public func ~>(lhs: [String], rhs: Regex<Substring>) -> [String] {
    lhs.elements(notContaining: rhs)
}
func ~>(lhs: [String], rhs: [String]) -> [String] {
    lhs.elements(notContainingAnyOf: rhs)
}
func ~>(lhs: [String], rhs: [Regex<Substring>]) -> [String] {
    lhs.elements(notContainingAnyOf: rhs)
}

// MARK: ⊢ operator |>
func |>(lhs: [String], rhs: String) -> [String] {
    lhs.elements(containing: rhs)
}
func |>(lhs: [String], rhs: [Regex<Substring>]) -> [String] {
    lhs.elements(containingAnyOf: rhs)
}
func |>(lhs: [String], rhs: [String]) -> [String] {
    lhs.elements(containingAnyOf: rhs)
}

// MARK: ⊢ operator |?
func |?(lhs: [String], rhs: String) -> Bool {
    lhs.hasAtLeastOneElement(containing: rhs)
}
func |?(lhs: [String], rhs: Regex<Substring>) -> Bool {
    lhs.hasAtLeastOneElement(containing: rhs)
}
func |?(lhs: [String], rhs: [String]) -> Bool {
    lhs.hasAtLeastOneElement(containingOneOf: rhs)
}
func |?(lhs: [String], rhs: [Regex<Substring>]) -> Bool {
    lhs.hasAtLeastOneElement(containingOneOf: rhs)
}

// MARK: ∟ operator &>
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
    
    func elements(notContainingAnyOf keywords: [Regex<Substring>]) -> [String] {
        filter({ element in
            !keywords.contains(where: {
                element.contains($0)
            })
        })
    }
    
    func elements(containingAnyOf keywords: [Regex<Substring>]) -> [String] {
        filter({ element in
            keywords.contains(where: {
                element.contains($0)
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
    
    func hasAtLeastOneElement(containingOneOf keywords: [Regex<Substring>]) -> Bool {
        filter({ element in
            keywords.contains(where: {
                element.contains($0)
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
