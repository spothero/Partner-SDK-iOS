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
    public var predictionDescription: String
    //uniquely identify a place in the Google Places database and on Google Maps
    public var placeID: String
    //contains an array of terms identifying each section of the returned description
    public var terms: [String]
}
