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
    metersPerMile = 1_609.344
    /**
     Takes in meters and returns the distance in miles.
     
     - parameter meters:  number of meters
     - returns: distance in miles as a double
     */
    static func distanceInMiles(_ meters: Double) -> Double {
        return meters / UnitsOfMeasurement.metersPerMile.rawValue
    }
}
