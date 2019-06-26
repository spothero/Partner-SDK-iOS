//
//  GooglePlacesPrediction+SpotHeroPartner.swift
//  SpotHero_iOS_Partner_SDK
//
//  Created by Matt on 2/26/18.
//

import Foundation

extension GooglePlacesPrediction {
    func timeZone(completion: @escaping TimeZoneCompletion) {
        GooglePlacesWrapper.getPlaceDetails(self) { placeDetails, _ in
            if let placeDetails = placeDetails {
                placeDetails.location.shp_timeZone(completion: completion)
            }
        }
    }
}
