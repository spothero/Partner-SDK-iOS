//
//  Facility.swift
//  Pods
//
//  Created by SpotHeroMatt on 7/19/16.
//
//

import Foundation
import CoreLocation

struct Facility {
    let title: String
    let licensePlateRequired: Bool
    let parkingSpotID: Int
    let timeZone: String
    let location: CLLocation
    let phoneNumberRequired: Bool
    
    var rates = [Rate]()
}

extension Facility {
    init(json: JSONDictionary) throws {
        self.title = try json.shp_string("title")
        self.licensePlateRequired = try json.shp_bool("license_plate_required")
        self.parkingSpotID = try json.shp_int("parking_spot_id")
        self.timeZone = try json.shp_string("timezone")
        self.phoneNumberRequired = try json.shp_bool("phone_number_required")
        
        let latitude = try json.shp_double("latitude")
        let longitude = try json.shp_double("longitude")
        self.location = CLLocation(latitude: latitude, longitude: longitude)
        
        if let rateDictionaries = try json.shp_array("hourly_rates") as? [JSONDictionary] {
            for rateDictionary in rateDictionaries {
                let rate = try Rate(json: rateDictionary)
                rates.append(rate)
            }
        }
    }
}
