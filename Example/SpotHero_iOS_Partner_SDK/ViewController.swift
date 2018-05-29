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
    
    private func configureSDK() -> SpotHeroPartnerSDK {
        //Production is the default setting, but for testing we will use the staging environment.
        ServerEnvironment.CurrentEnvironment = .staging
        let spotHeroSDK = SpotHeroPartnerSDK.shared
        // Enter your SpotHero Partner API Key here
        spotHeroSDK.partnerApplicationKey = ""
        return spotHeroSDK
    }
    
    @IBAction private func presentSDKButtonTapped(_ sender: Any) {
        let spotHeroSDK = self.configureSDK()
        // Present SDK as modal
        spotHeroSDK.launchSDK(fromViewController: self)
    }
    
    @IBAction private func pushSDKButtonTapped(_ sender: AnyObject) {
        let spotHeroSDK = self.configureSDK()
        // Launch SDK and get the view controller from a completion block
        spotHeroSDK.launchSDK {
            viewController in
            if let viewController = viewController {
                self.navigationController?.pushViewController(viewController, animated: true)
            }
        }
    }
}
