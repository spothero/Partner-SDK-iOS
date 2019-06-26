//
//  GooglePlacesWrapper+SpotHeroPartner.swift
//  SpotHero_iOS_Partner_SDK
//
//  Created by Matthew Reed on 12/20/17.
//

import Foundation

extension GooglePlacesWrapper {
    /**
     Finds the place details based on a city
     
     - parameter city: City to find details for
     - parameter completion: Completion closure. Passing in either the details or an error
     */
    static func getPlaceDetails(_ city: City, completion: @escaping GooglePlaceDetailsCompletion) {
        self.geocode(address: city.title) { places, error in
            completion(places.first, error)
        }
    }
}
