//
//  RestaurantItem.swift
//  AllTrailsAtLunch
//
//  Created by Evelyn C Cordner on 6/2/20.
//  Copyright © 2020 EvelynCordner. All rights reserved.
//

import Foundation
import MapKit

class Restaurant: NSObject, MKAnnotation, Decodable {
    var id: String
    var name: String
    var rating: Double
    var numberOfRatings: Int
    var location: Coordinate
    var photos: [Photo]?
        
    enum CodingKeys: String, CodingKey {
        case id
        case name
        case rating
        case numberOfRatings = "user_ratings_total"
        case location = "geometry"
        case photos
    }
    
    var title: String? {
        return name
    }
    
    var coordinate: CLLocationCoordinate2D {
        return CLLocationCoordinate2D(latitude: location.latitude, longitude: location.longitude)
    }
}

struct GooglePlacesResult: Decodable {
    var results: [Restaurant]
    
    enum codingKeys: String, CodingKey {
        case results
    }
}

struct Coordinate {
    var latitude: Double
    var longitude: Double
    
    enum CodingKeys: String, CodingKey {
        case location
    }
    
    enum LocationKeys: String, CodingKey {
        case latitude = "lat"
        case longitude = "lng"
    }
}

extension Coordinate: Decodable {
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        let location = try values.nestedContainer(keyedBy: LocationKeys.self, forKey: .location)
        latitude = try location.decode(Double.self, forKey: .latitude)
        longitude = try location.decode(Double.self, forKey: .longitude)
    }
}

struct Photo: Decodable {
    var reference: String
    
    enum CodingKeys: String, CodingKey {
        case reference = "photo_reference"
    }
}
