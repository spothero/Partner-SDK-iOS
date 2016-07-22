//
//  Rate.swift
//  Pods
//
//  Created by SpotHeroMatt on 7/19/16.
//
//

import Foundation

//enum Amenities: String {
////    case 
//}

struct Rate {
    let displayPrice: Double
    let starts: NSDate
    let ends: NSDate
    let unavailable: Bool
    let price: Double
    let amenities: JSONDictionary
    let unavailableReason: String?
}

extension Rate {
    init(json: JSONDictionary) throws {
        self.displayPrice = try json.shp_double("display_price")
        self.unavailable = try json.shp_bool("unavailable")
        self.unavailableReason = try? json.shp_string("unavailable_reason")
        self.price = try json.shp_double("price")
        self.amenities = try json.shp_dictionary("amenities") as JSONDictionary
        
        let startsString = try json.shp_string("starts")
        if let starts = Constants.dateFormatter.dateFromString(startsString) {
            self.starts = starts
        } else {
            assertionFailure("Cannot parse start time")
            self.starts = NSDate()
        }
        
        let endsString = try json.shp_string("ends")
        if let ends = Constants.dateFormatter.dateFromString(endsString) {
            self.ends = ends
        } else {
            assertionFailure("Cannot parse end time")
            self.ends = NSDate()
        }
    }
}
