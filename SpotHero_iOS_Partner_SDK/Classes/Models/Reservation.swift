//
//  Reservation.swift
//  Pods
//
//  Created by Matthew Reed on 7/22/16.
//
//

import Foundation

/**
 *  Represents a reservation
 */
struct Reservation {
    let status: String
    let rentalID: Int
    let starts: NSDate
    let ends: NSDate
    let price: Double
    let receiptAccessKey: String
}

extension Reservation {
    init(json: JSONDictionary) throws {
        self.status = try json.shp_string("reservation_status")
        self.rentalID = try json.shp_int("rental_id")
        self.price = try json.shp_double("price")
        
        //TODO: Figure out better way to get this key
        let cancelURLString = try json.shp_string("cancel_url")
        if let cancelURLComponents = NSURLComponents(string: cancelURLString), key = cancelURLComponents.queryItems?.first?.value {
            self.receiptAccessKey = key
        } else {
            assertionFailure("Could not get receipt access key")
            self.receiptAccessKey = ""
        }
        
        let startsString = try json.shp_string("starts")
        if let starts = DateFormatter.ISO8601NoMillisecondsUTC.dateFromString(startsString) {
            self.starts = starts
        } else {
            assertionFailure("Cannot parse start time")
            self.starts = NSDate()
        }
        
        let endsString = try json.shp_string("ends")
        if let ends = DateFormatter.ISO8601NoMillisecondsUTC.dateFromString(endsString) {
            self.ends = ends
        } else {
            assertionFailure("Cannot parse end time")
            self.ends = NSDate()
        }
    }
}
