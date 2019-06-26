//
//  AlertView.swift
//  Pods
//
//  Created by SpotHeroMatt on 8/31/16.
//
//

import UIKit

enum AlertView {
    
    //swiftlint:disable:next function_default_parameter_at_end
    static func presentErrorAlertView(_ title: String = LocalizedStrings.Error,
                                      message: String,
                                      from viewController: UIViewController,
                                      handler: ((UIAlertAction) -> Void)? = nil) {
        let okayAlertAction = UIAlertAction(title: LocalizedStrings.Okay,
                                            style: .default,
                                            handler: handler)
        self.presentAlert(title: title,
                          message: message,
                          from: viewController,
                          alertActions: [okayAlertAction])
    }
    
    static func presentAlert(title: String,
                             message: String,
                             from viewController: UIViewController,
                             alertActions: [UIAlertAction]) {
        let alert = UIAlertController(title: title,
                                      message: message,
                                      preferredStyle: .alert)
        alertActions.forEach { alertAction in
            alert.addAction(alertAction)
        }
        viewController.present(alert, animated: true)
    }
}
