//
//  FacilityCreateViewModel.swift
//  Lockup
//

import Foundation

final class FacilityCreateViewModel: ObservableObject {
    @Published var name: String = ""
    @Published var address: String = ""
    @Published var type: FacilityType = .permanent
    @Published var dimensions: RoomDimensions?

    var existingFacility: StorageFacility?

    init(existing: StorageFacility? = nil) {
        if let facility = existing {
            self.existingFacility = facility
            self.name = facility.name
            self.address = facility.address
            self.type = facility.type
            self.dimensions = facility.dimensions
        }
    }

    func save() -> StorageFacility {
        StorageFacility(id: existingFacility?.id ?? UUID(),
                        name: name,
                        address: address,
                        coordinate: existingFacility?.coordinate ?? .init(),
                        type: type,
                        dimensions: dimensions)
    }
}
