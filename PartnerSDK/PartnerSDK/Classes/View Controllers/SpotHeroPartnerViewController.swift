//
//  SpotHeroPartnerViewController.swift
//  SpotHero_iOS_Partner_SDK
//
//  Created by Matthew Reed on 12/5/17.
//

import UIKit

class SpotHeroPartnerViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        if SpotHeroPartnerSDK.shared.showXButton {
            self.addCloseButton()
        }
        self.registerForKeyboardnotifications()
        // Kill the back button label on the next VC setting an empty title on the back button
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "",
                                                                style: .plain,
                                                                target: nil,
                                                                action: nil)
    }
    
    private func registerForKeyboardnotifications() {
        let notificationCenter = NotificationCenter.default
        
        notificationCenter.addObserver(self,
                                       selector: #selector(self.willShowKeyboard(notification:)),
                                       name: UIResponder.keyboardWillShowNotification,
                                       object: nil)
        notificationCenter.addObserver(self,
                                       selector: #selector(self.willHideKeyboard(notification:)),
                                       name: UIResponder.keyboardWillHideNotification,
                                       object: nil)
    }
    
    @objc
    func willShowKeyboard(notification: Notification) {
        //Override as needed
    }
    
    @objc
    func willHideKeyboard(notification: Notification) {
        //Override as needed
    }

    private func addCloseButton() {
        let image = UIImage(shp_named: "icn_close")
        let barButtonItem = UIBarButtonItem(image: image,
                                            style: .plain,
                                            target: self,
                                            action: #selector(self.closeButtonTapped))
        barButtonItem.accessibilityLabel = LocalizedStrings.Close
        self.navigationItem.rightBarButtonItem = barButtonItem
    }
    
    @IBAction private func closeButtonTapped() {
        SpotHeroPartnerSDK.shared.close(from: self)
    }
}
