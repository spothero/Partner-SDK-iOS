//
//  Rate.swift
//  Pods
//
//  Created by Matthew Reed on 7/19/16.
//
//

import Foundation

/**
 *  Represents the Hourly Rates of a Facility 
 */
struct Rate {
    let displayPrice: Int
    let starts: Date
    let ends: Date
    let unavailable: Bool
    let price: Int
    let ruleGroupID: Int
    let unavailableReason: String?
    // TODO add tests
    let duration: Double

    // TODO: Change to struct or enum
    let amenities: JSONDictionary
}

extension Rate {
    init(json: JSONDictionary) throws {
        self.displayPrice = try json.shp_int("display_price")
        self.unavailable = try json.shp_bool("unavailable")
        self.unavailableReason = try? json.shp_string("unavailable_reason")
        self.price = try json.shp_int("price")
        self.amenities = try json.shp_dictionary("amenities") as JSONDictionary
        self.ruleGroupID = try json.shp_int("rule_group_id")
        self.duration = try json.shp_double("duration")
        
        let startsString = try json.shp_string("starts")
        if let starts = SHPDateFormatter.ISO8601NoSeconds.date(from: startsString) {
            self.starts = starts
        } else {
            assertionFailure("Cannot parse start time")
            self.starts = Date()
        }
        
        let endsString = try json.shp_string("ends")
        if let ends = SHPDateFormatter.ISO8601NoSeconds.date(from: endsString) {
            self.ends = ends
        } else {
            assertionFailure("Cannot parse end time")
            self.ends = Date()
        }
    }
    
    func isWheelchairAccessible() -> Bool {
        guard
            let wheelchairDict = self.amenities["wheelchair"] as? [String: Any],
            let visible = wheelchairDict["visible"] as? Bool else {
                return false
        }
        
        return visible
    }
    
    func allowsReentry() -> Bool {
        return self.amenities["in-out"] != nil
    }
    
    // TODO: add unit tests for this
    func minutesToReservation() -> Int {
        return Calendar
            .current
            .dateComponents([.minute],
                            from: Date(),
                            to: self.starts)
            .minute ?? 0
    }
}
