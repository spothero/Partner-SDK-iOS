//
//  FaciltyAPI.swift
//  Pods
//
//  Created by Matthew Reed on 7/20/16.
//
//

import Foundation
import CoreLocation

enum FacilityError: ErrorType {
    case NoFacilitiesFound
}

typealias FacilityCompletion = ([Facility], ErrorType?) -> (Void)

struct FacilityAPI {
    static var NextURLString: String?
    
    /**
     Returns the facilities near a given location within a range of dates
     
     - parameter location:   location to find facilities near
     - parameter starts:     when the reservation shold start
     - parameter ends:       when the reservation should end
     - parameter completion: closure to call after network call is made. passes in an array of facilities or an error
     */
    static func fetchFacilities(coordinate: CLLocationCoordinate2D,
                                starts: NSDate,
                                ends: NSDate,
                                minSearchRadius: Int = 0,
                                maxSearchRadius: Double = Constants.MetersPerMile,
                                completion: FacilityCompletion) {
        UIApplication.sharedApplication().networkActivityIndicatorVisible = true
        
        let startsString = DateFormatter.ISO8601NoSeconds.stringFromDate(starts)
        let endsString = DateFormatter.ISO8601NoSeconds.stringFromDate(ends)
        
        let latitude = "\(coordinate.latitude)"
        let longitude = "\(coordinate.longitude)"
        
        let headers = APIHeaders.defaultHeaders()
        let params = [
            "longitude" : longitude,
            "latitude" : latitude,
            "starts" : startsString,
            "ends" : endsString,
            "distance__gt" : "\(minSearchRadius)",
            "distance__lt" : "\(maxSearchRadius)",
            "include" : "facility"
        ]
        
        SpotHeroPartnerAPIController.getJSONFromEndpoint("partner/v1/facilities/rates",
                                                         withHeaders: headers,
                                                         additionalParams: params,
                                                         errorCompletion: {
                                                            error in
                                                            completion([], error)
                                                         },
                                                         successCompletion: self.facilityFetchSuccessHandler(completion))
    }
    
    private static func mapJSON(JSON: JSONDictionary) -> (facilities: [Facility], error: ErrorType?, nextURLString: String?) {
        do {
            let actualData = try JSON.shp_dictionary("data") as JSONDictionary
            let metaData = try JSON.shp_dictionary("meta") as JSONDictionary
            let results = try actualData.shp_array("results") as [JSONDictionary]
            var facilities = [Facility]()
            for result in results {
                let facility = try Facility(json: result)
                facilities.append(facility)
            }
            
            let facilitiesWithRates = facilities.filter { !$0.availableRates.isEmpty }
            var nextURLString = metaData["next"] as? String
            if !facilitiesWithRates.isEmpty {
                if nextURLString == FacilityAPI.NextURLString {
                    nextURLString = nil
                }
                return (facilitiesWithRates, nil, nextURLString)
            } else {
                return ([], FacilityError.NoFacilitiesFound, nextURLString)
            }
        } catch let error {
            return ([], error, nil)
        }
    }
    
    private static func fetchFacilitiesFromNextURLString(urlString: String,
                                                         prevFacilities: [Facility],
                                                         completion: FacilityCompletion) {
        UIApplication.sharedApplication().networkActivityIndicatorVisible = true
        FacilityAPI.NextURLString = urlString
        SpotHeroPartnerAPIController.getJSONFromFullURLString(urlString,
                                                              withHeaders: APIHeaders.defaultHeaders(),
                                                              errorCompletion: {
                                                                error in
                                                                completion([], error)
                                                              },
                                                              successCompletion: self.facilityFetchSuccessHandler(completion))
    }
    
    private static func facilityFetchSuccessHandler(completion: FacilityCompletion) -> JSONAPISuccessCompletion {
        return {
            JSON in
            UIApplication.sharedApplication().networkActivityIndicatorVisible = false

            let mappedJSON = FacilityAPI.mapJSON(JSON)
            let facilitiesWithRates = mappedJSON.facilities
            let error = mappedJSON.error
            completion(facilitiesWithRates, error)
            
            guard let nextURLString = mappedJSON.nextURLString else {
                return
            }
            
            FacilityAPI.fetchFacilitiesFromNextURLString(nextURLString,
                                                         prevFacilities: facilitiesWithRates,
                                                         completion: {
                                                            facilities, error in
                                                            completion(facilities, error)
            })

        }
    }
}
