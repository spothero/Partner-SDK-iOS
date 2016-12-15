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

/*
 - parameter facilities:    An array of the returned facilities. Will be empty on an error.
 - parameter error:         [Optional] Any error encountered, or nil if none was encountered.
 - parameter hasMorePages:  true if there are more pages of facilities to load, false if not.
 */
typealias FacilityCompletion = (facilities: [Facility],
                                error: ErrorType?,
                                hasMorePages: Bool) -> (Void)

struct FacilityAPI {
    private static var NextURLString: String?
    private static var DataTasks = [NSURLSessionDataTask]()
    
    /// Cancel all facility requests
    static func stopSearching() {
        self.DataTasks.forEach { $0.cancel() }
        self.DataTasks.removeAll()
    }
    
    
    /// Check if currently searching faclities
    ///
    /// - Returns: true is currently searching
    static func searching() -> Bool {
        return !self.DataTasks.isEmpty
    }
    
    /**
     Returns the facilities near a given location within a range of dates
     
     - parameter location:   location to find facilities near
     - parameter starts:     when the reservation shold start
     - parameter ends:       when the reservation should end
     - parameter completion: closure to call after each page of results is loaded.
     */
    static func fetchFacilities(coordinate: CLLocationCoordinate2D,
                                starts: NSDate,
                                ends: NSDate,
                                minSearchRadius: Int = 0,
                                maxSearchRadius: Double = UnitsOfMeasurement.MetersPerMile.rawValue,
                                completion: FacilityCompletion) {
        UIApplication.sharedApplication().networkActivityIndicatorVisible = true
        
        let startDate: NSDate
        let endDate: NSDate
        if NSClassFromString("KIFTestCase") == nil {
            startDate = starts
            endDate = ends
        } else {
            startDate = Constants.Test.startDate
            endDate = Constants.Test.endDate
        }
        
        let startsString = DateFormatter.ISO8601NoSeconds.stringFromDate(startDate)
        let endsString = DateFormatter.ISO8601NoSeconds.stringFromDate(endDate)
        
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
            "include" : "facility",
        ]
        
        self.stopSearching()
        
        let dataTask = SpotHeroPartnerAPIController.getJSONFromEndpoint("partner/v1/facilities/rates",
                                                                        withHeaders: headers,
                                                                        additionalParams: params,
                                                                        errorCompletion: {
                                                                            error in
                                                                            if error.code != NSURLError.Cancelled.rawValue {
                                                                                completion(facilities: [],
                                                                                    error: error,
                                                                                    hasMorePages: false)
                                                                            }
                                                                        },
                                                                        successCompletion: self.facilityFetchSuccessHandler(completion))

        if let dataTask = dataTask {
            self.DataTasks.append(dataTask)
        }
    }
    
    private static func mapJSON(JSON: JSONDictionary) -> (facilities: [Facility],
                                                          error: ErrorType?,
                                                          nextURLString: String?) {
        do {
            let actualData = try JSON.shp_dictionary("data") as JSONDictionary
            let metaData = try JSON.shp_dictionary("meta") as JSONDictionary
            let results = try actualData.shp_array("results") as [JSONDictionary]
            
            let facilities = results.flatMap { return try? Facility(json: $0) }
            
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
        FacilityAPI.NextURLString = urlString
        let dataTask = SpotHeroPartnerAPIController.getJSONFromFullURLString(urlString,
                                                                             withHeaders: APIHeaders.defaultHeaders(),
                                                                             errorCompletion: {
                                                                                error in
                                                                                if error.code != NSURLError.Cancelled.rawValue {
                                                                                    completion(facilities: [],
                                                                                        error: error,
                                                                                        hasMorePages: false)
                                                                                }
                                                                             },
                                                                             successCompletion: self.facilityFetchSuccessHandler(completion))
        
        if let dataTask = dataTask {
            self.DataTasks.append(dataTask)
        }
    }
    
    private static func facilityFetchSuccessHandler(completion: FacilityCompletion) -> JSONAPISuccessCompletion {
        return {
            JSON in

            let mappedJSON = FacilityAPI.mapJSON(JSON)
            let facilitiesWithRates = mappedJSON.facilities
            let error = mappedJSON.error
            
            guard let nextURLString = mappedJSON.nextURLString
                    where nextURLString != FacilityAPI.NextURLString else {
                //We're done loading, hide the activity indicator and reset the next URL string
                UIApplication.sharedApplication().networkActivityIndicatorVisible = false
                FacilityAPI.NextURLString = nil
                                                
                // Call the completion block and let them know we're out of pages.
                completion(facilities: facilitiesWithRates, error: error, hasMorePages: false)
                self.DataTasks.removeAll()
                return
            }
            
            //Call the completion block, but let them know we have more pages.
            completion(facilities: facilitiesWithRates, error: error, hasMorePages: true)
            
            //Get said more pages.
            FacilityAPI.fetchFacilitiesFromNextURLString(nextURLString,
                                                         prevFacilities: facilitiesWithRates,
                                                         completion: completion)
            
        }
    }
}
