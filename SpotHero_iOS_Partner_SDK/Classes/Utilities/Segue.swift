//
//  Segue.swift
//  SpotHero_iOS_Partner_SDK
//
//  Created by Matthew Reed on 12/14/17.
//

import UIKit

enum Segue: String {
    case showMap
    case showCheckout
    
    func perform(viewController: UIViewController, sender: Any? = nil) {
        viewController.performSegue(withIdentifier: self.rawValue, sender: sender)
    }
}
