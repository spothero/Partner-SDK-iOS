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
public struct GooglePlaceDetailsWrapper {
    ///A term to be matched against all content that Google has indexed for this place
    public var name: String
    //uniquely identify a place in the Google Places database and on Google Maps
    public var placeID: String
    ///contains an array of types that apply to this place
    public var types: [String]
    ///The latitude/longitude around which to retrieve place information
    public var location: CLLocation
}
