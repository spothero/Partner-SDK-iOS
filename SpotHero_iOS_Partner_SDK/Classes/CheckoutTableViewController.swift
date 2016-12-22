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

enum PersonalInfoRow {
    case
    Email,
    Phone,
    License
    
    init(facility: Facility, index: Int) {
        if index == 0 {
            self = .Email
        } else if index == 1 && facility.phoneNumberRequired {
            self = .Phone
        } else {
            self = .License
        }
    }
    
    func row(phoneNumberRequired: Bool) -> Int {
        switch self {
        case .Email:
            return 0
        case .Phone:
            return 1
        case .License:
            return phoneNumberRequired ? 2 : 1
        }
    }
    
    static func count(facility: Facility) -> Int {
        if facility.licensePlateRequired && facility.phoneNumberRequired {
            return 3
        } else if facility.licensePlateRequired || facility.phoneNumberRequired {
            return 2
        } else {
            return 1
        }
    }
    
    
    func title() -> String {
        switch self {
        case .Email:
            return LocalizedStrings.Email
        case .Phone:
            return LocalizedStrings.Phone
        case .License:
            return LocalizedStrings.LicensePlate
        }
    }
    
    func placeholder() -> String {
        switch self {
        case .Email:
            return LocalizedStrings.EmailAddressPlaceHolder
        case .Phone:
            return LocalizedStrings.PhoneNumberPlaceHolder
        case .License:
            return LocalizedStrings.LicensePlatePlaceHolder
        }
    }
}

class CheckoutTableViewController: UIViewController {
    @IBOutlet private weak var tableView: UITableView!
    @IBOutlet private weak var closeButton: UIBarButtonItem!
    @IBOutlet var toolbar: UIToolbar!
    
    private let reservationCellHeight: CGFloat = 60
    private let paymentButtonHeight: CGFloat = 60
    private let paymentButtonMargin: CGFloat = 0
    
    private lazy var paymentButton: UIButton = {
        #if swift(>=2.3)
            let _button = NSBundle.shp_resourceBundle()
                .loadNibNamed(String(PaymentButton),
                              owner: nil,
                              options: nil)!
                .first as! UIButton
        #else
            let _button = NSBundle.shp_resourceBundle()
            .loadNibNamed(String(PaymentButton),
            owner: nil,
            options: nil)
            .first as! UIButton
        #endif
        
        
        _button.addTarget(self,
                          action: #selector(self.paymentButtonPressed),
                          forControlEvents: .TouchUpInside)
        _button.backgroundColor = .shp_mutedGreen()
        _button.translatesAutoresizingMaskIntoConstraints = false
        return _button
    }()
    
    var facility: Facility?
    var rate: Rate?
    var indexPathsToValidate = [NSIndexPath]()
    
