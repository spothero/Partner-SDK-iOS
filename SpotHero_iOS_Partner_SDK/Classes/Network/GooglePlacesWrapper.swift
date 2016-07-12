//
//  GooglePlacesWrapper.swift
//  Pods
//
//  Created by SpotHeroMatt on 7/12/16.
//
//

import Foundation
import CoreLocation

typealias GooglePlacesWrapperCompletion = ([GooglePlacesPrediction]) -> (Void)

struct GooglePlacesWrapper {
    static func getPredictions(input: String, location: CLLocation? = nil, completion: GooglePlacesWrapperCompletion) {
        let urlComponents = NSURLComponents()
        urlComponents.host = "maps.googleapis.com"
        urlComponents.scheme = "https"
        urlComponents.path = "/maps/api/place/autocomplete/json"
        urlComponents.queryItems = [
            NSURLQueryItem(name: "input", value: input),
            NSURLQueryItem(name: "key", value: "AIzaSyCJSVbplK6bGdyV-8YvuEQS-VpU7E_qduY")
        ]
        
        if let location = location {
            let locationQueryItem = NSURLQueryItem(name: "location", value: "\(location.coordinate.latitude),\(location.coordinate.longitude)")
            urlComponents.queryItems?.append(locationQueryItem)
        }
        
        if let url = urlComponents.URL {
            NSURLSession.sharedSession().dataTaskWithURL(url, completionHandler: { (data, response, error) in
                guard let data = data else {
                    return
                }
                
                do {
                    let responseDictionary = try NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions()) as? JSONDictionary
                    if let predictionDictionaries = responseDictionary?["predictions"] as? [JSONDictionary] {
                        var predictions = [GooglePlacesPrediction]()
                        for predictionDictionary in predictionDictionaries {
                            let predition = try GooglePlacesPrediction(json: predictionDictionary)
                            predictions.append(predition)
                        }
                        completion(predictions)
                    }
                } catch {
                    // TODO: Handle errors
                }
            }).resume()
        } else {
            assertionFailure("Unable to form URL")
        }
    }
}
