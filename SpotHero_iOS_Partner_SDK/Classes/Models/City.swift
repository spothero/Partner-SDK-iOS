//
//  City.swift
//  SpotHero_iOS_Partner_SDK
//
//  Created by Matthew Reed on 12/8/17.
//

import CoreLocation
import Foundation

struct City {
    let identifier: Int
    let title: String
    let slug: String
    let location: CLLocation
    let isSpotHeroCity: Bool
    
    //swiftlint:disable identifier_name
    enum JSONKey: String {
        case
        id,
        title,
        slug,
        latitude,
        longitude,
        is_spothero_city
    }
    //swiftlint:enable identifier_name
}

extension City {
    init?(json: JSONDictionary) {
        guard
            let id = json[JSONKey.id.rawValue] as? Int,
            let title = json[JSONKey.title.rawValue] as? String,
            let slug = json[JSONKey.slug.rawValue] as? String,
            let latitude = json[JSONKey.latitude.rawValue] as? Double,
            let longitude = json[JSONKey.longitude.rawValue] as? Double,
            let isSpotHeroCity = json[JSONKey.is_spothero_city.rawValue] as? Bool else {
                return nil
        }
        
        let location = CLLocation(latitude: latitude, longitude: longitude)
        self.init(identifier: id,
                  title: title,
                  slug: slug,
                  location: location,
                  isSpotHeroCity: isSpotHeroCity)
    }
}
