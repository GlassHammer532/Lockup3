//
//  Item.swift
//  Lockup
//
//  Created by YourName on 08/2025.
//

import Foundation

public struct Item: Identifiable, Codable {
    public let id: UUID
    public var name: String
    public var imageFileNames: [String]
    public var categoryIDs: [UUID]
    public var description: String?
    public var facilityID: UUID?

    public init(
        id: UUID = .init(),
        name: String,
        imageFileNames: [String] = [],
        categoryIDs: [UUID] = [],
        description: String? = nil,
        facilityID: UUID? = nil
    ) {
        self.id = id
        self.name = name
        self.imageFileNames = imageFileNames
        self.categoryIDs = categoryIDs
        self.description = description
        self.facilityID = facilityID
    }
}
