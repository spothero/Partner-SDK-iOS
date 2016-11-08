//
//  GooglePlaceDetailsWrapper.swift
//  Pods
//
//  Created by Husein Kareem on 11/7/16.
//
//

import Foundation
import CoreLocation

/**
 *  Represents The details for a google place
 */
public class GooglePlaceDetailsWrapper {
    public let name: String
    public let placeID: String
    public let types: [String]
    public let location: CLLocation
    
    public init(name: String,
                placeID: String,
                types: [String],
                location: CLLocation) {
        self.name = name
        self.placeID = placeID
        self.types = types
        self.location = location
    }
}
