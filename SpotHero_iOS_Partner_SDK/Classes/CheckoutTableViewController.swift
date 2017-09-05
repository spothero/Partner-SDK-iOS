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
    reservationInfo,
    personalInfo,
    paymentInfo
    
    func reuseIdentifier() -> String {
        switch self {
        case .reservationInfo:
            return ReservationInfoTableViewCell.reuseIdentifier
        case .personalInfo:
            return PersonalInfoTableViewCell.reuseIdentifier
        case .paymentInfo:
            return PaymentInfoTableViewCell.reuseIdentifier
        }
    }
}

enum ReservationInfoRow: Int, CountableIntEnum {
    case
    address,
    starts,
    ends
    
    func title() -> String {
        switch self {
        case .address:
            return LocalizedStrings.Address
        case .starts:
            return LocalizedStrings.Starts
        case .ends:
            return LocalizedStrings.Ends
        }
    }
}

enum PersonalInfoRow {
    case
    email,
    phone,
    license
    
    init(facility: Facility, index: Int) {
        if index == 0 {
            self = .email
        } else if index == 1 && facility.phoneNumberRequired {
            self = .phone
        } else {
            self = .license
        }
    }
    
    func row(_ phoneNumberRequired: Bool) -> Int {
        switch self {
        case .email:
            return 0
        case .phone:
            return 1
        case .license:
            return phoneNumberRequired ? 2 : 1
        }
    }
    
    static func count(_ facility: Facility) -> Int {
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
        case .email:
            return LocalizedStrings.Email
        case .phone:
            return LocalizedStrings.Phone
        case .license:
            return LocalizedStrings.LicensePlate
        }
    }
    
    func placeholder() -> String {
        switch self {
        case .email:
            return LocalizedStrings.EmailAddressPlaceHolder
        case .phone:
            return LocalizedStrings.PhoneNumberPlaceHolder
        case .license:
            return LocalizedStrings.LicensePlatePlaceHolder
        }
    }
}

class CheckoutTableViewController: UIViewController {
    
    @IBOutlet fileprivate weak var tableView: UITableView!
    @IBOutlet private weak var closeButton: UIBarButtonItem!
    @IBOutlet private(set) var toolbar: UIToolbar!
    
    fileprivate let reservationCellHeight: CGFloat = 60
    fileprivate let paymentButtonHeight: CGFloat = 60
    private let paymentButtonMargin: CGFloat = 0
    
    private lazy var paymentButton: UIButton = {
        var button: UIButton
        if let nibButton = Bundle
                                .shp_resourceBundle()
                                .loadNibNamed(String(describing: PaymentButton.self),
                                              owner: nil,
                                              options: nil)?
                                .first as? UIButton {
            button = nibButton
        } else {
            assertionFailure("Could not load button from nib")
            button = UIButton(type: .custom)
        }
        
        button.addTarget(self,
                          action: #selector(self.paymentButtonPressed),
                          for: .touchUpInside)
        button.backgroundColor = .shp_mutedGreen()
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    var facility: Facility?
    var rate: Rate?
    var indexPathsToValidate = [IndexPath]()
    
    //MARK: - View Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.estimatedRowHeight = 60
        self.setupPaymentButton()
        self.registerForKeyboardNotifications()
        self.closeButton.accessibilityLabel = LocalizedStrings.Close
        self.view.accessibilityLabel = AccessibilityStrings.CheckoutScreen
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        NotificationCenter
            .default
            .addObserver(self,
                         selector: #selector(applicationWillEnterForeground(_:)),
                         name: .UIApplicationWillEnterForeground,
                         object: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        NotificationCenter
            .default
            .removeObserver(self)
    }
    
    //MARK: UI Setup
    
    private func setupPaymentButton() {
        guard
            let rate = self.rate,
            let price = SHPNumberFormatter.dollarNoCentsStringFromCents(rate.price) else {
                return
        }
        
        self.tableView.contentInset = UIEdgeInsets(top: 0,
                                                   left: 0,
                                                   bottom: self.paymentButtonHeight,
                                                   right: 0)
        
        if TestingHelper.isUITesting() {
            self.paymentButton.setTitle(Constants.Test.ButtonTitle, for: .normal)
        } else {
            self.paymentButton.setTitle(String(format: LocalizedStrings.paymentButtonTitleFormat, price), for: .normal)
        }
        
        self.view.addSubview(self.paymentButton)
        let horizontalConstraints = NSLayoutConstraint.constraints(withVisualFormat: "|-margin-[paymentButton]-margin-|",
                                                                   options: NSLayoutFormatOptions(rawValue: 0),
                                                                   metrics: ["margin": paymentButtonMargin],
                                                                   views: ["paymentButton": paymentButton])
        let verticalContraints = NSLayoutConstraint.constraints(withVisualFormat: "V:[paymentButton(height)]-margin-|",
                                                                options: NSLayoutFormatOptions(rawValue: 0),
                                                                metrics: ["margin": paymentButtonMargin, "height": paymentButtonHeight],
                                                                views: ["paymentButton": paymentButton])
        self.view.addConstraints(horizontalConstraints)
        self.view.addConstraints(verticalContraints)
    }
    
    //MARK: Notification handling
    
    @objc private func applicationWillEnterForeground(_ notification: Notification) {
        guard let rate = self.rate else {
            return
        }
        
        //If the user comes back and the current date is after the rate start date,
        // boot the user back to the map with an apology.
        let roundedDown = Date().shp_roundDateToNearestHalfHour(roundDown: true)
        if roundedDown.shp_isAfterDate(rate.starts) {
            guard let navController = self.navigationController else {
                assertionFailure("No navigation controller?!")
                return
            }
            
            AlertView.presentErrorAlertView(LocalizedStrings.Sorry,
                                            message: LocalizedStrings.RateExpired,
                                            from: navController)
            _ = navController.popViewController(animated: true)
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
                success, error in
                ProgressHUD.hideHUDForView(self?.view)
                if success {
                    self?.performSegue(withIdentifier: Constants.Segue.Confirmation, sender: nil)
                } else {
                    
                    if
                        let error = error as? NSError,
                        let userInfo = error.userInfo as? JSONDictionary,
                        let message = userInfo[SpotHeroPartnerSDK.UnlocalizedDescriptionKey] as? String {
                            AlertView.presentErrorAlertView(message: message, from: self)
                    } else {
                        AlertView.presentErrorAlertView(message: LocalizedStrings.CreateReservationErrorMessage, from: self)
                    }
                }
            }
        }
    }
    
