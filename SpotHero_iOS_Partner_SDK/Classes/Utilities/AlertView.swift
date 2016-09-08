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
            return
        }
        
        let alert = UIAlertController(title: LocalizedStrings.Error,
                                      message: message,
                                      preferredStyle: .Alert)
        alert.addAction(UIAlertAction(title: LocalizedStrings.OK,
                                      style: .Default,
                                      handler: nil))
        viewController.presentViewController(alert,
                                             animated: true,
                                             completion: nil)
    }
}
