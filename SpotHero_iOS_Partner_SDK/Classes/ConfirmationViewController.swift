//
//  ConfirmationViewController.swift
//  Pods
//
//  Created by SpotHeroMatt on 8/31/16.
//
//

import UIKit

class ConfirmationViewController: UIViewController {
    @IBOutlet private var bookAnotherButton: UIButton!
    @IBOutlet private var doneButton: UIButton!
    @IBOutlet private var closeButton: UIBarButtonItem!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.hidesBackButton = true
        self.bookAnotherButton.setTitle(LocalizedStrings.BookAnother, for: .normal)
        self.doneButton.setTitle(LocalizedStrings.Done, for: .normal)
        self.closeButton.accessibilityLabel = LocalizedStrings.Close
    }
    
    @IBAction func bookAnotherButtonPressed(_ sender: AnyObject) {
        // Got first ViewController to be able to start the rental process over again
        MixpanelWrapper.track(.PostPurchase, properties: [.TappedBookAnother: true])
        _ = self.navigationController?.popToRootViewController(animated: true)
    }
    
    @IBAction func doneButtonPressed(_ sender: AnyObject) {
        MixpanelWrapper.track(.PostPurchase, properties: [.TappedDone: true])
        SpotHeroPartnerSDK.shared.reportSDKClosed()
        self.dismiss(animated: true)
    }
    
    @IBAction func closeButtonPressed(_ sender: AnyObject) {
        SpotHeroPartnerSDK.shared.reportSDKClosed()
        self.dismiss(animated: true)
    }
}
