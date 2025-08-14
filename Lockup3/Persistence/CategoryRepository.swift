import Foundation
import CoreData

@MainActor
final class CategoryRepository: Repository {
    typealias Entity = Category
    
    private let context: NSManagedObjectContext
    
    init(context: NSManagedObjectContext = PersistenceController.shared.container.viewContext) {
        self.context = context
    }
    
    func create() async throws -> Category {
        let category = Category(context: context)
        category.id = UUID()
        category.createdAt = Date()
        return category
    }
    
    func fetch(predicate: NSPredicate? = nil, 
               sortDescriptors: [NSSortDescriptor]? = nil) async throws -> [Category] {
        let request: NSFetchRequest<Category> = Category.fetchRequest()
        request.predicate = predicate
        request.sortDescriptors = sortDescriptors
        
        return try await context.perform {
            try self.context.fetch(request)
        }
    }
    
    func findByID(_ id: UUID) async throws -> Category? {
        let predicate = NSPredicate(format: "id == %@", id as CVarArg)
        let results = try await fetch(predicate: predicate)
        return results.first
    }
    
    func delete(_ entity: Category) async throws {
        await context.perform {
            self.context.delete(entity)
        }
    }
    
    func save() async throws {
        try await PersistenceController.shared.save()
    }
}
