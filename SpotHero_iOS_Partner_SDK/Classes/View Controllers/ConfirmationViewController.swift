//
//  ConfirmationViewController.swift
//  Pods
//
//  Created by SpotHeroMatt on 8/31/16.
//
//

import UIKit

class ConfirmationViewController: SpotHeroPartnerViewController {
    @IBOutlet private var bookAnotherButton: UIButton!
    @IBOutlet private var doneButton: UIButton!
    @IBOutlet private var allSetLabel: HeadlineLabel!
    @IBOutlet private var detailsLabel: SubheadLabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.hidesBackButton = true
        self.title = LocalizedStrings.Confirmation
        self.allSetLabel.text = LocalizedStrings.AllSet
        self.detailsLabel.text = LocalizedStrings.ConfirmationDetails
        
        self.bookAnotherButton.setTitle(LocalizedStrings.BookAnother, for: .normal)
        self.doneButton.setTitle(LocalizedStrings.Done, for: .normal)
    }
    
    @IBAction func bookAnotherButtonPressed(_ sender: AnyObject) {
        MixpanelWrapper.track(.postPurchase, properties: [.tappedBookAnother: true])
        SpotHeroPartnerSDK.shared.resetToSearch(from: self)
    }
    
    @IBAction func doneButtonPressed(_ sender: AnyObject) {
        MixpanelWrapper.track(.postPurchase, properties: [.tappedDone: true])
        SpotHeroPartnerSDK.shared.close(from: self)
    }
}
