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

enum ReservationInfoRow: Int, CountableIntEnum {
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

enum PersonalInfoRow: Int, CountableIntEnum {
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

class CheckoutTableViewController: UIViewController {
    @IBOutlet private weak var tableView: UITableView!
    
    private let reservationCellHeight: CGFloat = 86
    private let paymentButtonHeight: CGFloat = 60
    private let paymentButtonMargin: CGFloat = 0
    
    private lazy var paymentButton: UIButton = {
        let _button = NSBundle.shp_resourceBundle()
            .loadNibNamed(String(PaymentButton),
                          owner: nil,
                          options: nil)
            .first as! UIButton
        _button.addTarget(self,
                          action: #selector(self.paymentButtonPressed),
                          forControlEvents: .TouchUpOutside)
        _button.backgroundColor = .shp_mutedGreen()
        _button.translatesAutoresizingMaskIntoConstraints = false
        return _button
    }()
    
    var facility: Facility?
    var rate: Rate?
    var indexPathsToValidate = [NSIndexPath]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.estimatedRowHeight = 60
        self.setupPaymentButton()
    }
    
    private func setupPaymentButton() {
        guard let
            rate = self.rate,
            price = NumberFormatter.dollarNoCentsStringFromCents(rate.price) else {
            return
        }
        
        self.tableView.contentInset = UIEdgeInsets(top: 0,
                                                   left: 0,
                                                   bottom: self.paymentButtonHeight,
                                                   right: 0)
        self.paymentButton.setTitle(String(format: LocalizedStrings.paymentButtonTitleFormat, price), forState: .Normal)
        self.view.addSubview(self.paymentButton)
        let horizontalConstraints = NSLayoutConstraint.constraintsWithVisualFormat("|-margin-[paymentButton]-margin-|",
                                                                                   options: NSLayoutFormatOptions(rawValue: 0),
                                                                                   metrics: ["margin": paymentButtonMargin],
                                                                                   views: ["paymentButton": paymentButton])
        let verticalContraints = NSLayoutConstraint.constraintsWithVisualFormat("V:[paymentButton(height)]-margin-|",
                                                                                options: NSLayoutFormatOptions(rawValue: 0),
                                                                                metrics: ["margin": paymentButtonMargin, "height": paymentButtonHeight],
                                                                                views: ["paymentButton": paymentButton])
        self.view.addConstraints(horizontalConstraints)
        self.view.addConstraints(verticalContraints)
    }
    
    //MARK: Actions
    
    func paymentButtonPressed() {
        //TODO: Create Stripe token and reservation
    }
    
    //MARK: Helpers
    
    private func configureCell(cell: ReservationInfoTableViewCell,
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
    
    private func configureCell(cell: PersonalInfoTableViewCell, row: PersonalInfoRow) {
        cell.titleLabel.text = row.title()
        cell.textField.placeholder = row.placeholder()
        cell.type = row
        
        switch row {
        case PersonalInfoRow.FullName:
            cell.textField.autocapitalizationType = .Words
            cell.validationClosure = {
                fullName in
                try Validator.validateFullName(fullName)
            }
        case PersonalInfoRow.Email:
            cell.textField.autocapitalizationType = .None
            cell.textField.keyboardType = .EmailAddress
            cell.validationClosure = {
                email in
                try Validator.validateEmail(email)
            }
        case PersonalInfoRow.Phone:
            cell.textField.keyboardType = .PhonePad
            cell.validationClosure = {
                phone in
                try Validator.validatePhone(phone)
            }
        }
    }
    
    private func setPaymentButtonEnabled(enabled: Bool) {
        self.paymentButton.enabled = enabled
        self.paymentButton.backgroundColor = enabled ? .shp_green() : .shp_mutedGreen()
    }
}

//MARK: UITableViewDataSource

extension CheckoutTableViewController: UITableViewDataSource {
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return CheckoutSection.AllCases.count
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case CheckoutSection.ReservationInfo.rawValue,
             CheckoutSection.PersonalInfo.rawValue:
            return 3
        default:
            return 1
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
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
        
        if let cell = cell as? ValidatorCell {
            self.indexPathsToValidate.append(indexPath)
            cell.delegate = self
        }
        
        return cell
    }
}

//MARK: UITableViewDelegate

extension CheckoutTableViewController: UITableViewDelegate {
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        switch indexPath.section {
        case CheckoutSection.ReservationInfo.rawValue:
            return self.reservationCellHeight
        default:
            return UITableViewAutomaticDimension
        }
    }
    
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
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
    
    func tableView(tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return CGFloat.min
    }
}

//MARK: ValidatorCellDelegate

extension CheckoutTableViewController: ValidatorCellDelegate {
    func didValidateText() {
        var invalidCells = 0
        for indexPath in self.indexPathsToValidate {
            if let cell = self.tableView.cellForRowAtIndexPath(indexPath) as? ValidatorCell where !cell.valid {
                invalidCells += 1
            }
        }
        self.setPaymentButtonEnabled(invalidCells == 0)
    }
}