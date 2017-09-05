//
//  GooglePlacesWrapper.swift
//  Pods
//
//  Created by Matthew Reed on 7/12/16.
//
//

import CoreLocation
import Foundation

enum GooglePlacesError: Error {
    case
    noPredictions,
    cannotFormURL,
    placeDetailsNotFound
}

enum GooglePlacesQueryItem: String {
    case
    input,
    components,
    placeid,
    key,
    address
}

public enum ServerEndpoint {
    case
    predictions,
    place,
    geocode
    
    static let Host = "maps.googleapis.com"
    static let Scheme = "https"

    func fullURLString(withQueryItems queryItems: [URLQueryItem] = []) -> URL? {
        var urlComponents = URLComponents()
        urlComponents.host = ServerEndpoint.Host
        urlComponents.scheme = ServerEndpoint.Scheme
        switch self {
        case .predictions:
            urlComponents.path = "/maps/api/place/autocomplete/json"
        case .place:
            urlComponents.path = "/maps/api/place/details/json"
        case .geocode:
            urlComponents.path =  "/maps/api/geocode/json"
        }
        urlComponents.queryItems = queryItems
        return urlComponents.url
    }
}

typealias GooglePlacesWrapperCompletion = ([GooglePlacesPrediction], Error?) -> (Void)
typealias GooglePlaceDetailsCompletion = (GooglePlaceDetails?, Error?) -> (Void)
typealias GooglePlacesGeocodeCompletion = ([GooglePlaceDetails], Error?) -> (Void)

struct GooglePlacesWrapper {
    static var GoogleAPIKey: String?
    static let KeyQueryItem = URLQueryItem(name: "key", value: GooglePlacesWrapper.GoogleAPIKey)
    static let CountryQueryItem = URLQueryItem(name: GooglePlacesQueryItem.components.rawValue, value: "country:us")
    /**
     Finds Predictions based on a string
     
     - parameter input:      String to base predictions on
     - parameter location:   Location to find predictions near. Optional
     - parameter completion: Completion closure. Passes in array of predictions and possible error.
     */
    static func getPredictions(_ input: String,
                               location: CLLocation? = nil,
                               completion: @escaping GooglePlacesWrapperCompletion) {
        
        var queryItems = [
            URLQueryItem(name: GooglePlacesQueryItem.input.rawValue, value: input),
            CountryQueryItem,
            KeyQueryItem,
        ]
        
        if let location = location {
            let locationQueryItem = URLQueryItem(name: "location", value: "\(location.coordinate.latitude),\(location.coordinate.longitude)")
            queryItems.append(locationQueryItem)
        }
        
        if let url = ServerEndpoint.predictions.fullURLString(withQueryItems: queryItems) {
            SharedURLSession.sharedInstance.session.dataTask(with: url, completionHandler: {
                data, _, error in
                OperationQueue.main.addOperation {
                    guard let data = data else {
                        completion([], error)
                        return
                    }
                    
                    do {
                        let responseDictionary = try JSONSerialization.jsonObject(with: data) as? JSONDictionary
                        if let predictionDictionaries =
                            responseDictionary?["predictions"] as? [JSONDictionary],
                            !predictionDictionaries.isEmpty {
                                var predictions = [GooglePlacesPrediction]()
                                for predictionDictionary in predictionDictionaries {
                                    let predition = try GooglePlacesPrediction(json: predictionDictionary)
                                    predictions.append(predition)
                                }
                                completion(predictions, nil)
                        } else {
                            completion([], GooglePlacesError.noPredictions)
                        }
                    } catch let error {
                        completion([], error)
                    }
                }
            }).resume()
        } else {
            assertionFailure("Unable to form URL")
            OperationQueue.main.addOperation {
                completion([], GooglePlacesError.cannotFormURL)
            }
        }
    }
    
    /**
     Finds the place details based on a prediction
     
     - parameter prediction:  Prediction to find the details for
     - parameter completion: Completion closure. Passing in either the details or an error
     */
    static func getPlaceDetails(_ prediction: GooglePlacesPrediction, completion: @escaping GooglePlaceDetailsCompletion) {
        let queryItems = [
            URLQueryItem(name: GooglePlacesQueryItem.placeid.rawValue, value: prediction.placeID),
            KeyQueryItem,
        ]
        
        if let url = ServerEndpoint.place.fullURLString(withQueryItems: queryItems) {
            SharedURLSession.sharedInstance.session.dataTask(with: url, completionHandler: {
                data, _, error in
                OperationQueue.main.addOperation {
                    guard let data = data else {
                        completion(nil, error)
                        return
                    }
                    
                    do {
                        let responseDictionary = try JSONSerialization.jsonObject(with: data) as? JSONDictionary
                        if let placeDictionary = responseDictionary?["result"] as? JSONDictionary {
                            let placeDetails = try GooglePlaceDetails(json: placeDictionary)
                            completion(placeDetails, nil)
                        } else {
                            completion(nil, GooglePlacesError.placeDetailsNotFound)
                        }
                    } catch let error {
                        completion(nil, error)
                    }
                }
            }).resume()
        } else {
            assertionFailure("Unable to form URL")
            OperationQueue.main.addOperation {
                completion(nil, GooglePlacesError.cannotFormURL)
            }
        }
    }
    
    /**
     Finds the places details based on passed-in text
     
     - parameter address:  String to geocode into places
     - parameter completion: Completion closure. Passing in either an array of GooglePlaceDetails or an error
     */
    static func geocode(address: String, completion: @escaping GooglePlacesGeocodeCompletion) {
        let queryItems = [
            URLQueryItem(name: GooglePlacesQueryItem.address.rawValue, value: address),
            CountryQueryItem,
        ]
        
        if let url = ServerEndpoint.geocode.fullURLString(withQueryItems: queryItems) {
            SharedURLSession.sharedInstance.session.dataTask(with: url, completionHandler: {
                data, _, error in
                OperationQueue.main.addOperation {
                    guard let data = data else {
                        completion([], error)
                        return
                    }
                    
                    do {
                        let responseDictionary = try JSONSerialization.jsonObject(with: data) as? JSONDictionary
                        if let placesDictionaries = responseDictionary?["results"] as? [JSONDictionary] {
                            var places = [GooglePlaceDetails]()
                            for placeDictionary in placesDictionaries {
                                let place = try GooglePlaceDetails(json: placeDictionary)
                                places.append(place)
                            }
                            completion(places, nil)
                        } else {
                            completion([], GooglePlacesError.placeDetailsNotFound)
                        }
                    } catch let error {
                        completion([], error)
                    }
                }
            }).resume()
        } else {
            assertionFailure("Unable to form URL")
            OperationQueue.main.addOperation {
                completion([], GooglePlacesError.cannotFormURL)
            }
        }
    }
}
