//
//  FacilityAPI.swift
//  Pods
//
//  Created by Matthew Reed on 7/20/16.
//
//

import CoreLocation
import Foundation

/*
 - parameter facilities:    An array of the returned facilities. Will be empty on an error.
 - parameter error:         [Optional] Any error encountered, or nil if none was encountered.
 */
typealias FacilityCompletion = (_ facilities: [Facility], _ error: Error?) -> Void

typealias IdealSearchDistanceCompletion = (_ idealSearchDistance: Double?) -> Void

struct FacilityAPI {
    
    private struct Endpoints {
        static let facilities = "partner/v1/facilities/rates"
        static let idealSearchDistance = "v1/ideal-search-distance"
    }
    
    @discardableResult
    static func fetchIdealSearchDistanceForCoordinate(_ coordinate: CLLocationCoordinate2D,
                                                      completion: @escaping IdealSearchDistanceCompletion) -> URLSessionTask? {
        let errorCompletion: APIErrorCompletion = { error in
            // just call the completion with a nil value, we don't want to stop any searches if this fails.
            completion(nil)
        }
        let successCompletion: (JSONDictionary) -> Void = { json in
            do {
                let data = try json.shp_dictionary("data") as JSONDictionary
                if let distance = data["ideal_search_distance"] as? String {
                    completion(Double(distance))
                } else {
                    completion(nil)
                }
            } catch {
                completion(nil)
            }
        }
        return SpotHeroPartnerAPIController.getJSONFromEndpoint(Endpoints.idealSearchDistance,
                                                                withHeaders: APIHeaders.defaultHeaders(),
                                                                additionalParams: coordinate.asParameters(),
                                                                errorCompletion: errorCompletion,
                                                                successCompletion: successCompletion)
    }
    
    /**
     Returns the facilities near a given location within a range of dates
     
     - parameter location:   location to find facilities near
     - parameter starts:     when the reservation shold start
     - parameter ends:       when the reservation should end
     - parameter completion: closure to call after each page of results is loaded.
     */
    @discardableResult
    static func fetchFacilities(_ coordinate: CLLocationCoordinate2D,
                                starts: Date,
                                ends: Date,
                                minSearchRadius: Int = 0,
                                maxSearchRadius: Double = UnitsOfMeasurement.metersPerMile.rawValue,
                                completion: @escaping FacilityCompletion) -> URLSessionTask? {
        
        let startsString = SHPDateFormatter.ISO8601NoSeconds.string(from: starts)
        let endsString = SHPDateFormatter.ISO8601NoSeconds.string(from: ends)
        
        let headers = APIHeaders.defaultHeaders()
        
        var params = coordinate.asParameters()
        params["starts"] = startsString
        params["ends"] = endsString
        params["distance__gt"] = "\(minSearchRadius)"
        params["distance__lt"] = "\(maxSearchRadius)"
        params["include"] = "facility,facility.images,facility.stripped_restrictions"
        
        let successCompletion: JSONAPISuccessCompletion = { json in
            do {
                let data = try json.shp_dictionary("data") as JSONDictionary
                let results = try data.shp_array("results") as [JSONDictionary]
                let facilities: [Facility] = results.compactMap { dictionary in
                    guard let facility = try? Facility(json: dictionary) else {
                        return nil
                    }
                    // while we are iterating facilities, filter out ones that don't have rates
                    return facility.availableRates.isEmpty ? nil : facility
                }
                completion(facilities, nil)
            } catch {
                completion([], error)
            }
        }
        
        let errorCompletion: APIErrorCompletion = { error in
            if error.code != URLError.cancelled.rawValue {
                completion([], error)
            }
        }
        
        return SpotHeroPartnerAPIController.getJSONFromEndpoint(Endpoints.facilities,
                                                                withHeaders: headers,
                                                                additionalParams: params,
                                                                errorCompletion: errorCompletion,
                                                                successCompletion: successCompletion)
    }
}

private extension CLLocationCoordinate2D {
    func asParameters() -> [String: String] {
        return [
            "latitude" : "\(self.latitude)",
            "longitude" : "\(self.longitude)",
        ]
    }
}
