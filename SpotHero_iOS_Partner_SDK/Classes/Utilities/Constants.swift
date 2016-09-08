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
    static let ThirtyMinutesInSeconds: NSTimeInterval = 1800
    static let SecondsInHour: NSTimeInterval = 3600
    static let TestCreditCardNumber = "4242424242424242"
    static let TestExpirationMonth = "12"
    static let TestExpirationYear = "2020"
    static let TestCVC = "123"
    enum Segue {
        static let Confirmation = "confirmation"
    }
}
