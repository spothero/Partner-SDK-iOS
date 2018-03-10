//
//  SpotHeroPartnerSDK.swift
//  Pods
//
//  Created by Ellen Shapiro (Work) on 6/29/16.
//
//

import Foundation

/**
 *  The primary interface for interacting with the partner SDK.
 */
@objc(SHPSpotHeroPartnerSDK)
public final class SpotHeroPartnerSDK: NSObject {
    
    //MARK: - Singleton
    
    /// The singleton instance of this SDK
    public static let shared = SpotHeroPartnerSDK()
    
    //MARK: - Settable properties
    
    /// Set to `true` if you would like a very large amount of debug logging. DO NOT set this to `true` for release builds.
    public var debugPrintInfo = false
    
    /// The tint color to use for the background of the nav bar. Defaults to Tire (SpotHero dark grey).
    public var tintColor: UIColor = .shp_tire
    
    /// The text color to use for the nav bar. Defaults to white.
    public var textColor: UIColor = .white
    
    /// Your application's private key. Defaults to an empty string.
    public var partnerApplicationKey: String = ""
    
    private var dateSDKOpened: Date?
    internal var showXButton = true
    
    //MARK: - Functions
    
    /// Send Mixpanel event that sdk was closed
    func reportSDKClosed() {
        let date = Date()
        if let openDate = SpotHeroPartnerSDK.shared.dateSDKOpened {
            let duration = date.timeIntervalSince(openDate)
            MixpanelWrapper.track(.sdkClosed, properties: [.sdkClosed: duration])
        }
    }
    
    /**
     Launches the SDK's UI from a given view controller as a modal.
     
     - parameter viewController: The view controller which you want to present the UI for getting a space through SpotHero
     - parameter completion:     A completion block to be passed through to `presentViewController`, or nil. Defaults to nil.
     */
    public func launchSDK(fromViewController viewController: UIViewController? = nil,
                          completion: ((UIViewController?) -> Void)? = nil) {
        let storyboard = UIStoryboard(name: "Main", bundle: Bundle.shp_resourceBundle())
        
        guard let navController = storyboard.instantiateInitialViewController() as? UINavigationController else {
            return
        }
        
        if partnerApplicationKey.isEmpty {
            // Yell in dev, return in production
            assertionFailure("Your API key is blank! You must have an API key to use the SDK")
            // Return from function so SDK is not launched without an API Key
            return
        }
        
        let textAttributes = [
            NSForegroundColorAttributeName: self.textColor,
            ]
        
        navController.navigationBar.titleTextAttributes = textAttributes
        navController.navigationBar.tintColor = self.textColor
        navController.navigationBar.barTintColor = self.tintColor
        // Set up custom back button
        let arrowImage = UIImage(shp_named: "search_back_arrow")?.withRenderingMode(.alwaysTemplate)
        navController.navigationBar.backIndicatorImage = arrowImage
        navController.navigationBar.backIndicatorTransitionMaskImage = arrowImage

        UIFont.loadAllFontsIfNeeded()
        
        APIKeyConfig.sharedInstance.getKeys {
            success in
            if let viewController = viewController, success {
                self.showXButton = true
                viewController.present(navController,
                                       animated: true) {
                                        completion?(nil)
                                       }
                self.trackSDKOpened()
            } else if success {
                self.trackSDKOpened()
                self.showXButton = false
                completion?(navController.topViewController)
            } else {
                assertionFailure("Unable to get API Keys")
            }
        }
    }
    
    private func trackSDKOpened() {
        MixpanelWrapper.track(.sdkOpened)
        self.dateSDKOpened = Date()
    }
    
    //MARK: -  Error keys
    
    /// Key to pull a non-localized description out of an NSError's UserInfo dictionary.
    public static let UnlocalizedDescriptionKey = "SpotHeroPartnerSDKDescription"
    
    /// Key indicating the error code received from the SpotHero server.
    public static let ErrorCodeFromServer = "ErrorCodeFromSpotHeroServer"
    
}
