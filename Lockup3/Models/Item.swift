import Foundation
import CoreData
import UIKit

@objc(Item)
public class Item: NSManagedObject {
    
    @nonobjc public class func fetchRequest() -> NSFetchRequest<Item> {
        return NSFetchRequest<Item>(entityName: "Item")
    }
    
    @NSManaged public var id: UUID
    @NSManaged public var name: String
    @NSManaged public var itemDescription: String?
    @NSManaged public var imageData: Data?
    @NSManaged public var position3D: Data? // Serialized 3D position data
    @NSManaged public var recognitionConfidence: Float
    @NSManaged public var createdAt: Date
    @NSManaged public var updatedAt: Date
    @NSManaged public var storageLocation: StorageLocation?
    @NSManaged public var categories: NSSet?
    
    // Computed properties
    var image: UIImage? {
        guard let imageData = imageData else { return nil }
        return UIImage(data: imageData)
    }
    
    var categoriesArray: [Category] {
        let set = categories as? Set<Category> ?? []
        return set.sorted { $0.name < $1.name }
    }
    
    var position: Position3D? {
        guard let position3D = position3D else { return nil }
        return try? JSONDecoder().decode(Position3D.self, from: position3D)
    }
    
    func setPosition(_ position: Position3D) {
        self.position3D = try? JSONEncoder().encode(position)
    }
}

// MARK: Generated accessors for categories
extension Item {
    @objc(addCategoriesObject:)
    @NSManaged public func addToCategories(_ value: Category)

    @objc(removeCategoriesObject:)
    @NSManaged public func removeFromCategories(_ value: Category)

    @objc(addCategories:)
    @NSManaged public func addToCategories(_ values: NSSet)

    @objc(removeCategories:)
    @NSManaged public func removeFromCategories(_ values: NSSet)
}
