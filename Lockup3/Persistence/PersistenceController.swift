import CoreData
import CloudKit

@MainActor
final class PersistenceController: ObservableObject {
    static let shared = PersistenceController()
    
    lazy var container: NSPersistentCloudKitContainer = {
        let container = NSPersistentCloudKitContainer(name: "LockupDataModel")
        
        // CloudKit configuration
        let storeDescription = container.persistentStoreDescriptions.first!
        storeDescription.setOption(true as NSNumber, forKey: NSPersistentHistoryTrackingKey)
        storeDescription.setOption(true as NSNumber, forKey: NSPersistentStoreRemoteChangeNotificationPostOptionKey)
        
        container.loadPersistentStores { _, error in
            if let error = error {
                fatalError("Core Data error: \(error.localizedDescription)")
            }
        }
        
        container.viewContext.automaticallyMergesChangesFromParent = true
        return container
    }()
    
    func save() async throws {
        let context = container.viewContext
        
        if context.hasChanges {
            try await context.perform {
                try context.save()
            }
        }
    }
    
    func newBackgroundContext() -> NSManagedObjectContext {
        return container.newBackgroundContext()
    }
}
