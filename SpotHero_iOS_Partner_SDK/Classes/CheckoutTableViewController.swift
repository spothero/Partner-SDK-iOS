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
    //TODO: Localize
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
    
    var reservation: Reservation?
    var facility: Facility?

    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.estimatedRowHeight = 60
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return CheckoutSection.Count.rawValue
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case CheckoutSection.ReservationInfo.rawValue, CheckoutSection.PersonalInfo.rawValue:
            return 3
        default:
            return 1
        }
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        //TODO: Uncomment when finished we can pass in a reservation and facility
//        guard let
//            facility = facility,
//            reservation = reservation else {
//                assertionFailure("You need a facility and reservation before you can checkout")
//                return UITableViewCell()
//        }
        
        let reuseIdentifier: String
        let title: String
        let primaryText: String
        let secondaryText: String
        switch indexPath.section {
        case CheckoutSection.ReservationInfo.rawValue:
            reuseIdentifier = "reservationInfoCell"
            title = reservationCellTitles[indexPath.row]
            primaryText = ""
            secondaryText = ""
        case CheckoutSection.PersonalInfo.rawValue:
            reuseIdentifier = "personalInfoCell"
            title = personalInfoTitles[indexPath.row]
            primaryText = ""
            secondaryText = ""
        case CheckoutSection.PaymentInfo.rawValue:
            reuseIdentifier = "paymentInfoCell"
            title = ""
            primaryText = ""
            secondaryText = ""
        default:
            reuseIdentifier = ""
            title = ""
            primaryText = ""
            secondaryText = ""
        }
        
        let cell = tableView.dequeueReusableCellWithIdentifier(reuseIdentifier, forIndexPath: indexPath)
        
        if let cell = cell as? CheckoutCell {
            cell.configureCell(title, primaryText: primaryText, secondaryText: secondaryText)
        }
        
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
    
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        // TODO: Localize
        switch section {
        case CheckoutSection.ReservationInfo.rawValue:
            return "RESERVATION INFO"
        case CheckoutSection.PersonalInfo.rawValue:
            return "PERSONAL INFO"
        case CheckoutSection.PaymentInfo.rawValue:
            return "PAYMENT INFO"
        default:
            return ""
        }
    }
    
    override func tableView(tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return CGFloat.min
    }
}
