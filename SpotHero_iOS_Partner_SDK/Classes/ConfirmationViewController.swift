//
//  ConfirmationViewController.swift
//  Pods
//
//  Created by SpotHeroMatt on 8/31/16.
//
//

import UIKit

class ConfirmationViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.hidesBackButton = true
    }
    
    @IBAction func bookAnotherButtonPressed(sender: AnyObject) {
        // Got first ViewController to be able to start the rental process over again
        self.navigationController?.popToRootViewControllerAnimated(true)
    }
    
    @IBAction func doneButtonPressed(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func closeButtonPressed(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
}
