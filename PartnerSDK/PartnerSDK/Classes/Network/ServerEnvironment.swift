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
    staging,
    production,
    custom(baseURL: String) // Must be passed in as https://whatevs.com (no /api) to work
    
    /// What environment should we be pointed at?
    public static var CurrentEnvironment = ServerEnvironment.production
    
    /// Should the API debugPrint the info?
    public static var ShouldDebugPrintInfo = SpotHeroPartnerSDK.shared.debugPrintInfo
    
    // MARK: SpotHero API
    
    func fullURLStringForEndpoint(_ endpoint: String) -> String {
        //NOTE: everything needs trailing slashes or it won't work.
        return self.apiBaseURLString + "/" + endpoint + "/"
    }
    
    func fullURLStringForEndpoint(_ endpoint: String, withQueryItems queryItems: [URLQueryItem]) -> String {
        let fullURLString = self.fullURLStringForEndpoint(endpoint)
        var components = URLComponents(string: fullURLString)
        if !queryItems.isEmpty {
            if components?.queryItems != nil {
                components?.queryItems?.append(contentsOf: queryItems)
            } else {
                components?.queryItems = queryItems
            }
        }
        
        return components?.url?.absoluteString ?? ""
            
    }
    
    public var stripeAPIKey: String {
        return APIKeyConfig.sharedInstance.stripeApiKey
    }
    
    public var apiBaseURLString: String {
        let pureBase: String
        switch self {
        case .staging:
            pureBase = "https://mobiledev.sandbox.kickthe.tires"
        case .production:
            pureBase = "https://spothero.com"
        case .custom (let baseURLString):
            pureBase = baseURLString
        }
        
        return pureBase + "/api"
    }
    
    // MARK: SpotHero Website
    
    public var websiteBaseURLString: String {
        switch self {
        case .staging:
            return "http://mobiledev.sandbox.kickthe.tires"
        case .production:
            return "http://www.spothero.com"
        case .custom (let baseURLString):
            return baseURLString
        }
    }
}
