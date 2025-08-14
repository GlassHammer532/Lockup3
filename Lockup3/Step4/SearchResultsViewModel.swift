//
//  SearchResultsViewModel.swift
//  Lockup
//

import Foundation
import Combine

final class SearchResultsViewModel: ObservableObject {
    @Published private(set) var results: [SearchResult] = []
    @Published var errorMessage: String?

    let query: String
    private let persistence = PersistenceService.shared

    init(query: String) {
        self.query = query
        runSearch()
    }

    private func runSearch() {
        do {
            let facilities = try persistence.fetchFacilities()
                .filter { $0.name.localizedCaseInsensitiveContains(query) ||
                          $0.address.localizedCaseInsensitiveContains(query) }
                .map { SearchResult.facility($0) }

            let items = try persistence.fetchItems()
                .filter { $0.name.localizedCaseInsensitiveContains(query) ||
                          ($0.description?.localizedCaseInsensitiveContains(query) ?? false) }
                .map { SearchResult.item($0) }

            let categories = try persistence.fetchCategories()
                .filter { $0.name.localizedCaseInsensitiveContains(query) ||
                          ($0.description?.localizedCaseInsensitiveContains(query) ?? false) }
                .map { SearchResult.category($0) }

            // Combine and sort alphabetically
            self.results = (facilities + items + categories)
                .sorted { $0.title.localizedCaseInsensitiveCompare($1.title) == .orderedAscending }
        } catch {
            errorMessage = "Search failed: \(error.localizedDescription)"
        }
    }
}
