import Foundation

public struct Category: Identifiable, Codable {
    public let id: UUID
    public var name: String
    public var description: String?
    public var colorHex: String

    public init(
        id: UUID = .init(),
        name: String,
        description: String? = nil,
        colorHex: String
    ) {
        self.id = id
        self.name = name
        self.description = description
        self.colorHex = colorHex
    }
}
