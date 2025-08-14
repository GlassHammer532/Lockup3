import Foundation
import CoreData
import CloudKit
import MapKit

@objc(StorageLocation)
public class StorageLocation: NSManagedObject {
    
    @nonobjc public class func fetchRequest() -> NSFetchRequest<StorageLocation> {
        return NSFetchRequest<StorageLocation>(entityName: "StorageLocation")
    }
    
    @NSManaged public var id: UUID
    @NSManaged public var name: String
    @NSManaged public var address: String?
    @NSManaged public var latitude: Double
    @NSManaged public var longitude: Double
    @NSManaged public var facilityType: String // "permanent" or "temporary"
    @NSManaged public var size: String?
    @NSManaged public var roomData: Data? // Serialized RoomPlan data
    @NSManaged public var createdAt: Date
    @NSManaged public var updatedAt: Date
    @NSManaged public var items: NSSet?
    @NSManaged public var categories: NSSet?
    
    // Computed properties
    var coordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
    
    var itemsArray: [Item] {
        let set = items as? Set<Item> ?? []
        return set.sorted { $0.name < $1.name }
    }
    
    var categoriesArray: [Category] {
        let set = categories as? Set<Category> ?? []
        return set.sorted { $0.name < $1.name }
    }
}

// MARK: Generated accessors for items
extension StorageLocation {
    @objc(addItemsObject:)
    @NSManaged public func addToItems(_ value: Item)

    @objc(removeItemsObject:)
    @NSManaged public func removeFromItems(_ value: Item)

    @objc(addItems:)
    @NSManaged public func addToItems(_ values: NSSet)

    @objc(removeItems:)
    @NSManaged public func removeFromItems(_ values: NSSet)
}

// MARK: Generated accessors for categories
extension StorageLocation {
    @objc(addCategoriesObject:)
    @NSManaged public func addToCategories(_ value: Category)

    @objc(removeCategoriesObject:)
    @NSManaged public func removeFromCategories(_ value: Category)

    @objc(addCategories:)
    @NSManaged public func addToCategories(_ values: NSSet)

    @objc(removeCategories:)
    @NSManaged public func removeFromCategories(_ values: NSSet)
}
