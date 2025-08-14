//
//  FacilityType.swift
//  Lockup3
//
//  Created by Felix Clissold on 14/08/2025.
//


//
//  Models.swift
//  Lockup
//
//  Created by YourName on 08/2025.
//

import Foundation
import CoreLocation

// MARK: – FacilityType

public enum FacilityType: String, Codable {
    case permanent
    case temporary
}

// MARK: – RoomShape

public enum RoomShape: String, Codable {
    case rectangle
    case lShaped
}

// MARK: – RoomDimensions

public struct RoomDimensions: Codable {
    public var width: Double
    public var length: Double
    public var height: Double
    public var shape: RoomShape

    public init(width: Double, length: Double, height: Double, shape: RoomShape) {
        self.width = width
        self.length = length
        self.height = height
        self.shape = shape
    }
}

// MARK: – StorageFacility

public struct StorageFacility: Identifiable, Codable {
    public let id: UUID
    public var name: String
    public var address: String
    public var coordinate: CLLocationCoordinate2D
    public var type: FacilityType
    public var dimensions: RoomDimensions?
    public var items: [UUID]

    public init(
        id: UUID = .init(),
        name: String,
        address: String,
        coordinate: CLLocationCoordinate2D,
        type: FacilityType,
        dimensions: RoomDimensions? = nil,
        items: [UUID] = []
    ) {
        self.id = id
        self.name = name
        self.address = address
        self.coordinate = coordinate
        self.type = type
        self.dimensions = dimensions
        self.items = items
    }
}

// MARK: – Item

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

// MARK: – Category

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
