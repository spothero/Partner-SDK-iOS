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
    let starts: Date
    let ends: Date
    let price: Double
    let receiptAccessKey: String
    let partnerRenterCardToken: String?
}

extension Reservation {
    init(json: JSONDictionary) throws {
        self.status = try json.shp_string("reservation_status")
        self.rentalID = try json.shp_int("rental_id")
        self.price = try json.shp_double("price")
        
        //TODO: Figure out better way to get this key
        let cancelURLString = try json.shp_string("cancel_url")
        if let cancelURLComponents = URLComponents(string: cancelURLString), let key = cancelURLComponents.queryItems?.first?.value {
            self.receiptAccessKey = key
        } else {
            assertionFailure("Could not get receipt access key")
            self.receiptAccessKey = ""
        }
        
        let startsString = try json.shp_string("starts")
        if let starts = SHPDateFormatter.ISO8601NoMillisecondsUTC.date(from: startsString) {
            self.starts = starts
        } else {
            assertionFailure("Cannot parse start time")
            self.starts = Date()
        }
        
        let endsString = try json.shp_string("ends")
        if let ends = SHPDateFormatter.ISO8601NoMillisecondsUTC.date(from: endsString) {
            self.ends = ends
        } else {
            assertionFailure("Cannot parse end time")
            self.ends = Date()
        }
        
        self.partnerRenterCardToken = try? json.shp_string("partner_renter_card_token")
        //Save partner renter card token to keychain
        if
            let partnerRenterCardToken = self.partnerRenterCardToken,
            let username = UserDefaultsWrapper.username {
                let keychainItem = KeychainPasswordItem(account: username)
                try keychainItem.savePassword(partnerRenterCardToken)
        } else if UserDefaultsWrapper.username == nil {
            // Clear Info if we don't get the token and there's no user saved
            UserDefaultsWrapper.clearUserInfo()
        }
    }
}
