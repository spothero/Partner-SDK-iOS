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
        spotHeroSDK.partnerApplicationKey = "0d08a88b4613fafb2a4d2badb522b1f664b1d23b"
        spotHeroSDK.launchSDKFromViewController(self)
    }
    
}
