//
//  CLLocation+SpotHeroPartner.swift
//  SpotHero_iOS_Partner_SDK
//
//  Created by Matt on 2/25/18.
//

import CoreLocation
import Foundation

typealias TimeZoneCompletion = (_ timeZone: TimeZone) -> Void

extension CLLocation {
    //TODO: This needs to be refactored apparently, CR-1536
    func shp_timeZone(completion: @escaping TimeZoneCompletion) {
        let geocoder = CLGeocoder()
        geocoder.reverseGeocodeLocation(self, completionHandler: {
            placemarks, _ in
            
            if let timeZone = placemarks?.last?.timeZone {
                completion(timeZone)
            } else {
                completion(TimeZone.current)
            }
        })
    }
}
