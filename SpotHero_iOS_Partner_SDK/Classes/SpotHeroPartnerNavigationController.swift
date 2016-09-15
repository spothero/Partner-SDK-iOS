//
//  SpotHeroPartnerNavigationController.swift
//  Pods
//
//  Created by SpotHeroMatt on 9/15/16.
//
//

import UIKit

class SpotHeroPartnerNavigationController: UINavigationController {
    override func preferredInterfaceOrientationForPresentation() -> UIInterfaceOrientation {
        return .Portrait
    }
    
    override func supportedInterfaceOrientations() -> UIInterfaceOrientationMask {
        return [.Portrait]
    }
}
