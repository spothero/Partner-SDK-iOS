//
//  GooglePlacesPredictionWrapper.swift
//  Pods
//
//  Created by Husein Kareem on 11/7/16.
//
//

import Foundation

/**
 *  Prediction of a google place
 */
public struct GooglePlacesPredictionWrapper {
    ///contains the human-readable name for the returned result
    public let predictionDescription: String
    //uniquely identify a place in the Google Places database and on Google Maps
    public let placeID: String
    //contains an array of terms identifying each section of the returned description
    public let terms: [String]
    
    public init(predictionDescription: String,
                placeID: String,
                terms: [String]) {
        self.predictionDescription = predictionDescription
        self.placeID = placeID
        self.terms = terms
    }
}
