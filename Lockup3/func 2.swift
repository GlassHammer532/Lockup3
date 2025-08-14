import Foundation
import CoreData

extension ItemEntity {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<ItemEntity> {
        return NSFetchRequest<ItemEntity>(entityName: "ItemEntity")
    }

    @NSManaged public var id: UUID
    @NSManaged public var name: String
    @NSManaged public var descriptionText: String?
    @NSManaged public var imageFileNames: [String]
    @NSManaged public var facility: FacilityEntity?
    @NSManaged public var categories: Set<CategoryEntity>?

}

extension ItemEntity {
    func update(from model: Item) {
        id = model.id
        name = model.name
        descriptionText = model.description
        imageFileNames = model.imageFileNames
        // facility & categories set in PersistenceService
    }

    func toModel() -> Item {
        let categoryIDs = categories?.compactMap { $0.id } ?? []
        return Item(
            id: id,
            name: name,
            imageFileNames: imageFileNames,
            categoryIDs: categoryIDs,
            description: descriptionText,
            facilityID: facility?.id
        )
    }
}
