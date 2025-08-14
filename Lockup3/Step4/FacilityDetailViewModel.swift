//
//  FacilityDetailViewModel.swift
//  Lockup
//
//  Created by YourName on 08/2025.
//

import Foundation
import Combine

final class FacilityDetailViewModel: ObservableObject {
    @Published private(set) var facility: StorageFacility
    @Published private(set) var items: [Item] = []
    @Published var errorMessage: String?

    private let persistence = PersistenceService.shared
    private var cancellables = Set<AnyCancellable>()

    init(facility: StorageFacility) {
        self.facility = facility
        loadItems()
    }

    func loadItems() {
        do {
            let all = try persistence.fetchItems()
            items = all.filter { $0.facilityID == facility.id }
        } catch {
            errorMessage = "Failed to load items: \(error.localizedDescription)"
        }
    }

    func deleteFacility(completion: @escaping (Bool) -> Void) {
        do {
            try persistence.deleteFacility(id: facility.id)
            completion(true)
        } catch {
            errorMessage = "Delete failed: \(error.localizedDescription)"
            completion(false)
        }
    }

    func deleteItem(_ item: Item) {
        do {
            try persistence.deleteItem(id: item.id)
            loadItems()
        } catch {
            errorMessage = "Failed to delete item: \(error.localizedDescription)"
        }
    }

    func transferItem(_ item: Item, to newFacilityID: UUID) {
        var updated = item
        updated.facilityID = newFacilityID
        do {
            try persistence.saveItem(updated)
            loadItems()
        } catch {
            errorMessage = "Transfer failed: \(error.localizedDescription)"
        }
    }

    func updateFacility(_ updated: StorageFacility) {
        do {
            try persistence.saveFacility(updated)
            facility = updated
        } catch {
            errorMessage = "Update failed: \(error.localizedDescription)"
        }
    }
}
