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
@objcMembers
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
    
    public var statusBarStyle: UIStatusBarStyle = .lightContent
    
    /// The text color to use for the nav bar. Defaults to white.
    public var textColor: UIColor = .white
    
    /// Your application's private key. Defaults to an empty string.
    public var partnerApplicationKey: String = ""
    
    private var dateSDKOpened: Date?
    private var sdkIsPresented = true
    internal var showXButton: Bool {
        return self.sdkIsPresented
    }
    
    //MARK: - Functions
    
    func resetToSearch(from viewController: UIViewController) {
        if let navigationController = viewController.navigationController {
            //not presented, pop back to before the search view controller
            var newViewControllers = Array(
                navigationController
                .viewControllers
                .reversed()
                .drop(while: { $0 is SpotHeroPartnerViewController })
                .reversed()
            )
            //and add in a new search view controller
            newViewControllers.append(SearchViewController.fromStoryboard())
            navigationController.setViewControllers(newViewControllers, animated: true)
        } else {
            assertionFailure("No navigation controller")
        }
    }
    
    func close(from viewController: UIViewController) {
        self.reportSDKClosed()
        if self.sdkIsPresented {
            viewController.dismiss(animated: true)
        } else {
            self.resetToSearch(from: viewController)
        }
    }
    
    /// Send Mixpanel event that sdk was closed
    func reportSDKClosed() {
        let date = Date()
        if let openDate = self.dateSDKOpened {
            let duration = date.timeIntervalSince(openDate)
            MixpanelWrapper.track(.sdkClosed, properties: [.sdkClosed: duration])
        }
    }
    
    /**
     Launches the SDK's UI from a given view controller as a modal.
     
     - parameter viewController: The view controller which you want to present the UI for getting a space through SpotHero
     - parameter completion:     A completion block to be passed through to `pushViewController`, or nil. Defaults to nil.
     */
    public func launchSDK(fromViewController viewController: UIViewController? = nil,
                          completion: ((UIViewController?) -> Void)? = nil) {
        let storyboard = UIStoryboard(name: "Main", bundle: Bundle.shp_resourceBundle())
        
        guard let navController = storyboard.instantiateInitialViewController() as? SpotHeroPartnerNavigationController else {
            return
        }
        
        if partnerApplicationKey.isEmpty {
            // Yell in dev, return in production
            assertionFailure("Your API key is blank! You must have an API key to use the SDK")
            // Return from function so SDK is not launched without an API Key
            return
        }
        
        let textAttributes = [
            NSAttributedString.Key.foregroundColor: self.textColor,
            ]
        
        navController.navigationBar.titleTextAttributes = textAttributes
        navController.navigationBar.tintColor = self.textColor
        navController.navigationBar.barTintColor = self.tintColor
        navController.statusBarStyle = statusBarStyle
        // Set up custom back button
        let arrowImage = UIImage(shp_named: "search_back_arrow")?.withRenderingMode(.alwaysTemplate)
        navController.navigationBar.backIndicatorImage = arrowImage
        navController.navigationBar.backIndicatorTransitionMaskImage = arrowImage

        UIFont.loadAllFontsIfNeeded()
        
        APIKeyConfig.sharedInstance.getKeys {
            success in
            guard success else {
                assertionFailure("Unable to get API Keys")
                return
            }
            
            if let viewController = viewController {
                self.sdkIsPresented = true
                viewController.present(navController, animated: true) {
                    completion?(nil)
                }
            } else {
                self.sdkIsPresented = false
                completion?(navController.topViewController)
            }
            self.trackSDKOpened()
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
