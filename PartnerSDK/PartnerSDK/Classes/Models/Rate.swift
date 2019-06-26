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
    let isOnlineCommuterRate: Bool
    let onlineCommuterRateDescription: String?
    let onlineCommuterRateEnterStart: Date?
    let onlineCommuterRateEnterEnd: Date?
    
    // TODO add tests
    let duration: Double
    var appVisibleAmenities: [Amenity] {
        return self.amenities.filter { $0.visible }
    }

    fileprivate(set) var amenities = [Amenity]()
}

extension Rate {
    init(json: JSONDictionary) throws {
        self.displayPrice = try json.shp_int("display_price")
        self.unavailable = try json.shp_bool("unavailable")
        self.unavailableReason = try? json.shp_string("unavailable_reason")
        self.price = try json.shp_int("price")
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
        
        let amenityDictionaries = try json.shp_dictionary("amenities") as JSONDictionary
        for case let amenityDictionary as JSONDictionary in amenityDictionaries.values {
            self.amenities.append(try Amenity(json: amenityDictionary))
        }
        
        self.isOnlineCommuterRate = try json.shp_bool("online_commuter_rate")
        self.onlineCommuterRateDescription = try? json.shp_string("online_commuter_rate_description")
        
        let formatter = SHPDateFormatter.APIOnlineCommuter
        self.onlineCommuterRateEnterStart = try? json.shp_date(forKey: "online_commuter_rate_enter_start", usingFormatter: formatter)
        self.onlineCommuterRateEnterEnd = try? json.shp_date(forKey: "online_commuter_rate_enter_end", usingFormatter: formatter)
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
