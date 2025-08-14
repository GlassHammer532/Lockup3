import Foundation
import CoreData

extension FacilityEntity {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<FacilityEntity> {
        return NSFetchRequest<FacilityEntity>(entityName: "FacilityEntity")
    }

    @NSManaged public var id: UUID
    @NSManaged public var name: String
    @NSManaged public var address: String
    @NSManaged public var latitude: Double
    @NSManaged public var longitude: Double
    @NSManaged public var type: String
    @NSManaged public var width: NSNumber?
    @NSManaged public var length: NSNumber?
    @NSManaged public var height: NSNumber?
    @NSManaged public var shape: String?
    @NSManaged public var items: Set<ItemEntity>?

}

extension FacilityEntity {
    func update(from model: StorageFacility) {
        id = model.id
        name = model.name
        address = model.address
        latitude = model.coordinate.latitude
        longitude = model.coordinate.longitude
        type = model.type.rawValue
        if let dims = model.dimensions {
            width = NSNumber(value: dims.width)
            length = NSNumber(value: dims.length)
            height = NSNumber(value: dims.height)
            shape = dims.shape.rawValue
        } else {
            width = nil; length = nil; height = nil; shape = nil
        }
        // items handled via relationships in PersistenceService
    }

    func toModel() -> StorageFacility {
        let coord = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        let dims: RoomDimensions? = {
            guard let w = width?.doubleValue,
                  let l = length?.doubleValue,
                  let h = height?.doubleValue,
                  let s = shape.flatMap({ RoomShape(rawValue: $0) })
            else { return nil }
            return RoomDimensions(width: w, length: l, height: h, shape: s)
        }()
        let itemIDs = items?.compactMap { $0.id } ?? []
        return StorageFacility(
            id: id,
            name: name,
            address: address,
            coordinate: coord,
            type: FacilityType(rawValue: type)!,
            dimensions: dims,
            items: itemIDs
        )
    }
}
