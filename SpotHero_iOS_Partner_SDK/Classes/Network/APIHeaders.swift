//
//  APIHeaders.swift
//  SpotHero_iOS_Partner_SDK
//
//  Created by Ellen Shapiro (Work) on 6/29/16.
//
//

import Foundation

typealias HeaderDictionary = [APIHeaders.HTTPHeaderField : APIHeaders.HTTPHeaderValue]

public struct APIHeaders {
    private static let CurrentAPIMinorVersion = "2016-05-27"
    
    // The current user agent for the SDK.
    static let UserAgent: HTTPHeaderValue = {
        //TODO: Get this off the bundle
        let version = 1
        return HTTPHeaderValue.PartnerSDKUserAgent(versionNumber: version)
    }()
    
    ///Various standard header fields
    enum HTTPHeaderField: String {
        case
        Authorization,
        ContentType = "Content-Type",
        UserAgent = "User-Agent",
        APIMinorVersion = "SpotHero-Version",
        Accept
    }
    
    ///Various Content types
    enum HTTPContentType: String {
        case
        JSON = "application/json",
        Form = "application/x-www-form-urlencoded; charset=utf8"
    }
    
    ///Various header values and types associated with them
    enum HTTPHeaderValue {
        case
        ContentType(contentType: HTTPContentType),
        PartnerSDKUserAgent(versionNumber: Int),
        APIMinorVersion
        
        
        /**
         - returns: The value of the header as a single string.
         */
        func asString() -> String {
            switch self {
            case ContentType(let contentType):
                return contentType.rawValue
            case PartnerSDKUserAgent(let buildNumber):
                return "ios-partner-sdk-version-\(buildNumber)"
            case APIMinorVersion:
                return APIHeaders.CurrentAPIMinorVersion
            }
        }
    }
    
    static func headerStringDict(headers: [HTTPHeaderField : HTTPHeaderValue]) -> [String : String] {
        var headerDictionary = [String : String]()
        for (key, value) in headers {
            headerDictionary[key.rawValue] = value.asString()
        }
        
        return headerDictionary
    }
    
    static func defaultHeaders() -> HeaderDictionary {
        var headers = [HTTPHeaderField : HTTPHeaderValue]()
        
        headers[.ContentType] = .ContentType(contentType: .JSON)
        headers[.APIMinorVersion] = .APIMinorVersion
        headers[.UserAgent] = self.UserAgent
        headers[.Accept] = .ContentType(contentType: .JSON)
        
        return headers
    }
}
