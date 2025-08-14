//
//  ItemDetailViewModel.swift
//  Lockup
//

import Foundation
import Combine

final class ItemDetailViewModel: ObservableObject {
    @Published var item: Item
    @Published var errorMessage: String?

    private let persistence = PersistenceService.shared

    init(item: Item) {
        self.item = item
    }

    func deleteItem() {
        do {
            try persistence.deleteItem(id: item.id)
        } catch {
            errorMessage = "Failed to delete item: \(error.localizedDescription)"
        }
    }

    func updateItem(_ updated: Item) {
        do {
            try persistence.saveItem(updated)
            item = updated
        } catch {
            errorMessage = "Failed to update item: \(error.localizedDescription)"
        }
    }
}
