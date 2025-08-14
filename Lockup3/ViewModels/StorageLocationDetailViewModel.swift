import SwiftUI
import CoreData

@MainActor
@Observable
final class StorageLocationDetailViewModel {
    var storageLocation: StorageLocation
    var items: [Item] = []
    var isLoading = false
    var isEditing = false
    
    private let itemRepo: ItemRepository
    private let storageLocationRepo: StorageLocationRepository
    
    init(storageLocation: StorageLocation,
         itemRepo: ItemRepository = ItemRepository(),
         storageLocationRepo: StorageLocationRepository = StorageLocationRepository()) {
        self.storageLocation = storageLocation
        self.itemRepo = itemRepo
        self.storageLocationRepo = storageLocationRepo
    }
    
    func loadItems() async {
        isLoading = true
        
        do {
            items = try await itemRepo.fetchItemsInLocation(storageLocation.id)
        } catch {
            print("Error loading items: \(error)")
        }
        
        isLoading = false
    }
    
    func deleteItem(_ item: Item) async {
        do {
            try await itemRepo.delete(item)
            await loadItems()
        } catch {
            print("Error deleting item: \(error)")
        }
    }
    
    func transferItem(_ item: Item, to newLocation: StorageLocation) async {
        do {
            item.storageLocation = newLocation
            item.updatedAt = Date()
            try await itemRepo.save()
            await loadItems()
        } catch {
            print("Error transferring item: \(error)")
        }
    }
    
    func deleteLocation() async {
        // Transfer all items to a default location or handle deletion
        do {
            try await storageLocationRepo.delete(storageLocation)
        } catch {
            print("Error deleting location: \(error)")
        }
    }
}
