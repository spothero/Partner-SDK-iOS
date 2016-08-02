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
    
    func title() -> String {
        switch self {
        case .Address:
            return LocalizedStrings.Address
        case .Starts:
            return LocalizedStrings.Starts
        case .Ends:
            return LocalizedStrings.Ends
        }
    }
}

enum PersonalInfoRow: Int {
    case
    FullName,
    Email,
    Phone
    
    func title() -> String {
        switch self {
        case .FullName:
            return LocalizedStrings.FullName
        case .Email:
            return LocalizedStrings.Email
        case .Phone:
            return LocalizedStrings.Phone
        }
    }
    
    func placeholder() -> String {
        switch self {
        case .FullName:
            return LocalizedStrings.EnterFullName
        case .Email:
            return LocalizedStrings.EnterEmailAddress
        case .Phone:
            return LocalizedStrings.EnterPhoneNumber
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
        case CheckoutSection.ReservationInfo.rawValue,
             CheckoutSection.PersonalInfo.rawValue:
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
            facility = self.facility,
            rate = self.rate,
            row = ReservationInfoRow(rawValue: indexPath.row) {
            
            cell.configureCell(row, facility: facility, rate: rate)
        } else if let
            cell = cell as? PersonalInfoTableViewCell,
            row = PersonalInfoRow(rawValue: indexPath.row) {
            
            cell.configureCell(row)
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
        guard let checkoutSection = CheckoutSection(rawValue: section) else {
            return nil
        }
        
        switch checkoutSection {
        case CheckoutSection.ReservationInfo:
            return LocalizedStrings.ReservationInfo
        case CheckoutSection.PersonalInfo:
            return LocalizedStrings.PersonalInfo
        case CheckoutSection.PaymentInfo:
            return LocalizedStrings.PaymentInfo
        }
    }
    
    override func tableView(tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return CGFloat.min
    }
    
}
