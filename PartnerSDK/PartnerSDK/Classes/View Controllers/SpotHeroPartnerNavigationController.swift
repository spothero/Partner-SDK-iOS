//
//  SpotHeroPartnerNavigationController.swift
//  Pods
//
//  Created by SpotHeroMatt on 9/15/16.
//
//

import UIKit

class SpotHeroPartnerNavigationController: UINavigationController {
    var statusBarStyle: UIStatusBarStyle = .lightContent
    
    override var preferredInterfaceOrientationForPresentation: UIInterfaceOrientation {
        return .portrait
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return [.portrait]
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return self.statusBarStyle
    }
}
