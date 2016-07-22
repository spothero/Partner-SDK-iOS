//
//  FaciltyAPI.swift
//  Pods
//
//  Created by SpotHeroMatt on 7/20/16.
//
//

import Foundation
import CoreLocation

enum FacilityError: ErrorType {
    case NoFacilitiesFound
}

struct FacilityAPI {
    static func fetchFacilities(location: CLLocation,
                                starts: NSDate,
                                ends: NSDate,
                                completion: ([Facility], ErrorType?) -> (Void)) {
        let startsString = Constants.dateFormatter.stringFromDate(starts)
        let endsString = Constants.dateFormatter.stringFromDate(ends)
        
        let latitude = "\(location.coordinate.latitude)"
        let longitude = "\(location.coordinate.longitude)"
        
        let headers = APIHeaders.defaultHeaders()
        let params = [
            "longitude" : longitude,
            "latitude" : latitude,
            "starts" : startsString,
            "ends" : endsString
        ]
        
        SpotHeroPartnerAPIController.getJSONFromEndpoint("partner/v1/facilities/rates",
                                                         withHeaders: headers,
                                                         additionalParams: params,
                                                         errorCompletion: {
                                                            error in
                                                            completion([], error)
        }) {
            JSON in
            if let results = JSON["results"] as? [JSONDictionary] {
                var facilities = [Facility]()
                do {
                    for result in results {
                        let facility = try Facility(json: result)
                        facilities.append(facility)
                    }
                    if facilities.count > 0 {
                        completion(facilities, nil)
                    } else {
                        completion([], FacilityError.NoFacilitiesFound)
                    }
                } catch let error {
                    completion([], error)
                }
                
            }
        }
    }
}
