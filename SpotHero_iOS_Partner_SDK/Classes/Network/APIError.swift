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
        Network = "com.spothero.partnersdk.network.error",
        Parsing = "com.spothero.partnersdk.parsing.error"
        
    }
    
    enum PartnerSDKErrorCode: Int {
        case
        /// Used when conversion to an NSURL fails.
        CouldntMakeURLOutOfString = 650,
        /// Used when some parameter included is not valid (before it gets to the server)
        InvalidParameter = 651,
        
        /// Used when an empty response was received unexpectedly.
        UnexpectedEmptyResponse = 652,
        
        /// Used when JSON parsing fails
        JSONParsingFailure = 653
    }
    
    //MARK: - Error Generation
    
    static func errorFromServerJSON(serverError: ServerErrorJSON, statusCode: Int) -> NSError {
        let messages = serverError.messages.joinWithSeparator("\n")
        
        return NSError(domain: PartnerSDKAPIErrorDomain.Network.rawValue,
                       code: statusCode,
                       userInfo: [
                        SpotHeroPartnerSDK.UnlocalizedDescriptionKey: messages,
                        SpotHeroPartnerSDK.ErrorCodeFromServer: serverError.code
            ])
    }
    
    static func errorFromHTTPStatusCode(statusCode: Int) -> NSError {
        return NSError(domain: PartnerSDKAPIErrorDomain.Network.rawValue,
                       code: statusCode,
                       userInfo: [
                        SpotHeroPartnerSDK.UnlocalizedDescriptionKey: "Server error"
            ])
    }
    
    static func errorWithDescription(description: String, andStatusCode statusCode: Int) -> NSError {
        return NSError(domain: PartnerSDKAPIErrorDomain.Network.rawValue,
                       code: statusCode,
                       userInfo: [
                        SpotHeroPartnerSDK.UnlocalizedDescriptionKey: description,
            ])
    }
    
    static func parsingError(json: JSONDictionary?) -> NSError {
        if ServerEnvironment.ShouldDebugPrintInfo {
            print("JSON which couldn't be parsed: \(json)")
        }
        
        return NSError(domain: PartnerSDKAPIErrorDomain.Parsing.rawValue,
                       code: PartnerSDKErrorCode.JSONParsingFailure.rawValue,
                       userInfo: [
                        SpotHeroPartnerSDK.UnlocalizedDescriptionKey: "Couldn't parse the returned JSON!"
            ])
    }
}
