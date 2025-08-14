import Foundation

final class CategoryCreateViewModel: ObservableObject {
    @Published var name: String = ""
    @Published var description: String = ""
    @Published var colorHex: String = "#000000"

    var existing: Category?

    init(existing: Category? = nil) {
        if let existing = existing {
            self.existing = existing
            self.name = existing.name
            self.description = existing.description ?? ""
            self.colorHex = existing.colorHex
        }
    }

    func buildCategory() -> Category {
        Category(
            id: existing?.id ?? UUID(),
            name: name,
            description: description.isEmpty ? nil : description,
            colorHex: colorHex
        )
    }
}
