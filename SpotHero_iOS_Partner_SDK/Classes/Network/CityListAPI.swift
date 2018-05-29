//
//  CityListAPI.swift
//  SpotHero_iOS_Partner_SDK
//
//  Created by Matthew Reed on 12/8/17.
//

import CoreLocation
import Foundation

struct CityListAPI {
    enum JSONKey: String {
        case
        data,
        results
    }
    
    typealias CityCompletion = (_ cities: [City]) -> Void
    
    private(set) static var cities = [City]()
    
    static func getCities(completion: CityCompletion? = nil) {
        let headers = APIHeaders.defaultHeaders()
        SpotHeroPartnerAPIController.getJSONFromEndpoint("/v1/cities/",
                                                         withHeaders: headers,
                                                         additionalParams: nil,
                                                         errorCompletion: {
                                                            _ in
                                                            completion?([])
                                                         },
                                                         successCompletion: {
                                                            json in
                                                            guard
                                                                let data: JSONDictionary = try? json.shp_dictionary(JSONKey.data.rawValue),
                                                                let results: [JSONDictionary] = try? data.shp_array(JSONKey.results.rawValue) else {
                                                                    completion?([])
                                                                    return
                                                            }
                                                            
                                                            let cities: [City] = results
                                                                .compactMap { City(json: $0) }
                                                                .filter { $0.isSpotHeroCity }
                                                                .sorted { $0.title < $1.title }
                                                            
                                                            self.cities = cities
                                                            completion?(cities)
                                                         })
    }
}
