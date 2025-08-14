import Foundation
import CoreData

@MainActor
final class ItemRepository: Repository {
    typealias Entity = Item
    
    private let context: NSManagedObjectContext
    
    init(context: NSManagedObjectContext = PersistenceController.shared.container.viewContext) {
        self.context = context
    }
    
    func create() async throws -> Item {
        let item = Item(context: context)
        item.id = UUID()
        item.createdAt = Date()
        item.updatedAt = Date()
        return item
    }
    
    func fetch(predicate: NSPredicate? = nil, 
               sortDescriptors: [NSSortDescriptor]? = nil) async throws -> [Item] {
        let request: NSFetchRequest<Item> = Item.fetchRequest()
        request.predicate = predicate
        request.sortDescriptors = sortDescriptors
        
        return try await context.perform {
            try self.context.fetch(request)
        }
    }
    
    func findByID(_ id: UUID) async throws -> Item? {
        let predicate = NSPredicate(format: "id == %@", id as CVarArg)
        let results = try await fetch(predicate: predicate)
        return results.first
    }
    
    func delete(_ entity: Item) async throws {
        await context.perform {
            self.context.delete(entity)
        }
    }
    
    func save() async throws {
        try await PersistenceController.shared.save()
    }
    
    // Item-specific methods
    func fetchItemsInLocation(_ locationID: UUID) async throws -> [Item] {
        let predicate = NSPredicate(format: "storageLocation.id == %@", locationID as CVarArg)
        let sortDescriptor = NSSortDescriptor(keyPath: \Item.name, ascending: true)
        return try await fetch(predicate: predicate, sortDescriptors: [sortDescriptor])
    }
    
    func bulkCreate(_ recognizedItems: [RecognizedItem], in location: StorageLocation) async throws -> [Item] {
        var items: [Item] = []
        
        for recognizedItem in recognizedItems {
            let item = try await create()
            item.name = recognizedItem.name
            item.recognitionConfidence = recognizedItem.confidence
            item.storageLocation = location
            items.append(item)
        }
        
        try await save()
        return items
    }
}
