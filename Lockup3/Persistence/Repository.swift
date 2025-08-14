import Foundation
import CoreData

protocol Repository {
    associatedtype Entity: NSManagedObject
    
    func create() async throws -> Entity
    func fetch(predicate: NSPredicate?, sortDescriptors: [NSSortDescriptor]?) async throws -> [Entity]
    func findByID(_ id: UUID) async throws -> Entity?
    func delete(_ entity: Entity) async throws
    func save() async throws
}
