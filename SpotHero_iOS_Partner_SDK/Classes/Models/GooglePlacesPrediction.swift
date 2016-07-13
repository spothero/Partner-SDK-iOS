//
//  GooglePlacesPrediction.swift
//  Pods
//
//  Created by SpotHeroMatt on 7/12/16.
//
//

import Foundation

struct GooglePlacesPrediction {
    let description: String
    let placeID: String
}

extension GooglePlacesPrediction {
    init(json: JSONDictionary) throws {
        self.description = try json.shp_string("description")
        self.placeID = try json.shp_string("place_id")
    }
}
