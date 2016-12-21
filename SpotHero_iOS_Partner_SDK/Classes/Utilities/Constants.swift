//
//  Constants.swift
//  Pods
//
//  Created by Husein Kareem on 7/13/16.
//
//

import Foundation
import CoreLocation

enum Constants {
    static let ChicagoLocation = CLLocation(latitude: 41.894503, longitude: -87.636659)
    static let ViewAnimationDuration: NSTimeInterval = 0.3
    static let ThirtyMinutesInSeconds: NSTimeInterval = 30 * 60
    static let SecondsInHour: NSTimeInterval = 60 * 60
    static let SixHoursInSeconds: NSTimeInterval = 6 * Constants.SecondsInHour
    static let MaxSearchRadiusInMeters = UnitsOfMeasurement.MetersPerMile.rawValue * 60.0
    enum Test {
        static let CreditCardNumber = "4242424242424242"
        static let ExpirationMonth = "12"
        static let ExpirationYear = "2020"
        static let CVC = "123"
        static let StartDate = DateFormatter.ISO8601NoSeconds.dateFromString("2016-10-13T19:16")!
        static let EndDate = DateFormatter.ISO8601NoSeconds.dateFromString("2016-10-14T00:16")!
        static let ReservationStartDate = DateFormatter.ISO8601NoMillisecondsUTC.dateFromString("2016-08-02T00:08:00Z")!
        static let ReservationEndDate = DateFormatter.ISO8601NoMillisecondsUTC.dateFromString("2016-08-02T05:08:00Z")!
        static let ButtonTitle = "Payment Button"
    }
    
    
    enum Segue {
        static let Confirmation = "confirmation"
    }
}
