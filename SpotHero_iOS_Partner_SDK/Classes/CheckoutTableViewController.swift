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
    let paymentButtonHeight: CGFloat = 60
    
    private lazy var paymentButton: UIButton = {
        let _button = UIButton()
        _button.addTarget(self, action: #selector(self.paymentButtonPressed), forControlEvents: .TouchUpOutside)
        _button.backgroundColor = .shp_mutedGreen()
        _button.enabled = false
        _button.frame = CGRect(x: 0, y: self.navigationController!.view.frame.height - self.paymentButtonHeight, width: self.navigationController!.view.frame.width, height: self.paymentButtonHeight)
        return _button
    }()
    
    var facility: Facility?
    var rate: Rate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.estimatedRowHeight = 60
        self.setupPaymentButton()
    }
    
    func setupPaymentButton() {
        guard let
            rate = self.rate,
            price = NumberFormatter.dollarNoCentsStringFromCents(rate.price) else {
            return
        }
        
        self.tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: self.paymentButtonHeight, right: 0)
        
        self.paymentButton.setTitle("Pay \(price) and Confirm Parking", forState: .Normal)
        self.navigationController?.view.addSubview(self.paymentButton)
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
            
            self.configureCell(cell,
                               row: row,
                               facility: facility,
                               rate: rate)
        } else if let
            cell = cell as? PersonalInfoTableViewCell,
            row = PersonalInfoRow(rawValue: indexPath.row) {
            
            self.configureCell(cell, row: row)
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
    
    //MARK: Actions
    
    func paymentButtonPressed() {
        // Create Stripe token and reservation
    }
    
    //MARK: Helpers
    
    func configureCell(cell: ReservationInfoTableViewCell,
                       row: ReservationInfoRow,
                       facility: Facility,
                       rate: Rate) {
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
    }
    
    func configureCell(cell: PersonalInfoTableViewCell, row: PersonalInfoRow) {
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
    
    func setPaymentButtonEnabled(enabled: Bool) {
        self.paymentButton.enabled = enabled
        self.paymentButton.backgroundColor = enabled ? .shp_green() : .shp_mutedGreen()
    }
}
