//
//  ViewController.swift
//  SpotHero_iOS_Partner_SDK
//
//  Created by Ellen Shapiro on 06/29/2016.
//  Copyright (c) 2016 SpotHero, Inc. All rights reserved.
//

import SpotHero_iOS_Partner_SDK
import UIKit

class ViewController: UIViewController {
    private let apiKey = "Your API key Here"
    
    @IBAction private func presentSDKButtonTapped(_ sender: Any) {
        let spotHeroSDK = SpotHeroPartnerSDK.shared
        // Enter your SpotHero Partner API Key here
        spotHeroSDK.partnerApplicationKey = self.apiKey
        
        // Present SDK as modal
        spotHeroSDK.launchSDK(fromViewController: self)
    }
    
    @IBAction private func pushSDKButtonTapped(_ sender: AnyObject) {
        let spotHeroSDK = SpotHeroPartnerSDK.shared
        // Enter your SpotHero Partner API Key here
        spotHeroSDK.partnerApplicationKey = self.apiKey
        
        // Launch SDK and get the view controller from a completion block
        spotHeroSDK.launchSDK {
            viewController in
            if let viewController = viewController {
                self.navigationController?.pushViewController(viewController, animated: true)
            }
        }
    }
}
