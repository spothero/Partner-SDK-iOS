//
//  UnitsOfMeasurement.swift
//  Pods
//
//  Created by Husein Kareem on 9/23/16.
//
//

import Foundation

enum UnitsOfMeasurement: Double {
    case
    MetersPerMile = 1609.344,
    ApproximateMilesPerDegreeOfLatitude = 69.0 //http://gis.stackexchange.com/a/142327/45816
    
    /**
     Takes in meters and returns the distance in miles.
     
     - parameter meters:  number of meters
     - returns: distance in miles as a double
     */
    static func distanceInMiles(meters: Double) -> Double {
        return meters / UnitsOfMeasurement.MetersPerMile.rawValue
    }
}
