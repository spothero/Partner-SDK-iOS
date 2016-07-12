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
}

extension GooglePlacesPrediction {
    init(json: JSONDictionary) throws {
        self.description = try json.shp_string("description")
    }
}
