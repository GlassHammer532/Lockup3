//
//  SearchResult.swift
//  Lockup
//

import Foundation

enum SearchResult {
    case facility(StorageFacility)
    case item(Item)
    case category(Category)

    var title: String {
        switch self {
        case .facility(let f): return f.name
        case .item(let i):     return i.name
        case .category(let c): return c.name
        }
    }

    var subtitle: String? {
        switch self {
        case .facility(let f): return f.address
        case .item(let i):     return i.description
        case .category(let c): return c.description
        }
    }
}
