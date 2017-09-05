//
//  GooglePlaceDetails.swift
//  Pods
//
//  Created by Matthew Reed on 7/13/16.
//
//

import CoreLocation
import Foundation

/**
 *  Represents The details for a google place
 */
struct GooglePlaceDetails {
    let name: String?
    let placeID: String
    let types: [String]
    let location: CLLocation
    let formattedAddress: String
    
    func isAirport() -> Bool {
        return self.types.contains("airport")
    }
}

extension GooglePlaceDetails {
    enum JSONKey: String {
        case
        name,
        placeId = "place_id",
        formattedAddress = "formatted_address",
        types,
        geometry,
        location,
        lat,
        lng
    }
    
    init(json: JSONDictionary) throws {
        self.name = try? json.shp_string(JSONKey.name.rawValue)
        self.placeID = try json.shp_string(JSONKey.placeId.rawValue)
        self.formattedAddress = try json.shp_string(JSONKey.formattedAddress.rawValue)
        self.types = try json.shp_array(JSONKey.types.rawValue)
        let geometry = try json.shp_dictionary(JSONKey.geometry.rawValue) as JSONDictionary
        let location = try geometry.shp_dictionary(JSONKey.location.rawValue) as JSONDictionary
        let latitude = try location.shp_double(JSONKey.lat.rawValue)
        let longitude = try location.shp_double(JSONKey.lng.rawValue)
        self.location = CLLocation(latitude: latitude, longitude: longitude)
    }
}
