import Foundation

final class ItemCreateViewModel: ObservableObject {
    @Published var name: String = ""
    @Published var description: String = ""
    @Published var imageFileNames: [String] = []
    @Published var categoryIDs: [UUID] = []
    @Published var facilityID: UUID?

    var existing: Item?

    init(existing: Item? = nil) {
        if let existing = existing {
            self.existing = existing
            self.name = existing.name
            self.description = existing.description ?? ""
            self.imageFileNames = existing.imageFileNames
            self.categoryIDs = existing.categoryIDs
            self.facilityID = existing.facilityID
        }
    }

    func buildItem() -> Item {
        Item(
            id: existing?.id ?? UUID(),
            name: name,
            imageFileNames: imageFileNames,
            categoryIDs: categoryIDs,
            description: description.isEmpty ? nil : description,
            facilityID: facilityID
        )
    }
}
