//
//  AlertView.swift
//  Pods
//
//  Created by SpotHeroMatt on 8/31/16.
//
//

import UIKit

enum AlertView {
    static func presentErrorAlertView(_ title: String = LocalizedStrings.Error,
                                      message: String,
                                      from viewController: UIViewController?,
                                      handler: ((UIAlertAction) -> Void)? = nil) {
        guard let viewController = viewController else {
            return
        }
        
        let alert = UIAlertController(title: title,
                                      message: message,
                                      preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: LocalizedStrings.Okay,
                                      style: .default,
                                      handler: handler))
        viewController.present(alert, animated: true)
    }
}
