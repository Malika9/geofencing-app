//
//  GeoRegion.swift
//  GeofencingApp
//
//  Created by vinmac on 23/09/19.
//  Copyright © 2019 vinmac. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

enum EventType: String {
    case onEntry = "On Entry"
    case onExit = "On Exit"
}
enum CodingKeys: String, CodingKey {
    case latitude, longitude, radius, identifier, note, eventType
}

class GeoRegion: NSObject, MKAnnotation, Codable {
    var coordinate: CLLocationCoordinate2D
    var radius: CLLocationDistance
    var identifier: String
    var note: String
    var eventType: EventType
    
    var title: String? {
        if note.isEmpty {
            return ""
        }
        return note
    }
    
    var subtitle: String? {
        let eventTypeString = eventType.rawValue
        return "Radius: \(radius)m - \(eventTypeString)"
    }
    
    init(coordinate: CLLocationCoordinate2D, radius: CLLocationDistance, identifier: String, note: String, eventType: EventType) {
        self.coordinate = coordinate
        self.radius = radius
        self.identifier = identifier
        self.note = note
        self.eventType = eventType
    }
    
    // MARK: Codable
    required init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        let latitude = try values.decode(Double.self, forKey: .latitude)
        let longitude = try values.decode(Double.self, forKey: .longitude)
        coordinate = CLLocationCoordinate2DMake(latitude, longitude)
        radius = try values.decode(Double.self, forKey: .radius)
        identifier = try values.decode(String.self, forKey: .identifier)
        note = try values.decode(String.self, forKey: .note)
        let event = try values.decode(String.self, forKey: .eventType)
        eventType = EventType(rawValue: event) ?? .onEntry
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(coordinate.latitude, forKey: .latitude)
        try container.encode(coordinate.longitude, forKey: .longitude)
        try container.encode(radius, forKey: .radius)
        try container.encode(identifier, forKey: .identifier)
        try container.encode(note, forKey: .note)
        try container.encode(eventType.rawValue, forKey: .eventType)
    }
    
    public static func allGeoRegions() -> [GeoRegion] {
        guard let savedData = UserDefaults.standard.data(forKey: Utilities.savedItems) else { return [] }
        let decoder = JSONDecoder()
        if let savedGeoRegions = try? decoder.decode(Array.self, from: savedData) as [GeoRegion] {
            return savedGeoRegions
        }
        return []
    }
}

