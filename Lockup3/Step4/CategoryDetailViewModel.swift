import Foundation
import Combine

final class CategoryDetailViewModel: ObservableObject {
    @Published private(set) var category: Category
    @Published private(set) var items: [Item] = []
    @Published var errorMessage: String?

    private let persistence = PersistenceService.shared

    init(category: Category) {
        self.category = category
        loadItems()
    }

    func loadItems() {
        do {
            let all = try persistence.fetchItems()
            items = all.filter { $0.categoryIDs.contains(category.id) }
        } catch {
            errorMessage = "Failed to load items: \(error.localizedDescription)"
        }
    }

    func deleteCategory(completion: @escaping (Bool) -> Void) {
        do {
            try persistence.deleteCategory(id: category.id)
            completion(true)
        } catch {
            errorMessage = "Delete failed: \(error.localizedDescription)"
            completion(false)
        }
    }

    func updateCategory(_ updated: Category) {
        do {
            try persistence.saveCategory(updated)
            category = updated
        } catch {
            errorMessage = "Update failed: \(error.localizedDescription)"
        }
    }
}
