//
//  APIError.swift
//  Pods
//
//  Created by Ellen Shapiro (Work) on 6/29/16.
//
//

import Foundation

struct APIError {
    
    private enum PartnerSDKAPIErrorDomain: String {
        case
        network = "com.spothero.partnersdk.network.error",
        parsing = "com.spothero.partnersdk.parsing.error"
        
    }
    
    enum PartnerSDKErrorCode: Int {
        case
        /// Used when conversion to an NSURL fails.
        couldntMakeURLOutOfString = 650,
        /// Used when some parameter included is not valid (before it gets to the server)
        invalidParameter = 651,
        
        /// Used when an empty response was received unexpectedly.
        unexpectedEmptyResponse = 652,
        
        /// Used when JSON parsing fails
        jsonParsingFailure = 653
    }
    
    // MARK: - Error Generation
    
    static func errorFromServerJSON(_ serverError: ServerErrorJSON, statusCode: Int) -> NSError {
        guard
            let message = serverError.messages.first else {
                return NSError(
                    domain: PartnerSDKAPIErrorDomain.network.rawValue,
                    code: statusCode,
                    userInfo: [
                        SpotHeroPartnerSDK.UnlocalizedDescriptionKey: serverError.messages,
                    ]
                )
        }
        
        return NSError(
            domain: PartnerSDKAPIErrorDomain.network.rawValue,
            code: statusCode,
            userInfo: [
                SpotHeroPartnerSDK.UnlocalizedDescriptionKey: message,
                SpotHeroPartnerSDK.ErrorCodeFromServer: serverError.code,
            ]
        )
    }
    
    static func errorFromHTTPStatusCode(_ statusCode: Int) -> NSError {
        return NSError(
            domain: PartnerSDKAPIErrorDomain.network.rawValue,
            code: statusCode,
            userInfo: [
                SpotHeroPartnerSDK.UnlocalizedDescriptionKey: "Server error",
            ]
        )
    }
    
    static func errorWithDescription(_ description: String, andStatusCode statusCode: Int) -> NSError {
        return NSError(
            domain: PartnerSDKAPIErrorDomain.network.rawValue,
            code: statusCode,
            userInfo: [
                SpotHeroPartnerSDK.UnlocalizedDescriptionKey: description,
            ]
        )
    }
    
    static func parsingError(_ json: JSONDictionary?) -> NSError {
        if ServerEnvironment.ShouldDebugPrintInfo {
            print("JSON which couldn't be parsed: \(String(describing: json))")
        }
        
        return NSError(
            domain: PartnerSDKAPIErrorDomain.parsing.rawValue,
            code: PartnerSDKErrorCode.jsonParsingFailure.rawValue,
            userInfo: [
                SpotHeroPartnerSDK.UnlocalizedDescriptionKey: "Couldn't parse the returned JSON!",
            ]
        )
    }
}
