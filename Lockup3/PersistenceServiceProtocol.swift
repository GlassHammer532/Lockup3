import Foundation
import CoreData

protocol PersistenceServiceProtocol {
    // Facilities
    func fetchFacilities() throws -> [StorageFacility]
    func saveFacility(_ facility: StorageFacility) throws
    func deleteFacility(id: UUID) throws

    // Items
    func fetchItems() throws -> [Item]
    func saveItem(_ item: Item) throws
    func deleteItem(id: UUID) throws

    // Categories
    func fetchCategories() throws -> [Category]
    func saveCategory(_ category: Category) throws
    func deleteCategory(id: UUID) throws
}

final class PersistenceService: PersistenceServiceProtocol {
    static let shared = PersistenceService()
    private let container: NSPersistentContainer

    private init() {
        container = NSPersistentContainer(name: "LockupModel")
        container.loadPersistentStores { _, error in
            if let error = error {
                fatalError("Core Data store load error: \(error)")
            }
        }
    }

    private var context: NSManagedObjectContext { container.viewContext }

    // MARK: – Facility CRUD

    func fetchFacilities() throws -> [StorageFacility] {
        let req: NSFetchRequest<FacilityEntity> = FacilityEntity.fetchRequest()
        let entities = try context.fetch(req)
        return entities.map { $0.toModel() }
    }

    func saveFacility(_ model: StorageFacility) throws {
        let entity = try fetchOrCreateFacilityEntity(id: model.id)
        entity.update(from: model)

        // Sync items relationship
        entity.items = Set(try model.items.map { id in
            let itemEnt = try fetchOrCreateItemEntity(id: id)
            itemEnt.facility = entity
            return itemEnt
        })

        try context.save()
    }

    func deleteFacility(id: UUID) throws {
        let req: NSFetchRequest<FacilityEntity> = FacilityEntity.fetchRequest()
        req.predicate = NSPredicate(format: "id == %@", id as CVarArg)
        if let ent = try context.fetch(req).first {
            // Nullify facility relationship on items
            ent.items?.forEach { $0.facility = nil }
            context.delete(ent)
            try context.save()
        }
    }

    private func fetchOrCreateFacilityEntity(id: UUID) throws -> FacilityEntity {
        let req: NSFetchRequest<FacilityEntity> = FacilityEntity.fetchRequest()
        req.predicate = NSPredicate(format: "id == %@", id as CVarArg)
        if let existing = try context.fetch(req).first {
            return existing
        }
        let newEnt = FacilityEntity(context: context)
        newEnt.id = id
        return newEnt
    }

    // MARK: – Item CRUD

    func fetchItems() throws -> [Item] {
        let req: NSFetchRequest<ItemEntity> = ItemEntity.fetchRequest()
        let entities = try context.fetch(req)
        return entities.map { $0.toModel() }
    }

    func saveItem(_ model: Item) throws {
        let entity = try fetchOrCreateItemEntity(id: model.id)
        entity.update(from: model)

        // Facility relationship
        if let facID = model.facilityID {
            let facEnt = try fetchOrCreateFacilityEntity(id: facID)
            entity.facility = facEnt
        } else {
            entity.facility = nil
        }

        // Categories relationship
        entity.categories = Set(try model.categoryIDs.map { cid in
            let catEnt = try fetchOrCreateCategoryEntity(id: cid)
            catEnt.items?.insert(entity)
            return catEnt
        })

        try context.save()
    }

    func deleteItem(id: UUID) throws {
        let req: NSFetchRequest<ItemEntity> = ItemEntity.fetchRequest()
        req.predicate = NSPredicate(format: "id == %@", id as CVarArg)
        if let ent = try context.fetch(req).first {
            ent.categories?.forEach { $0.items?.remove(ent) }
            context.delete(ent)
            try context.save()
        }
    }

    private func fetchOrCreateItemEntity(id: UUID) throws -> ItemEntity {
        let req: NSFetchRequest<ItemEntity> = ItemEntity.fetchRequest()
        req.predicate = NSPredicate(format: "id == %@", id as CVarArg)
        if let existing = try context.fetch(req).first {
            return existing
        }
        let newEnt = ItemEntity(context: context)
        newEnt.id = id
        return newEnt
    }

    // MARK: – Category CRUD

    func fetchCategories() throws -> [Category] {
        let req: NSFetchRequest<CategoryEntity> = CategoryEntity.fetchRequest()
        let entities = try context.fetch(req)
        return entities.map { $0.toModel() }
    }

    func saveCategory(_ model: Category) throws {
        let entity = try fetchOrCreateCategoryEntity(id: model.id)
        entity.update(from: model)

        // Sync back-reference
        entity.items = Set(try fetchItemEntities(for: model.id))

        try context.save()
    }

    func deleteCategory(id: UUID) throws {
        let req: NSFetchRequest<CategoryEntity> = CategoryEntity.fetchRequest()
        req.predicate = NSPredicate(format: "id == %@", id as CVarArg)
        if let ent = try context.fetch(req).first {
            ent.items?.forEach { $0.categories?.remove(ent) }
            context.delete(ent)
            try context.save()
        }
    }

    private func fetchOrCreateCategoryEntity(id: UUID) throws -> CategoryEntity {
        let req: NSFetchRequest<CategoryEntity> = CategoryEntity.fetchRequest()
        req.predicate = NSPredicate(format: "id == %@", id as CVarArg)
        if let existing = try context.fetch(req).first {
            return existing
        }
        let newEnt = CategoryEntity(context: context)
        newEnt.id = id
        return newEnt
    }

    private func fetchItemEntities(for categoryID: UUID) throws -> [ItemEntity] {
        let req: NSFetchRequest<ItemEntity> = ItemEntity.fetchRequest()
        req.predicate = NSPredicate(format: "ANY categories.id == %@", categoryID as CVarArg)
        return try context.fetch(req)
    }
}
