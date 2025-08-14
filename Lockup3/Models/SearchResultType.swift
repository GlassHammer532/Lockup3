import Foundation

enum SearchResultType {
    case storageLocation
    case item
    case category
}

struct SearchResult: Identifiable {
    let id = UUID()
    let title: String
    let subtitle: String?
    let type: SearchResultType
    let objectID: NSManagedObjectID
}
