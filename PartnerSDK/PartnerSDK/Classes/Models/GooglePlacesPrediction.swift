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
    let predictionDescription: String
    let placeID: String
    let terms: [String]
}

extension GooglePlacesPrediction {
    enum JSONKey: String {
        case
        description,
        placeId = "place_id",
        terms,
        value
    }
    
    init(json: JSONDictionary) throws {
        self.predictionDescription = try json.shp_string(JSONKey.description.rawValue)
        self.placeID = try json.shp_string(JSONKey.placeId.rawValue)
        let terms = try json.shp_array(JSONKey.terms.rawValue) as [JSONDictionary]
        self.terms = try terms.map { term in
            return try term.shp_string(JSONKey.value.rawValue)
        }
    }
}