    @IBAction func doneButtonPressed(_ sender: AnyObject) {
        self.view.endEditing(true)
    }
    
    @IBAction func closeButtonPressed(_ sender: AnyObject) {
        SpotHeroPartnerSDK.shared.reportSDKClosed()
        self.dismiss(animated: true, completion: nil)
    }
    //MARK: Helpers
    
    /**
     Gets a stripe token for the user's credit card
     
     - parameter completion: Passes in stripe token if it is able to create it. Otherwise nil is passed in.
     */
    func getStripeToken(_ completion: @escaping (String?) -> Void) {
        let paymentIndexPath = IndexPath(row: 0, section: CheckoutSection.paymentInfo.rawValue)
        guard let paymentCell = self.tableView.cellForRow(at: paymentIndexPath) as? PaymentInfoTableViewCell else {
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
                                        case .cannotGetToken(let message):
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
    func createReservation(_ token: String, completion: @escaping (Bool, Error?) -> Void) {
        guard
            let facility = self.facility,
            let rate = self.rate else {
                assertionFailure("No facility or rate")
                completion(false, nil)
                return
        }
        
        let emailIndexPath = IndexPath(row: PersonalInfoRow.email.row(facility.phoneNumberRequired),
                                       section: CheckoutSection.personalInfo.rawValue)
        
        guard
            let emailCell = self.tableView.cellForRow(at: emailIndexPath) as? PersonalInfoTableViewCell,
            let email = emailCell.textField.text else {
                assertionFailure("Cannot get email cell")
                completion(false, nil)
                return
        }
        
        var phoneNumber: String?
        if
            let phoneCell = self.tableView.cellForRow(at: IndexPath(row: PersonalInfoRow.phone.row(facility.phoneNumberRequired),
                                                                    section: CheckoutSection.personalInfo.rawValue)) as? PersonalInfoTableViewCell,
            let text = phoneCell.textField.text,
            facility.phoneNumberRequired {
                phoneNumber = text
        }
        
        var license: String?
        
        if
            let licenseCell = self.tableView.cellForRow(at: IndexPath(row: PersonalInfoRow.license.row(facility.phoneNumberRequired),
                                                                      section: CheckoutSection.personalInfo.rawValue)) as? PersonalInfoTableViewCell,
            facility.licensePlateRequired {
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
                                            guard reservation != nil else {
                                                completion(false, error)
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
                                            completion(true, nil)
        })
    }
    
    fileprivate func configureCell(_ cell: ReservationInfoTableViewCell,
                                   row: ReservationInfoRow,
                                   facility: Facility,
                                   rate: Rate) {
        cell.titleLabel.text = row.title()
        
        switch row {
        case ReservationInfoRow.address:
            cell.primaryLabel.text = facility.streetAddress
            cell.secondaryLabel.text = "\(facility.city), \(facility.state)"
        case ReservationInfoRow.starts:
            cell.primaryLabel.text = self.getDateFormatString(rate.starts)
            cell.secondaryLabel.text = SHPDateFormatter.TimeOnly.string(from: rate.starts)
        case ReservationInfoRow.ends:
            cell.primaryLabel.text = self.getDateFormatString(rate.ends)
            cell.secondaryLabel.text = SHPDateFormatter.TimeOnly.string(from: rate.ends)
        }
    }
    
    private func getDateFormatString(_ date: Date) -> String {
        let calendar = Calendar(identifier: Calendar.Identifier.gregorian)
        guard calendar.isDateInToday(date) || calendar.isDateInTomorrow(date) else {
            return SHPDateFormatter.DayOfWeekWithDate.string(from: date)
        }
        
        return "\(SHPDateFormatter.RelativeDate.string(from: date)), \(SHPDateFormatter.DateOnlyNoYear.string(from: date))"
    }
    
    fileprivate func configureCell(_ cell: PersonalInfoTableViewCell, row: PersonalInfoRow) {
        cell.titleLabel.text = row.title()
        cell.textField.placeholder = row.placeholder()
        cell.textField.accessibilityLabel = row.placeholder()
        cell.textField.inputAccessoryView = self.toolbar
        cell.type = row
        cell.personalInfoCellDelegate = self
        
        switch row {
        case PersonalInfoRow.email:
            cell.textField.autocapitalizationType = .none
            cell.textField.keyboardType = .emailAddress
            cell.textField.returnKeyType = .next
            cell.validationClosure = {
                email in
                try Validator.validateEmail(email)
            }
        case PersonalInfoRow.phone:
            cell.textField.keyboardType = .phonePad
            cell.valid = true
            cell.validationClosure = {
                phone in
                try Validator.validatePhone(phone)
            }
        case PersonalInfoRow.license:
            cell.textField.autocapitalizationType = .allCharacters
            cell.valid = true
            cell.validationClosure = {
                license in
                try Validator.validateLicense(license)
            }
        }
    }
    
    fileprivate func setPaymentButtonEnabled(_ enabled: Bool) {
        self.paymentButton.isEnabled = enabled
        self.paymentButton.backgroundColor = enabled ? .shp_green() : .shp_mutedGreen()
    }
}

//MARK: UITableViewDataSource

extension CheckoutTableViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return CheckoutSection.AllCases.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let checkoutSection = CheckoutSection(rawValue: section) else {
            assertionFailure("Could not create a checkout section. Section number: \(section)")
            return 0
        }
        switch checkoutSection {
        case .reservationInfo:
            return ReservationInfoRow.AllCases.count
        case .personalInfo:
            guard let facility = self.facility else {
                assertionFailure("self.facility is not set!")
                return 0
            }
            
            return PersonalInfoRow.count(facility)
        case .paymentInfo:
            return 1
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: UITableViewCell
        if let section = CheckoutSection(rawValue: indexPath.section) {
            cell = tableView.dequeueReusableCell(withIdentifier: section.reuseIdentifier(), for: indexPath)
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
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch indexPath.section {
        case CheckoutSection.reservationInfo.rawValue:
            return self.reservationCellHeight
        default:
            return UITableViewAutomaticDimension
        }
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        guard let checkoutSection = CheckoutSection(rawValue: section) else {
            return nil
        }
        
        switch checkoutSection {
        case CheckoutSection.reservationInfo:
            return LocalizedStrings.ReservationInfo
        case CheckoutSection.personalInfo:
            return LocalizedStrings.PersonalInfo
        case CheckoutSection.paymentInfo:
            return LocalizedStrings.PaymentInfo
        }
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return CGFloat.leastNormalMagnitude
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        // Number chosen to match designs
        return 32
    }
}

//MARK: ValidatorCellDelegate

extension CheckoutTableViewController: ValidatorCellDelegate {
    func didValidateText() {
        var invalidCells = 0
        for indexPath in self.indexPathsToValidate {
            if let cell = self.tableView.cellForRow(at: indexPath) as? ValidatorCell, !cell.valid {
                invalidCells += 1
            }
        }
        self.setPaymentButtonEnabled(invalidCells == 0)
    }
}

// MARK: - KeyboardNotification

extension CheckoutTableViewController: KeyboardNotification {
    func registerForKeyboardNotifications() {
        NotificationCenter
            .default
            .addObserver(forName: .UIKeyboardWillShow,
                         object: nil,
                         queue: nil) {
                            [weak self]
                            notification in
                            guard
                                let userInfo = notification.userInfo,
                                let frame = userInfo[UIKeyboardFrameEndUserInfoKey] as? CGRect else {
                                    return
                            }
                            
                            self?.tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: frame.height, right: 0)
        }
        
        NotificationCenter
            .default
            .addObserver(forName: .UIKeyboardWillHide,
                         object: nil,
                         queue: nil) {
                            [weak self]
                            _ in
                            guard let paymentButtonHeight = self?.paymentButtonHeight else {
                                return
                            }
                            
                            self?.tableView.contentInset = UIEdgeInsets(top: 0,
                                                                        left: 0,
                                                                        bottom: paymentButtonHeight,
                                                                        right: 0)
        }
    }
}

// MARK: - PersonalInfoTableViewCellDelegate

extension CheckoutTableViewController: PersonalInfoTableViewCellDelegate {
    func textFieldShouldReturn(_ type: PersonalInfoRow) {
        guard let facility = self.facility else {
            return
        }
        let indexPath = IndexPath(row: type.row(facility.phoneNumberRequired) + 1, section: CheckoutSection.personalInfo.rawValue)
        if let cell = self.tableView.cellForRow(at: indexPath) as? PersonalInfoTableViewCell {
            cell.textField.becomeFirstResponder()
        }
    }
}
