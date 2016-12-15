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
        spotHeroSDK.partnerApplicationKey = "65f498a5f7966a9b814bd676f11a76025dd42a68"
        spotHeroSDK.launchSDKFromViewController(self)
    }
}
