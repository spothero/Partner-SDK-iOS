//
//  Rate.swift
//  Pods
//
//  Created by SpotHeroMatt on 7/19/16.
//
//

import Foundation

struct Rate {
    let displayPrice: Double
    let starts: String
    let ends: String
    let unavailable: Bool
    let price: Double
    let amenities: String
}

extension Rate {
    init(json: JSONDictionary) throws {
        self.displayPrice = try json.shp_double("display_price")
        self.starts = try json.shp_string("starts")
        self.ends = try json.shp_string("ends")
        self.unavailable = try json.shp_bool("unavailable")
        self.price = try json.shp_double("price")
        self.amenities = try json.shp_string("amenities")
    }
}
