//
//  ViewController.swift
//  SpotHero_iOS_Partner_SDK
//
//  Created by Ellen Shapiro on 06/29/2016.
//  Copyright (c) 2016 SpotHero, Inc. All rights reserved.
//

import UIKit
import SpotHero_iOS_Partner_SDK

class ViewController: UIViewController {
    
    @IBAction private func launchSDKButtonPressed(sender: AnyObject) {
        let spotHeroSDK = SpotHeroPartnerSDK.SharedInstance
        // Enter your SpotHero Partner API Key here
        spotHeroSDK.partnerApplicationKey = "a92bcb5001fec54e57aa7224be4f88f4f28b5d4a"
        spotHeroSDK.launchSDKFromViewController(self)
    }
    
}
