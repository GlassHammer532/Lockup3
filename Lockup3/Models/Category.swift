import Foundation
import CoreData
import SwiftUI

@objc(Category)
public class Category: NSManagedObject {
    
    @nonobjc public class func fetchRequest() -> NSFetchRequest<Category> {
        return NSFetchRequest<Category>(entityName: "Category")
    }
    
    @NSManaged public var id: UUID
    @NSManaged public var name: String
    @NSManaged public var categoryDescription: String?
    @NSManaged public var colorHex: String
    @NSManaged public var createdAt: Date
    @NSManaged public var items: NSSet?
    @NSManaged public var storageLocations: NSSet?
    
    // Computed properties
    var color: Color {
        Color(hex: colorHex) ?? .blue
    }
    
    var itemsArray: [Item] {
        let set = items as? Set<Item> ?? []
        return set.sorted { $0.name < $1.name }
    }
}

// MARK: Generated accessors for items
extension Category {
    @objc(addItemsObject:)
    @NSManaged public func addToItems(_ value: Item)

    @objc(removeItemsObject:)
    @NSManaged public func removeFromItems(_ value: Item)

    @objc(addItems:)
    @NSManaged public func addToItems(_ values: NSSet)

    @objc(removeItems:)
    @NSManaged public func removeFromItems(_ values: NSSet)
}

// MARK: Generated accessors for storageLocations
extension Category {
    @objc(addStorageLocationsObject:)
    @NSManaged public func addToStorageLocations(_ value: StorageLocation)

    @objc(removeStorageLocationsObject:)
    @NSManaged public func removeFromStorageLocations(_ value: StorageLocation)

    @objc(addStorageLocations:)
    @NSManaged public func addToStorageLocations(_ values: NSSet)

    @objc(removeStorageLocations:)
    @NSManaged public func removeFromStorageLocations(_ values: NSSet)
}
