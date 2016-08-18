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
        spotHeroSDK.partnerApplicationKey = "246691fb79c08b02c36d4a265a359c639ed75578"
        spotHeroSDK.launchSDKFromViewController(self)
    }
    
}
