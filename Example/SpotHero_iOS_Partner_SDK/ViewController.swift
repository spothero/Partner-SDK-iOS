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
    
    @IBAction fileprivate func launchSDKButtonPressed(_ sender: AnyObject) {
        let spotHeroSDK = SpotHeroPartnerSDK.shared
        // Enter your SpotHero Partner API Key here
        spotHeroSDK.partnerApplicationKey = "bb5ab4b58fc484d8f478ef06e3c67e3c2dd71543"
        spotHeroSDK.launchSDKFromViewController(self)
    }
}
