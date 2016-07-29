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
    
    func reuseIdentifier() -> String {
        switch self {
        case .ReservationInfo:
            return "reservationInfoCell"
        case .PersonalInfo:
            return "personalInfoCell"
        case .PaymentInfo:
            return "paymentInfoCell"
        default:
            return ""
        }
    }
}

enum ReservationInfoRow: Int {
    case
    Address,
    Starts,
    Ends
}

enum PersonalInfoRow: Int {
    case
    FullName,
    Email,
    Phone
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
    let personalInfoPlaceholders = [
        "Enter Full Name",
        "Enter Email Address",
        "Enter Phone Number"
    ]
    
    var facility: Facility?
    var rate: Rate?

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
        let cell: UITableViewCell
        if let section = CheckoutSection(rawValue: indexPath.section) {
            cell = tableView.dequeueReusableCellWithIdentifier(section.reuseIdentifier(), forIndexPath: indexPath)
        } else {
            assertionFailure("Cannot get the section")
            cell = UITableViewCell()
        }
        
        if let
            cell = cell as? ReservationInfoTableViewCell,
            facility = facility,
            rate = rate {
            cell.titleLabel.text = reservationCellTitles[indexPath.row]
            
            switch indexPath.row {
            case ReservationInfoRow.Address.rawValue:
                cell.primaryLabel.text = facility.streetAddress
                cell.secondaryLabel.text = "\(facility.city), \(facility.state)"
            case ReservationInfoRow.Starts.rawValue:
                cell.primaryLabel.text = "\(DateFormatter.RelativeDate.stringFromDate(rate.starts)), \(DateFormatter.DateOnlyNoYear.stringFromDate(rate.starts))"
                cell.secondaryLabel.text = DateFormatter.TimeOnly.stringFromDate(rate.starts)
            case ReservationInfoRow.Ends.rawValue:
                cell.primaryLabel.text = "\(DateFormatter.RelativeDate.stringFromDate(rate.ends)), \(DateFormatter.DateOnlyNoYear.stringFromDate(rate.ends))"
                cell.secondaryLabel.text = DateFormatter.TimeOnly.stringFromDate(rate.ends)
            default:
                break
            }
        } else if let cell = cell as? PersonalInfoTableViewCell {
            cell.titleLabel.text = personalInfoTitles[indexPath.row]
            cell.textField.placeholder = personalInfoPlaceholders[indexPath.row]
            
            switch indexPath.row {
            case PersonalInfoRow.FullName.rawValue:
                cell.textField.autocapitalizationType = .Words
            case PersonalInfoRow.Email.rawValue:
                cell.textField.autocapitalizationType = .None
                cell.textField.keyboardType = .EmailAddress
            case PersonalInfoRow.Phone.rawValue:
                cell.textField.keyboardType = .PhonePad
            default:
                break
            }
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
