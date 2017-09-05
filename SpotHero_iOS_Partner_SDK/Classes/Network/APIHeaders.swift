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
        return HTTPHeaderValue.partnerSDKUserAgent(versionNumber: version)
    }()
    
    ///Various standard header fields
    enum HTTPHeaderField: String {
        case
        authorization = "Authorization",
        contentType = "Content-Type",
        userAgent = "User-Agent",
        apiMinorVersion = "SpotHero-Version",
        accept = "Accept"
    }
    
    ///Various Content types
    enum HTTPContentType: String {
        case
        json = "application/json",
        form = "application/x-www-form-urlencoded; charset=utf8"
    }
    
    ///Various header values and types associated with them
    enum HTTPHeaderValue {
        case
        contentType(contentType: HTTPContentType),
        partnerSDKUserAgent(versionNumber: Int),
        apiMinorVersion,
        apiToken
        
        /**
         - returns: The value of the header as a single string.
         */
        func asString() -> String {
            switch self {
            case .contentType(let contentType):
                return contentType.rawValue
            case .partnerSDKUserAgent(let buildNumber):
                return "ios-partner-sdk-version-\(buildNumber)"
            case .apiMinorVersion:
                return APIHeaders.CurrentAPIMinorVersion
            case .apiToken:
                return "Token \(SpotHeroPartnerSDK.shared.partnerApplicationKey)"
            }
        }
    }
    
    static func headerStringDict(_ headers: [HTTPHeaderField : HTTPHeaderValue]) -> [String : String] {
        var headerDictionary = [String : String]()
        for (key, value) in headers {
            headerDictionary[key.rawValue] = value.asString()
        }
        
        return headerDictionary
    }
    
    static func defaultHeaders() -> HeaderDictionary {
        var headers = [HTTPHeaderField : HTTPHeaderValue]()
        
        headers[.contentType] = .contentType(contentType: .json)
        headers[.apiMinorVersion] = .apiMinorVersion
        headers[.userAgent] = self.UserAgent
        headers[.accept] = .contentType(contentType: .json)
        headers[.authorization] = .apiToken
        
        return headers
    }
}
