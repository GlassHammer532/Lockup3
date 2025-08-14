import Foundation
import CoreData

@MainActor
final class StorageLocationRepository: Repository {
    typealias Entity = StorageLocation
    
    private let context: NSManagedObjectContext
    
    init(context: NSManagedObjectContext = PersistenceController.shared.container.viewContext) {
        self.context = context
    }
    
    func create() async throws -> StorageLocation {
        let location = StorageLocation(context: context)
        location.id = UUID()
        location.createdAt = Date()
        location.updatedAt = Date()
        return location
    }
    
    func fetch(predicate: NSPredicate? = nil, 
               sortDescriptors: [NSSortDescriptor]? = nil) async throws -> [StorageLocation] {
        let request: NSFetchRequest<StorageLocation> = StorageLocation.fetchRequest()
        request.predicate = predicate
        request.sortDescriptors = sortDescriptors
        
        return try await context.perform {
            try self.context.fetch(request)
        }
    }
    
    func findByID(_ id: UUID) async throws -> StorageLocation? {
        let predicate = NSPredicate(format: "id == %@", id as CVarArg)
        let results = try await fetch(predicate: predicate)
        return results.first
    }
    
    func delete(_ entity: StorageLocation) async throws {
        await context.perform {
            self.context.delete(entity)
        }
    }
    
    func save() async throws {
        try await PersistenceController.shared.save()
    }
}
