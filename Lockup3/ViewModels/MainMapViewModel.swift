import SwiftUI
import MapKit
import CoreData

@MainActor
@Observable
final class MainMapViewModel {
    var storageLocations: [StorageLocation] = []
    var selectedLocation: StorageLocation?
    var mapStyle: MapStyle = .standard(elevation: .realistic)
    var isLoading = false
    
    private let storageLocationRepo: StorageLocationRepository
    private let searchService: SearchService
    
    init(storageLocationRepo: StorageLocationRepository = StorageLocationRepository(),
         searchService: SearchService = SearchService()) {
        self.storageLocationRepo = storageLocationRepo
        self.searchService = searchService
    }
    
    func loadStorageLocations() async {
        isLoading = true
        
        do {
            let sortDescriptor = NSSortDescriptor(keyPath: \StorageLocation.name, ascending: true)
            storageLocations = try await storageLocationRepo.fetch(sortDescriptors: [sortDescriptor])
        } catch {
            print("Error loading storage locations: \(error)")
        }
        
        isLoading = false
    }
    
    func search(_ query: String) async {
        await searchService.search(query)
    }
    
    var searchResults: [SearchResult] {
        searchService.searchResults
    }
    
    var isSearching: Bool {
        searchService.isSearching
    }
}
