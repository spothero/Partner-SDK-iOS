//
//  CheckoutTableViewController.swift
//  Pods
//
//  Created by SpotHeroMatt on 7/27/16.
//
//

import UIKit

enum CheckoutSection: Int {
    case
    ReservationInfo,
    PersonalInfo,
    PaymentInfo,
    Count
}

class CheckoutTableViewController: UITableViewController {
    let reservationCellHeight: CGFloat = 86
    let reservationCellTitles = [
        "Address",
        "Starts",
        "Ends"
    ]
    let personalInfoTitles = [
        "Full Name",
        "Email",
        "Phone"
    ]

    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.estimatedRowHeight = 60
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return CheckoutSection.Count.rawValue
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let reuseIdentifier: String
        switch indexPath.section {
        case CheckoutSection.ReservationInfo.rawValue:
            reuseIdentifier = "reservationInfoCell"
        case CheckoutSection.PersonalInfo.rawValue:
            reuseIdentifier = "personalInfoCell"
        case CheckoutSection.PaymentInfo.rawValue:
            reuseIdentifier = "paymentInfoCell"
        default:
            reuseIdentifier = ""
        }
        
        let cell = tableView.dequeueReusableCellWithIdentifier(reuseIdentifier, forIndexPath: indexPath)
        
        return cell
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        switch indexPath.section {
        case CheckoutSection.ReservationInfo.rawValue:
            return self.reservationCellHeight
        default:
            return UITableViewAutomaticDimension
        }
    }
}
