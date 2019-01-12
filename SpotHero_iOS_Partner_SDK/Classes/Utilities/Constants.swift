//
//  Constants.swift
//  Pods
//
//  Created by Husein Kareem on 7/13/16.
//
//

import CoreLocation
import Foundation

enum Constants {
    static let HuronStLocation = CLLocation(latitude: 41.894503, longitude: -87.636659)
    static let ChicagoLocation = CLLocation(latitude: 41.8797756, longitude: -87.6303326)
    static let ViewAnimationDuration: TimeInterval = 0.3
    static let ThirtyMinutesInSeconds: TimeInterval = 30 * 60
    static let SecondsInHour: TimeInterval = 60 * 60
    static let SixHoursInSeconds: TimeInterval = 6 * Constants.SecondsInHour
    static let MaxSearchRadiusInMeters = UnitsOfMeasurement.metersPerMile.rawValue * 60.0
    
    enum Segue {
        static let Confirmation = "confirmation"
    }
}
