//
//  ServerEnvironment.swift
//  SpotHero_iOS_Partner_SDK
//
//  Created by Ellen Shapiro (Work) on 6/29/16.
//
//

import Foundation

public enum ServerEnvironment {
    case
    Staging,
    Production,
    Custom(baseURL: String) // Must be passed in as https://whatevs.com (no /api) to work
    
    /// What environment should we be pointed at?
    public static var CurrentEnvironment = ServerEnvironment.Staging
    
    /// Should the API debugPrint the info?
    public static var ShouldDebugPrintInfo = true
    
    //MARK: SpotHero API
    
    func fullURLStringForEndpoint(endpoint: String) -> String {
        //NOTE: everything needs trailing slashes or it won't work.
        return self.apiBaseURLString + "/" + endpoint + "/"
    }
    
    func fullURLStringForEndpoint(endpoint: String, withQueryItems queryItems: [NSURLQueryItem]) -> String {
        var fullURLString = self.fullURLStringForEndpoint(endpoint)
        if let components = NSURLComponents(string: fullURLString) {
            if queryItems.count > 0 {
                if components.queryItems != nil {
                    components.queryItems?.appendContentsOf(queryItems)
                } else {
                    components.queryItems = queryItems
                }
                
                #if swift(>=2.3)
                    fullURLString = components.URL!.absoluteString!
                #else
                    fullURLString = components.URL!.absoluteString
                #endif
            } //else nothing to add
        } //else nothing to add to.
        
        return fullURLString
    }
    
    public var stripeAPIKey: String {
        switch self {
        case .Production:
            return "pk_Upwuor56YhI3bn8eyKsTVzMzRNtkJ"
        case .Staging:
            return "pk_pVrZECFdsvN2AS2UpLXO4CCPnziai"
        default:
            return ""
        }
    }
    
    public var apiBaseURLString: String {
        let pureBase: String
        switch self {
        case .Staging:
            pureBase = "https://pdp.kickthe.tires"
        case .Production:
            pureBase = "https://spothero.com"
        case .Custom (let baseURLString):
            pureBase = baseURLString
        }
        
        return pureBase + "/api"
    }
    
    //MARK: SpotHero Website
    
    public var websiteBaseURLString: String {
        switch self {
        case .Staging:
            return "http://pdp.kickthe.tires"
        case .Production:
            return "http://www.spothero.com"
        case .Custom (let baseURLString):
            return baseURLString
        }
    }
}
