//
//  APIKeyConfig.swift
//  Pods
//
//  Created by SpotHeroMatt on 10/4/16.
//
//

import Foundation

class APIKeyConfig {
    static let sharedInstance = APIKeyConfig()
    
    private (set) var googleApiKey = ""
    private (set) var stripeApiKey = ""
    private (set) var mixpanelApiKey = ""
    
    typealias APIKeyCompletion = (Bool) -> ()
    func getKeys(completion: APIKeyCompletion) {
        guard !TestingHelper.isUITesting() else {
            completion(true)
            return
        }
        
        let endpoint = "v1/mobile-config/iossdk"
        let headers = APIHeaders.defaultHeaders()
        SpotHeroPartnerAPIController.getJSONFromEndpoint(endpoint,
                                                         withHeaders: headers,
                                                         errorCompletion: {
                                                            error in
                                                            assertionFailure("Cannot get json, error \(error)")
                                                            completion(false)
            }) {
                JSON in
                do {
                    let data = try JSON.shp_dictionary("data") as JSONDictionary
                    self.googleApiKey = try data.shp_string("google_places_api_key")
                    GooglePlacesWrapper.GoogleAPIKey = self.googleApiKey
                    self.stripeApiKey = try data.shp_string("stripe_public_api_key")
                    self.mixpanelApiKey = try data.shp_string("mixpanel_api_key")
                    completion(true)
                } catch let error {
                    assertionFailure("Cannot parse json, error \(error)")
                    completion(false)
                }
        }
    }
}
