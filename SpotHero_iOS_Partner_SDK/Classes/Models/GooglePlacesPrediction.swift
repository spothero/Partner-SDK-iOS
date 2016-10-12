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
@objc(SPHGooglePlacesPrediction)
class GooglePlacesPrediction: NSObject {
    let predictionDescription: String
    let placeID: String
    let terms: [String]
    
    init(json: JSONDictionary) throws {
        self.predictionDescription = try json.shp_string("description")
        self.placeID = try json.shp_string("place_id")
        let terms = try json.shp_array("terms") as [JSONDictionary]
        self.terms = try terms.map { term in
            return try term.shp_string("value")
        }
    }
    
    init(predictionDescription: String,
         placeID: String,
         terms: [String]) {
        self.predictionDescription = predictionDescription
        self.placeID = placeID
        self.terms = terms
    }
}
