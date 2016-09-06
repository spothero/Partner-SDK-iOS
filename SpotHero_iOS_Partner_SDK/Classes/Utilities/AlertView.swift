//
//  AlertView.swift
//  Pods
//
//  Created by SpotHeroMatt on 8/31/16.
//
//

import UIKit

enum AlertView {
    static func presentErrorAlertView(message: String, from viewController: UIViewController?) {
        guard let viewController = viewController else {
            // TODO: Present from top window vc
            return
        }
        
        let alert = UIAlertController(title: "Error",
                                      message: message,
                                      preferredStyle: .Alert)
        alert.addAction(UIAlertAction(title: "OK",
                                      style: .Default,
                                      handler: nil))
        viewController.presentViewController(alert,
                                             animated: true,
                                             completion: nil)
    }
}
