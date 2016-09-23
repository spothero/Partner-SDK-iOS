//
//  Facility.swift
//  Pods
//
//  Created by Matthew Reed on 7/19/16.
//
//

import Foundation
import CoreLocation

/**
 *  Represents a facility
 */
struct Facility {
    let title: String
    let licensePlateRequired: Bool
    let parkingSpotID: Int
    let timeZone: String
    let location: CLLocation
    let phoneNumberRequired: Bool
    let city: String
    let state: String
    let streetAddress: String
    let distanceInMeters: Int
    
    private var rates = [Rate]()
    var availableRates: [Rate] {
        return self.rates.filter { $0.unavailable == false }
    }
}

extension Facility {
    init(json: JSONDictionary) throws {
        self.title = try json.shp_string("title")
        self.licensePlateRequired = try json.shp_bool("license_plate_required")
        self.parkingSpotID = try json.shp_int("parking_spot_id")
        self.timeZone = try json.shp_string("timezone")
        self.phoneNumberRequired = try json.shp_bool("phone_number_required")
        self.distanceInMeters = try json.shp_int("distance")
        
        let latitude = try json.shp_double("latitude")
        let longitude = try json.shp_double("longitude")
        self.location = CLLocation(latitude: latitude, longitude: longitude)
        
        if let rateDictionaries = try json.shp_array("hourly_rates") as? [JSONDictionary] {
            for rateDictionary in rateDictionaries {
                let rate = try Rate(json: rateDictionary)
                rates.append(rate)
            }
        }
        
        let details = try json.shp_dictionary("facility") as JSONDictionary
        self.city = try details.shp_string("city")
        self.state = try details.shp_string("state")
        self.streetAddress = try details.shp_string("street_address")
    }
    
    func displayPrice() -> String {
        guard let rate = self.rates.first else {
            assertionFailure("facility has no rates")
            return ""
        }
        
        return String(rate.displayPrice)
    }
}
