//
//  ConfirmationViewController.swift
//  Pods
//
//  Created by SpotHeroMatt on 8/31/16.
//
//

import UIKit

class ConfirmationViewController: UIViewController {
    @IBOutlet weak var bookAnotherButton: UIButton!
    @IBOutlet weak var doneButton: UIButton!
    @IBOutlet weak var closeButton: UIBarButtonItem!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.hidesBackButton = true
        self.view.accessibilityLabel = AccessibilityStrings.ConfirmationScreen
        self.bookAnotherButton.setTitle(LocalizedStrings.BookAnother, forState: .Normal)
        self.doneButton.setTitle(LocalizedStrings.Done, forState: .Normal)
        self.closeButton.accessibilityLabel = LocalizedStrings.Close
    }
    
    @IBAction func bookAnotherButtonPressed(sender: AnyObject) {
        // Got first ViewController to be able to start the rental process over again
        MixpanelWrapper.track(.PostPurchase, properties: [.TappedBookAnother: true])
        self.navigationController?.popToRootViewControllerAnimated(true)
    }
    
    @IBAction func doneButtonPressed(sender: AnyObject) {
        MixpanelWrapper.track(.PostPurchase, properties: [.TappedDone: true])
        SpotHeroPartnerSDK.SharedInstance.reportSDKClosed()
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func closeButtonPressed(sender: AnyObject) {
        SpotHeroPartnerSDK.SharedInstance.reportSDKClosed()
        self.dismissViewControllerAnimated(true, completion: nil)
    }
}
