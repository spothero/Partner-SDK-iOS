//
//  Config.swift
//  Pods
//
//  Created by SpotHeroMatt on 10/4/16.
//
//

import Foundation

class Config {
    static let sharedInstance = Config()
    
    var googleApiKey = ""
    var stripeApiKey = ""
    var mixpanelApiKey = ""
    
    typealias APIKeyCompletion = (Bool) -> ()
    func getKeys(completion: APIKeyCompletion) {
        let endpoint = "api/v1/mobile-config/iossdk/"
        let headers = APIHeaders.defaultHeaders()
        SpotHeroPartnerAPIController.getJSONFromEndpoint(endpoint,
                                                         withHeaders: headers,
                                                         errorCompletion: {
                                                            error in
                                                            completion(false)
            }) {
                JSON in
                guard
                    let data = JSON["data"] as? [String: AnyObject],
                    let googleApiKey = data["google_places_api_key"] as? String,
                    let stripeApiKey = data["stripe_public_api_key"] as? String,
                    let mixpanelApiKey = data["mixpanel_api_key"] as? String else {
                        completion(false)
                        return
                }
                
                self.googleApiKey = googleApiKey
                self.stripeApiKey = stripeApiKey
                self.mixpanelApiKey = mixpanelApiKey
                completion(true)
        }
    }
}
