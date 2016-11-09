//
//  GooglePlacesAPIWrapper.swift
//  Pods
//
//  Created by Husein Kareem on 11/4/16.
//
//

import Foundation
import CoreLocation

public class GooglePlacesAPIWrapper {
    ///Completion closure. Passes in array of predictions and possible error.
    public typealias GooglePlacesPredictionWrapperCompletion = ([GooglePlacesPredictionWrapper], ErrorType?) -> (Void)
    ///Completion closure. Passing in either the details or an error
    public typealias GooglePlaceDetailsWrapperCompletion = (GooglePlaceDetailsWrapper?, ErrorType?) -> (Void)
    
    /**
     Stores the Google API Key
     
     - parameter key:      API key string
     */
    public static func storeGoogleAPIKey(key: String) {
        GooglePlacesWrapper.GoogleAPIKey = key
    }
    
    /**
     Finds Predictions based on a string
     
     - parameter input:      String to base predictions on
     - parameter location:   Location to find predictions near. Optional
     - parameter completion: Completion closure. Passes in array of predictions and possible error.
     */
    public static func getPredictions(input: String,
                                      location: CLLocation? = nil,
                                      completion: GooglePlacesPredictionWrapperCompletion) {
        GooglePlacesWrapper.getPredictions(input, location: location) {
            predictions, error in
            
            if let error = error {
                completion([], error)
            } else {
                var predictionsWrapper = [GooglePlacesPredictionWrapper]()
                predictions.map({
                    prediction in
                    
                    let predictionWrapper = GooglePlacesPredictionWrapper(predictionDescription: prediction.predictionDescription,
                                                                          placeID: prediction.placeID,
                                                                          terms: prediction.terms)
                    predictionsWrapper.append(predictionWrapper)
                })
                
                completion(predictionsWrapper, nil)
            }
        }
    }
    
    /**
     Finds the place details based on a prediction
     
     - parameter prediction:  Prediction to find the details for
     - parameter completion: Completion closure. Passing in either the details or an error
     */
    public static func getPlaceDetails(prediction: GooglePlacesPredictionWrapper, completion: GooglePlaceDetailsWrapperCompletion) {
        let googlePlacesPrediction = GooglePlacesPrediction(predictionDescription: prediction.predictionDescription,
                                                            placeID: prediction.placeID,
                                                            terms: prediction.terms)
        GooglePlacesWrapper.getPlaceDetails(googlePlacesPrediction) {
            placeDetails, error in
            
            if let error = error {
                completion(nil, error)
            } else {
                if let placeDetails = placeDetails {
                    let placeDetailsWrapper = GooglePlaceDetailsWrapper(name: placeDetails.name,
                                                                        placeID: placeDetails.placeID,
                                                                        types: placeDetails.types,
                                                                        location: placeDetails.location)
                    completion(placeDetailsWrapper, nil)
                }
            }
        }
    }
}
