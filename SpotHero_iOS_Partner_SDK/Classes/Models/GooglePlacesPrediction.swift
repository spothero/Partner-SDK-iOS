//
//  GooglePlacesPrediction.swift
//  Pods
//
//  Created by Matthew Reed on 7/12/16.
//
//

import Foundation

/**
 *  Prediction of a google place
 */
struct GooglePlacesPrediction {
    let description: String
    let placeID: String
    let terms: [String]
}

extension GooglePlacesPrediction {
    init(json: JSONDictionary) throws {
        self.description = try json.shp_string("description")
        self.placeID = try json.shp_string("place_id")
        let terms = try json.shp_array("terms") as [JSONDictionary]
        self.terms = try terms.map { term in
            return try term.shp_string("value")
        }
    }
}
