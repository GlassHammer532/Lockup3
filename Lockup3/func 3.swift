import Foundation
import CoreData

extension CategoryEntity {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<CategoryEntity> {
        return NSFetchRequest<CategoryEntity>(entityName: "CategoryEntity")
    }

    @NSManaged public var id: UUID
    @NSManaged public var name: String
    @NSManaged public var descriptionText: String?
    @NSManaged public var colorHex: String
    @NSManaged public var items: Set<ItemEntity>?

}

extension CategoryEntity {
    func update(from model: Category) {
        id = model.id
        name = model.name
        descriptionText = model.description
        colorHex = model.colorHex
    }

    func toModel() -> Category {
        return Category(
            id: id,
            name: name,
            description: descriptionText,
            colorHex: colorHex
        )
    }
}
