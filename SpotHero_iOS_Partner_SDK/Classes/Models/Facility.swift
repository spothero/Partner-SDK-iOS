//
//  Facility.swift
//  Pods
//
//  Created by Matthew Reed on 7/19/16.
//
//

import CoreLocation
import Foundation

/**
 *  Represents a facility
 */
struct Facility: Equatable {
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
    let defaultImageURL: String
    let restrictions: [String]
    let hoursOfOperation: HoursOfOperation
    let gettingHere: String
    let images: [CloudinaryImage]
    
    fileprivate var rates = [Rate]()
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
        
        let rateDictionaries = try json.shp_array("hourly_rates") as [JSONDictionary]
        for rateDictionary in rateDictionaries {
            let rate = try Rate(json: rateDictionary)
            rates.append(rate)
        }
        
        let details = try json.shp_dictionary("facility") as JSONDictionary
        self.city = try details.shp_string("city")
        self.state = try details.shp_string("state")
        self.streetAddress = try details.shp_string("street_address")
        self.defaultImageURL = try json.shp_string("default_image_url")
        self.restrictions = try details.shp_array("stripped_restrictions")
        let hoursOfOperationDictionary: JSONDictionary = try details.shp_dictionary("hours_of_operation")
        self.hoursOfOperation = try HoursOfOperation(json: hoursOfOperationDictionary)
        self.gettingHere = try details.shp_string("getting_here")
        let imageArray = try details.shp_array("images") as [JSONDictionary]
        self.images = try imageArray.map { try CloudinaryImage(json: $0) }
    }
    
    func displayPrice() -> String {
        guard let rate = self.rates.first else {
            assertionFailure("facility has no rates")
            return ""
        }
        
        return String(rate.displayPrice)
    }
}

//swiftlint:disable:next operator_whitespace
func ==(lhs: Facility, rhs: Facility) -> Bool {
    return lhs.parkingSpotID == rhs.parkingSpotID
}
