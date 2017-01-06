//
//  GooglePlaceDetails.swift
//  Pods
//
//  Created by Matthew Reed on 7/13/16.
//
//

import Foundation
import CoreLocation

/**
 *  Represents The details for a google place
 */
struct GooglePlaceDetails {
    let name: String
    let placeID: String
    let types: [String]
    let location: CLLocation
    
    func isAirport() -> Bool {
        return self.types.contains("airport")
    }
}

extension GooglePlaceDetails {
    init(json: JSONDictionary) throws {
        self.name = try json.shp_string("name")
        self.placeID = try json.shp_string("place_id")
        self.types = try json.shp_array("types")
        let geometry = try json.shp_dictionary("geometry") as JSONDictionary
        let location = try geometry.shp_dictionary("location") as JSONDictionary
        let latitude = try location.shp_double("lat")
        let longitude = try location.shp_double("lng")
        self.location = CLLocation(latitude: latitude, longitude: longitude)
    }
}
