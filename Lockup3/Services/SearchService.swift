import Foundation
import CoreData

@MainActor
final class SearchService: ObservableObject {
    @Published var searchResults: [SearchResult] = []
    @Published var isSearching = false
    
    private let context: NSManagedObjectContext
    private let storageLocationRepo: StorageLocationRepository
    private let itemRepo: ItemRepository
    private let categoryRepo: CategoryRepository
    
    init(context: NSManagedObjectContext = PersistenceController.shared.container.viewContext) {
        self.context = context
        self.storageLocationRepo = StorageLocationRepository(context: context)
        self.itemRepo = ItemRepository(context: context)
        self.categoryRepo = CategoryRepository(context: context)
    }
    
    func search(_ query: String) async {
        guard !query.isEmpty else {
            await MainActor.run {
                searchResults = []
            }
            return
        }
        
        isSearching = true
        
        async let locationResults = searchStorageLocations(query)
        async let itemResults = searchItems(query)
        async let categoryResults = searchCategories(query)
        
        let allResults = await locationResults + itemResults + categoryResults
        
        await MainActor.run {
            self.searchResults = allResults
            self.isSearching = false
        }
    }
    
    private func searchStorageLocations(_ query: String) async -> [SearchResult] {
        let predicate = NSPredicate(format: "name CONTAINS[cd] %@ OR address CONTAINS[cd] %@", query, query)
        
        do {
            let locations = try await storageLocationRepo.fetch(predicate: predicate)
            return locations.map { location in
                SearchResult(
                    title: location.name,
                    subtitle: location.address,
                    type: .storageLocation,
                    objectID: location.objectID
                )
            }
        } catch {
            print("Error searching locations: \(error)")
            return []
        }
    }
    
    private func searchItems(_ query: String) async -> [SearchResult] {
        let predicate = NSPredicate(format: "name CONTAINS[cd] %@ OR itemDescription CONTAINS[cd] %@", query, query)
        
        do {
            let items = try await itemRepo.fetch(predicate: predicate)
            return items.map { item in
                SearchResult(
                    title: item.name,
                    subtitle: item.storageLocation?.name ?? "No location",
                    type: .item,
                    objectID: item.objectID
                )
            }
        } catch {
            print("Error searching items: \(error)")
            return []
        }
    }
    
    private func searchCategories(_ query: String) async -> [SearchResult] {
        let predicate = NSPredicate(format: "name CONTAINS[cd] %@ OR categoryDescription CONTAINS[cd] %@", query, query)
        
        do {
            let categories = try await categoryRepo.fetch(predicate: predicate)
            return categories.map { category in
                SearchResult(
                    title: category.name,
                    subtitle: "\(category.itemsArray.count) items",
                    type: .category,
                    objectID: category.objectID
                )
            }
        } catch {
            print("Error searching categories: \(error)")
            return []
        }
    }
}
