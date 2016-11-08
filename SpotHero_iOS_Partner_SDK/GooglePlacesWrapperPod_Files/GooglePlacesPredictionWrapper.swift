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
public class GooglePlacesPredictionWrapper {
    public let predictionDescription: String
    public let placeID: String
    public let terms: [String]
    
    public init(predictionDescription: String,
                placeID: String,
                terms: [String]) {
        self.predictionDescription = predictionDescription
        self.placeID = placeID
        self.terms = terms
    }
}
