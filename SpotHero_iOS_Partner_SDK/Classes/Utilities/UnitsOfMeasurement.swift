//
//  UnitsOfMeasurement.swift
//  Pods
//
//  Created by Husein Kareem on 9/23/16.
//
//

import Foundation

enum UnitsOfMeasurement {
    /**
     Takes in meters and returns the distance in miles.
     
     - parameter meters:  number of meters
     - returns: distance in miles as a double
     */
    static func distanceInMiles(meters: Double) -> Double {
        return meters / 1609.344
    }
}
