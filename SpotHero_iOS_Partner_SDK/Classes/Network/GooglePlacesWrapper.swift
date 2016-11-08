//
//  GooglePlacesWrapper.swift
//  Pods
//
//  Created by Matthew Reed on 7/12/16.
//
//

import Foundation
import CoreLocation

enum GooglePlacesError: ErrorType {
    case
    NoPredictions,
    CannotFormURL,
    PlaceDetailsNotFound
}

typealias GooglePlacesWrapperCompletion = ([GooglePlacesPrediction], ErrorType?) -> (Void)
typealias GooglePlaceDetailsCompletion = (GooglePlaceDetails?, ErrorType?) -> (Void)

@objc(SPHGooglePlacesWrapper)
class GooglePlacesWrapper: NSObject {
    static let Host = "maps.googleapis.com"
    static let Scheme = "https"
    static var GoogleAPIKey: String?
    static let KeyQueryItem = NSURLQueryItem(name: "key", value: GooglePlacesWrapper.GoogleAPIKey)
    
    /**
     Finds Predictions based on a string
     
     - parameter input:      String to base predictions on
     - parameter location:   Location to find predictions near. Optional
     - parameter completion: Completion closure. Passes in array of predictions and possible error.
     */
    static func getPredictions(input: String,
                               location: CLLocation? = nil,
                               completion: GooglePlacesWrapperCompletion) {
        let urlComponents = NSURLComponents()
        urlComponents.host = Host
        urlComponents.scheme = Scheme
        urlComponents.path = "/maps/api/place/autocomplete/json"
        urlComponents.queryItems = [
            NSURLQueryItem(name: "input", value: input),
            KeyQueryItem
        ]
        
        if let location = location {
            let locationQueryItem = NSURLQueryItem(name: "location", value: "\(location.coordinate.latitude),\(location.coordinate.longitude)")
            urlComponents.queryItems?.append(locationQueryItem)
        }
        
        if let url = urlComponents.URL {
            NSURLSession.sharedSession().dataTaskWithURL(url, completionHandler: {
                data, response, error in
                NSOperationQueue.mainQueue().addOperationWithBlock {
                    guard let data = data else {
                        completion([], error)
                        return
                    }
                    
                    do {
                        let responseDictionary = try NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions()) as? JSONDictionary
                        if let predictionDictionaries =
                            responseDictionary?["predictions"] as? [JSONDictionary] where !predictionDictionaries.isEmpty {
                            var predictions = [GooglePlacesPrediction]()
                            for predictionDictionary in predictionDictionaries {
                                let predition = try GooglePlacesPrediction(json: predictionDictionary)
                                predictions.append(predition)
                            }
                            completion(predictions, nil)
                        } else {
                            completion([], GooglePlacesError.NoPredictions)
                        }
                    } catch let error {
                        completion([], error)
                    }
                }
            }).resume()
        } else {
            assertionFailure("Unable to form URL")
            NSOperationQueue.mainQueue().addOperationWithBlock() {
                completion([], GooglePlacesError.CannotFormURL)
            }
        }
    }
    
    /**
     Finds the place details based on a prediction
     
     - parameter prediction:  Prediction to find the details for
     - parameter completion: Completion closure. Passing in either the details or an error
     */
    static func getPlaceDetails(prediction: GooglePlacesPrediction, completion: GooglePlaceDetailsCompletion) {
        let urlComponents = NSURLComponents()
        urlComponents.host = Host
        urlComponents.scheme = Scheme
        urlComponents.path = "/maps/api/place/details/json"
        urlComponents.queryItems = [
            NSURLQueryItem(name: "placeid", value: prediction.placeID),
            KeyQueryItem
        ]
        
        if let url = urlComponents.URL {
            NSURLSession.sharedSession().dataTaskWithURL(url, completionHandler: {
                data, response, error in
                NSOperationQueue.mainQueue().addOperationWithBlock() {
                    guard let data = data else {
                        completion(nil, error)
                        return
                    }
                    
                    do {
                        let responseDictionary = try NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions()) as? JSONDictionary
                        if let placeDictionary = responseDictionary?["result"] as? JSONDictionary {
                            let placeDetails = try GooglePlaceDetails(json: placeDictionary)
                            completion(placeDetails, nil)
                        } else {
                            completion(nil, GooglePlacesError.PlaceDetailsNotFound)
                        }
                    } catch let error {
                        completion(nil, error)
                    }
                }
            }).resume()
        } else {
            assertionFailure("Unable to form URL")
            NSOperationQueue.mainQueue().addOperationWithBlock() {
                completion(nil, GooglePlacesError.CannotFormURL)
            }
        }
    }
}
