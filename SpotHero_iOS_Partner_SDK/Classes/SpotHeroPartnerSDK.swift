//
//  SpotHeroPartnerSDK.swift
//  Pods
//
//  Created by Ellen Shapiro (Work) on 6/29/16.
//
//

import Foundation

@objc(SHPSpotHeroPartnerSDK)
public class SpotHeroPartnerSDK: NSObject {

    /// The singleton instance of this SDK
    public static let SharedInstance = SpotHeroPartnerSDK()
    
    /// Set to `true` if you would like a very large amount of debug logging. DO NOT set this to `true` for release builds. 
    public var debugPrintInfo = false
    
    
    //MARK: Error keys
    
    ///Key to pull a non-localized description out of an NSError's UserInfo dictionary.
    public static let UnlocalizedDescriptionKey = "SpotHeroPartnerSDKDescription"
    
    ///Key indicating the error code received from the SpotHero server.
    public static let ErrorCodeFromServer = "ErrorCodeFromSpotHeroServer"

}