    //MARK: - View Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.estimatedRowHeight = 60
        self.setupPaymentButton()
        self.registerForKeyboardNotifications()
        self.closeButton.accessibilityLabel = LocalizedStrings.Close
        self.view.accessibilityLabel = AccessibilityStrings.CheckoutScreen
    }
    
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        NSNotificationCenter
            .defaultCenter()
            .addObserver(self,
                         selector: #selector(applicationWillEnterForeground(_:)),
                         name: UIApplicationWillEnterForegroundNotification,
                         object: nil)
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
        NSNotificationCenter
            .defaultCenter()
            .removeObserver(self)
    }
    
    //MARK: UI Setup
    
    private func setupPaymentButton() {
        guard
            let rate = self.rate,
            let price = NumberFormatter.dollarNoCentsStringFromCents(rate.price) else {
                return
        }
        
        self.tableView.contentInset = UIEdgeInsets(top: 0,
                                                   left: 0,
                                                   bottom: self.paymentButtonHeight,
                                                   right: 0)
        if Testing.isUITesting() {
            self.paymentButton.setTitle(Constants.Test.ButtonTitle, forState: .Normal)
        } else {
            self.paymentButton.setTitle(String(format: LocalizedStrings.paymentButtonTitleFormat, price), forState: .Normal)
        }

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
    
    //MARK: Notification handling
    
    @objc private func applicationWillEnterForeground(notification: NSNotification) {
        guard let rate = self.rate else {
            return
        }
        
        //If the user comes back and the current date is after the rate start date,
        // boot the user back to the map with an apology.
        let roundedDown = NSDate().shp_roundDateToNearestHalfHour(roundDown: true)
        if roundedDown.shp_isAfterDate(rate.starts) {
            guard let navController = self.navigationController else {
                assertionFailure("No navigation controller?!")
                return
            }
            
            AlertView.presentErrorAlertView(LocalizedStrings.Sorry,
                                            message: LocalizedStrings.RateExpired,
                                            from: navController)
            navController.popViewControllerAnimated(true)
        }
    }
    
    //MARK: Actions
    
    func paymentButtonPressed() {
        ProgressHUD.showHUDAddedTo(self.view, withText: LocalizedStrings.Loading)
        self.getStripeToken {
            [weak self]
            token in
            guard let token = token else {
                ProgressHUD.hideHUDForView(self?.view)
                return
            }
            
            self?.createReservation(token) {
                success in
                ProgressHUD.hideHUDForView(self?.view)
                if success {
                    self?.performSegueWithIdentifier(Constants.Segue.Confirmation, sender: nil)
                } else {
                    AlertView.presentErrorAlertView(message: LocalizedStrings.CreateReservationErrorMessage, from: self)
                }
            }
        }
    }
    
    @IBAction func doneButtonPressed(sender: AnyObject) {
        self.view.endEditing(true)
    }
    
    @IBAction func closeButtonPressed(_ sender: AnyObject) {
        SpotHeroPartnerSDK.SharedInstance.reportSDKClosed()
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    //MARK: Helpers
    
    /**
     Gets a stripe token for the user's credit card
     
     - parameter completion: Passes in stripe token if it is able to create it. Otherwise nil is passed in.
     */
    func getStripeToken(completion: (String?) -> ()) {
        guard let paymentCell = self.tableView.cellForRowAtIndexPath(NSIndexPath(forRow: 0, inSection: CheckoutSection.PaymentInfo.rawValue)) as? PaymentInfoTableViewCell else {
            assertionFailure("Cannot get payment cell")
            completion(nil)
            return
        }
        
        StripeWrapper.getToken(paymentCell.cardNumber,
                               expirationMonth: paymentCell.expirationMonth,
                               expirationYear: paymentCell.expirationYear,
                               cvc: paymentCell.cvc) {
                                [weak self]
                                token, error in
                                guard let token = token else {
                                    if let error = error as? StripeAPIError {
                                        switch error {
                                        case .CannotGetToken(let message):
                                            AlertView.presentErrorAlertView(message: message, from: self)
                                        }
                                    } else {
                                        AlertView.presentErrorAlertView(message: LocalizedStrings.CreateReservationErrorMessage, from: self)
                                    }
                                    completion(nil)
                                    return
                                }
                                
                                completion(token)
        }
    }
    
    /**
     creates the reservation. ONLY CALL AFTER GETTING STRIPE TOKEN
     
     - parameter token:      Stripe Token
     - parameter completion: Passing in a bool. True if reservation was successfully created, false if an error occured
     */
    func createReservation(token: String, completion: (Bool) -> ()) {
        guard
            let facility = self.facility,
            let rate = self.rate else {
                assertionFailure("No facility or rate")
                completion(false)
                return
        }
        
        guard
            let emailCell = self.tableView.cellForRowAtIndexPath(NSIndexPath(forRow: PersonalInfoRow.Email.row(facility.phoneNumberRequired), inSection: CheckoutSection.PersonalInfo.rawValue)) as? PersonalInfoTableViewCell,
            let email = emailCell.textField.text else {
                assertionFailure("Cannot get email cell")
                completion(false)
                return
        }
        
        var phoneNumber: String?
        if let
            phoneCell = self.tableView.cellForRowAtIndexPath(NSIndexPath(forRow: PersonalInfoRow.Phone.row(facility.phoneNumberRequired), inSection: CheckoutSection.PersonalInfo.rawValue)) as? PersonalInfoTableViewCell
            where facility.phoneNumberRequired,
            let text = phoneCell.textField.text {
                phoneNumber = text
        }
        
        var license: String?
        
        if let
            licenseCell = self.tableView.cellForRowAtIndexPath(NSIndexPath(forRow: PersonalInfoRow.License.row(facility.phoneNumberRequired), inSection: CheckoutSection.PersonalInfo.rawValue)) as? PersonalInfoTableViewCell
            where facility.licensePlateRequired {
                license = licenseCell.textField.text
        }
        
        ReservationAPI.createReservation(facility,
                                         rate: rate,
                                         email: email,
                                         phone: phoneNumber,
                                         stripeToken: token,
                                         license: license,
                                         completion: {
                                            [weak self]
                                            reservation, error in
                                            guard let reservation = reservation else {
                                                completion(false)
                                                return
                                            }
                                            
                                            if
                                                let rate = self?.rate,
                                                let facility = self?.facility {
                                                MixpanelWrapper.track(.UserPurchased, properties: [
                                                    .Price: rate.displayPrice,
                                                    .SpotID: facility.parkingSpotID,
                                                    .SpotHeroCity: facility.city,
                                                    .ReservationLength: rate.duration,
                                                    .Distance: facility.distanceInMeters,
                                                    .DistanceFromSearchCenter: facility.distanceInMeters,
                                                    .PaymentType: "Credit Card",
                                                    .RequiredLicensePlate: facility.licensePlateRequired,
                                                    .RequiredPhoneNumber: facility.phoneNumberRequired,
                                                    .EmailAddress: email,
                                                    .PhoneNumber: phoneNumber ?? "",
                                                    .TimeFromReservationStart: rate.minutesToReservation(),
                                                    ])
                                            }
                                            completion(true)
            })
    }
    
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
            cell.primaryLabel.text = self.getDateFormatString(rate.starts)
            cell.secondaryLabel.text = DateFormatter.TimeOnly.stringFromDate(rate.starts)
        case ReservationInfoRow.Ends:
            cell.primaryLabel.text = self.getDateFormatString(rate.ends)
            cell.secondaryLabel.text = DateFormatter.TimeOnly.stringFromDate(rate.ends)
        }
    }
    
    private func getDateFormatString(date: NSDate) -> String {
        guard let calendar = NSCalendar(calendarIdentifier: NSGregorianCalendar) where calendar.isDateInToday(date) || calendar.isDateInTomorrow(date) else {
            return DateFormatter.DayOfWeekWithDate.stringFromDate(date)
        }
        
        return "\(DateFormatter.RelativeDate.stringFromDate(date)), \(DateFormatter.DateOnlyNoYear.stringFromDate(date))"
    }
    
    private func configureCell(cell: PersonalInfoTableViewCell, row: PersonalInfoRow) {
        cell.titleLabel.text = row.title()
        cell.textField.placeholder = row.placeholder()
        cell.textField.accessibilityLabel = row.placeholder()
        cell.textField.inputAccessoryView = self.toolbar
        cell.type = row
        cell.personalInfoCellDelegate = self
        
        switch row {
        case PersonalInfoRow.Email:
            cell.textField.autocapitalizationType = .None
            cell.textField.keyboardType = .EmailAddress
            cell.textField.returnKeyType = .Next
            cell.validationClosure = {
                email in
                try Validator.validateEmail(email)
            }
        case PersonalInfoRow.Phone:
            cell.textField.keyboardType = .PhonePad
            cell.valid = true
            cell.validationClosure = {
                phone in
                try Validator.validatePhone(phone)
            }
        case PersonalInfoRow.License:
            cell.textField.autocapitalizationType = .AllCharacters
            cell.valid = true
            cell.validationClosure = {
                license in
                try Validator.validateLicense(license)
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
        guard let checkoutSection = CheckoutSection(rawValue: section) else {
            assertionFailure("Could not create a checkout section. Section number: \(section)")
            return 0
        }
        switch checkoutSection {
        case .ReservationInfo:
            return ReservationInfoRow.AllCases.count
        case .PersonalInfo:
            guard let facility = self.facility else {
                assertionFailure("self.facility is not set!")
                return 0
            }
            
            return PersonalInfoRow.count(facility)
        case .PaymentInfo:
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
        
        if
            let cell = cell as? ReservationInfoTableViewCell,
            let facility = self.facility,
            let rate = self.rate,
            let row = ReservationInfoRow(rawValue: indexPath.row) {
            
            self.configureCell(cell,
                               row: row,
                               facility: facility,
                               rate: rate)
        } else if
            let cell = cell as? PersonalInfoTableViewCell,
            let facility = self.facility {
                let row = PersonalInfoRow(facility: facility, index: indexPath.row)
                self.configureCell(cell, row: row)
        } else if let cell = cell as? PaymentInfoTableViewCell {
            cell.creditCardTextField.inputAccessoryView = self.toolbar
            cell.expirationDateTextField.inputAccessoryView = self.toolbar
            cell.cvcTextField.inputAccessoryView = self.toolbar
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
    
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        // Number chosen to match designs
        return 32
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

// MARK: - KeyboardNotification

extension CheckoutTableViewController: KeyboardNotification {
    func registerForKeyboardNotifications() {
        NSNotificationCenter.defaultCenter().addObserverForName(UIKeyboardWillShowNotification,
                                                                object: nil,
                                                                queue: nil) {
                                                                    [weak self]
                                                                    notification in
                                                                    guard
                                                                        let userInfo = notification.userInfo,
                                                                        let frame = userInfo[UIKeyboardFrameEndUserInfoKey] as? NSValue else {
                                                                            return
                                                                    }
                                                                    
                                                                    let rect = frame.CGRectValue()
                                                                    self?.tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: rect.height, right: 0)
        }
        
        NSNotificationCenter.defaultCenter().addObserverForName(UIKeyboardWillHideNotification,
                                                                object: nil,
                                                                queue: nil) {
                                                                    [weak self]
                                                                    notification in
                                                                    guard let paymentButtonHeight = self?.paymentButtonHeight else {
                                                                        return
                                                                    }
                                                                    
                                                                    self?.tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: paymentButtonHeight, right: 0)
        }
    }
}

// MARK: - PersonalInfoTableViewCellDelegate

extension CheckoutTableViewController: PersonalInfoTableViewCellDelegate {
    func textFieldShouldReturn(type: PersonalInfoRow) {
        guard let facility = self.facility else {
            return
        }
        let indexPath = NSIndexPath(forRow: type.row(facility.phoneNumberRequired) + 1, inSection: CheckoutSection.PersonalInfo.rawValue)
        if let cell = self.tableView.cellForRowAtIndexPath(indexPath) as? PersonalInfoTableViewCell {
            cell.textField.becomeFirstResponder()
        }
    }
}
