//
//  MixpanelWrapper.swift
//  Pods
//
//  Created by SpotHeroMatt on 10/10/16.
//
//

import Foundation

struct MixpanelWrapper {
    private static let baseUrlString = "http://api.mixpanel.com/track/"
    
    static func track(event: String, properties: [String: AnyObject]) {
        var mutableProperties = properties
        mutableProperties["token"] = APIKeyConfig.sharedInstance.mixpanelApiKey
        let eventDictionary = ["event": event, "properties": mutableProperties]
        
        do {
            let jsonData = try NSJSONSerialization.dataWithJSONObject(eventDictionary, options: [])
            let base64 = jsonData.base64EncodedStringWithOptions([])
            let urlComponents = NSURLComponents(string: baseUrlString)
            urlComponents?.query = "data=\(base64)"
            if let url = urlComponents?.URL {
                NSURLSession.sharedSession().dataTaskWithURL(url, completionHandler: {
                    data, response, error in
                    if let error = error {
                        print(error)
                    } else {
                        print(data)
                    }
                })
            } else {
                assertionFailure("Cannot create url")
            }
        } catch {
            assertionFailure("Invalid JSON")
        }
    }
}
