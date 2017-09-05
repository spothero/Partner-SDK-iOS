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
    enum Test {
        static let CreditCardNumber = "4242424242424242"
        static let ExpirationMonth = "12"
        static let ExpirationYear = "2020"
        static let CVC = "123"
        
        //swiftlint:disable force_unwrapping (we want this to fail fast)
        static let StartDate = SHPDateFormatter.ISO8601NoSeconds.date(from: "2016-10-13T19:16")!
        static let EndDate = SHPDateFormatter.ISO8601NoSeconds.date(from: "2016-10-14T00:16")!
        static let ReservationStartDate = SHPDateFormatter.ISO8601NoMillisecondsUTC.date(from: "2016-08-02T00:08:00Z")!
        static let ReservationEndDate = SHPDateFormatter.ISO8601NoMillisecondsUTC.date(from: "2016-08-02T05:08:00Z")!
        //swiftlint:enable force_unwrapping
        
        static let ButtonTitle = "Payment Button"
    }
        
    enum Segue {
        static let Confirmation = "confirmation"
    }
}
