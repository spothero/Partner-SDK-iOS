//
//  CheckoutTableViewController.swift
//  Pods
//
//  Created by Matthew Reed on 7/27/16.
//
//

import UIKit

enum CheckoutSection: Int, CountableIntEnum {
    case
    ReservationInfo,
    PersonalInfo,
    PaymentInfo
    
    func reuseIdentifier() -> String {
        switch self {
        case .ReservationInfo:
            return ReservationInfoTableViewCell.reuseIdentifier
        case .PersonalInfo:
            return PersonalInfoTableViewCell.reuseIdentifier
        case .PaymentInfo:
            return PaymentInfoTableViewCell.reuseIdentifier
        }
    }
}

enum ReservationInfoRow: Int {
    case
    Address,
    Starts,
    Ends
    
    //TODO: Localize
    func title() -> String {
        switch self {
        case .Address:
            return "Address"
        case .Starts:
            return "Starts"
        case .Ends:
            return "Ends"
        }
    }
}


enum PersonalInfoRow: Int {
    case
    FullName,
    Email,
    Phone
    
    //TODO: Localize
    func title() -> String {
        switch self {
        case .FullName:
            return "Full Name"
        case .Email:
            return "Email"
        case .Phone:
            return "Phone"
        }
    }
    
    //TODO: Localize
    func placeholder() -> String {
        switch self {
        case .FullName:
            return "Enter Full Name"
        case .Email:
            return "Enter Email Address"
        case .Phone:
            return "Enter Phone Number"
        }
    }
}

class CheckoutTableViewController: UITableViewController {
    let reservationCellHeight: CGFloat = 86
    
    var facility: Facility?
    var rate: Rate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.estimatedRowHeight = 60
    }
    
    // MARK: - Table view data source
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return CheckoutSection.AllCases.count
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
            rate = rate,
            row = ReservationInfoRow(rawValue: indexPath.row) {
            
            cell.titleLabel.text = row.title()
            
            switch row {
            case ReservationInfoRow.Address:
                cell.primaryLabel.text = facility.streetAddress
                cell.secondaryLabel.text = "\(facility.city), \(facility.state)"
            case ReservationInfoRow.Starts:
                cell.primaryLabel.text = "\(DateFormatter.RelativeDate.stringFromDate(rate.starts)), \(DateFormatter.DateOnlyNoYear.stringFromDate(rate.starts))"
                cell.secondaryLabel.text = DateFormatter.TimeOnly.stringFromDate(rate.starts)
            case ReservationInfoRow.Ends:
                cell.primaryLabel.text = "\(DateFormatter.RelativeDate.stringFromDate(rate.ends)), \(DateFormatter.DateOnlyNoYear.stringFromDate(rate.ends))"
                cell.secondaryLabel.text = DateFormatter.TimeOnly.stringFromDate(rate.ends)
            }
        } else if let
            cell = cell as? PersonalInfoTableViewCell,
            row = PersonalInfoRow(rawValue: indexPath.row) {
            
            cell.titleLabel.text = row.title()
            cell.textField.placeholder = row.placeholder()
            
            switch row {
            case PersonalInfoRow.FullName:
                cell.textField.autocapitalizationType = .Words
            case PersonalInfoRow.Email:
                cell.textField.autocapitalizationType = .None
                cell.textField.keyboardType = .EmailAddress
            case PersonalInfoRow.Phone:
                cell.textField.keyboardType = .PhonePad
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
