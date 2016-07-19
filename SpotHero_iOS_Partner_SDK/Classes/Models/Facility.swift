//
//  Facility.swift
//  Pods
//
//  Created by SpotHeroMatt on 7/19/16.
//
//

import Foundation

struct Facility {
    var rates = [Rate]()
    let licensePlateRequired: Int
    let parkingSpotID: Int
}

extension Facility {
    init(json: JSONDictionary) throws {
        self.licensePlateRequired = try json.shp_int("license_plate_required")
        self.parkingSpotID = try json.shp_int("parking_spot_id")
        if let rateDictionaries = try json.shp_array("hourly_rates") as? [JSONDictionary] {
            for rateDictionary in rateDictionaries {
                let rate = try Rate(json: rateDictionary)
                rates.append(rate)
            }
        }
    }
}
