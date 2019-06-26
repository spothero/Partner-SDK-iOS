//
//  CheckoutViewController.swift
//  Pods
//
//  Created by Matthew Reed on 7/27/16.
//
//

import UIKit

class CheckoutViewController: SpotHeroPartnerViewController {
    @IBOutlet private var detailsLabel: UILabel!
    @IBOutlet private var addressLabel: UILabel!
    @IBOutlet private var dateLabel: UILabel!
    @IBOutlet private var emailLabel: UILabel!
    @IBOutlet private var emailTextField: SHPTextField!
    @IBOutlet private var phoneNumberLabel: UILabel!
    @IBOutlet private var phoneNumberTextField: SHPTextField!
    @IBOutlet private var phoneNumberContainerView: UIView!
    @IBOutlet private var phoneNumberErrorLabel: ErrorLabel!
    @IBOutlet private var phoneNumberErrorContainer: UIView!
    @IBOutlet private var paymentInfoView: PaymentInfoView!
    @IBOutlet private var licensePlateContainerView: UIView!
    @IBOutlet private var licensePlateTextField: SHPTextField!
    @IBOutlet private var licensePlateLabel: UILabel!
    @IBOutlet private var paymentButton: UIButton!
    @IBOutlet private var paymentButtonContainer: UIView!
    @IBOutlet private var emailErrorLabel: ErrorLabel!
    @IBOutlet private var emailErrorContainer: UIView!
    @IBOutlet private var scrollView: UIScrollView!
    @IBOutlet private var saveInfoButton: UIButton!
    
    private var sanitizedPhoneNumber: String? {
        guard let phoneNumberText = self.phoneNumberTextField.text else {
            return nil
        }
        return PhoneNumberFormatter.sanitizePhoneNumber(phoneNumberText)
    }
    
    private var isPaymentValid: Bool {
        return self.paymentInfoView.isValid
    }
    
    private var isEmailValid: Bool {
        guard let emailText = self.emailTextField.text else {
            return false
        }
        return (try? Validator.validateEmail(emailText)) ?? false
    }
    
    private var isPhoneNumberValid: Bool {
        guard let phoneNumber = self.sanitizedPhoneNumber else {
            return false
        }
        return PhoneNumberFormatter.isValid(phoneNumber)
    }
    
    private var isLicensePlateValid: Bool {
        return self.licensePlateTextField?.text?.isEmpty == false
    }
    
    var facility: Facility?
    var rate: Rate?
    
    // MARK: - View Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupViews()
        self.setupFacility()
        
        MixpanelWrapper.track(.viewedCheckout)
    }
    
    func setupViews() {
        self.title = LocalizedStrings.Checkout
        self.detailsLabel.text = LocalizedStrings.Details
        self.emailLabel.text = LocalizedStrings.Email
        self.phoneNumberLabel.text = LocalizedStrings.Phone
        self.paymentButtonContainer.shp_addShadow()
        self.paymentInfoView.delegate = self
        self.emailTextField.delegate = self
        self.emailTextField.setAttributedPlaceholder(text: LocalizedStrings.EmailAddressPlaceHolder)
        self.emailTextField.keyboardType = .emailAddress
        self.phoneNumberTextField.delegate = self
        self.phoneNumberTextField.setAttributedPlaceholder(text: LocalizedStrings.PhoneNumberPlaceHolder)
        self.phoneNumberTextField.keyboardType = .phonePad
        self.phoneNumberErrorLabel.text = LocalizedStrings.PhoneNumberFormattingErrorMessage
        self.licensePlateLabel.text = LocalizedStrings.License
        self.licensePlateTextField.setAttributedPlaceholder(text: LocalizedStrings.LicensePlate)
        self.emailErrorLabel.text = LocalizedStrings.EmailErrorMessage
        self.addressLabel.textColor = .shp_tire
        self.saveInfoButton.setTitle(LocalizedStrings.SaveInfo, for: .normal)
        if
            let username = UserDefaultsWrapper.username,
            let lastFour = UserDefaultsWrapper.lastFour,
            let cardType = UserDefaultsWrapper.cardType,
            UserDefaultsWrapper.isInfoSaved {
                self.emailTextField.text = username
                self.paymentInfoView.setupSavedCard(lastFour: lastFour, cardType: cardType)
                if let savedNumber = UserDefaultsWrapper.phoneNumber {
                    self.phoneNumberTextField.text = PhoneNumberFormatter.formatPhoneNumberFromMachineFormat(oldNumber: savedNumber)
                }
                if let savedLicensePlate = UserDefaultsWrapper.licensePlate {
                    self.licensePlateTextField.text = savedLicensePlate
                }
        }
        self.updatePaymentButtonEnabledStatus()
    }
    
    func setupFacility() {
        guard
            let facility = self.facility,
            let rate = self.rate else {
                assertionFailure("You should have a facility and rate right now")
                return
        }
        
        self.addressLabel.text = facility.title
        let formatter = SHPDateFormatter.DateWithTime
        if let timeZoneIdentifier = self.facility?.timeZone {
            formatter.timeZone = TimeZone(identifier: timeZoneIdentifier)
        }
        self.dateLabel.text = "\(formatter.string(from: rate.starts)) - \(formatter.string(from: rate.ends))"
        if let priceString = SHPNumberFormatter.dollarNoCentsStringFromCents(rate.price) {
            self.paymentButton.setTitle(String(format: LocalizedStrings.PaymentButtonTitleFormat, priceString),
                                        for: .normal)
        }

        if !facility.phoneNumberRequired {
            self.phoneNumberErrorContainer.removeFromSuperview()
            self.phoneNumberContainerView.removeFromSuperview()
        }

        if !facility.licensePlateRequired {
            self.licensePlateContainerView.removeFromSuperview()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        NotificationCenter
            .default
            .addObserver(self,
                         selector: #selector(applicationWillEnterForeground(_:)),
                         name: UIApplication.willEnterForegroundNotification,
                         object: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        NotificationCenter
            .default
            .removeObserver(self)
    }
    
    override func willShowKeyboard(notification: Notification) {
        guard
            let userInfo = notification.userInfo,
            let keyboardFrame = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect else {
                return
        }
        
        let inset = UIEdgeInsets(top: 0,
                                 left: 0,
                                 bottom: keyboardFrame.height + HeightsAndWidths.Margins.Large,
                                 right: 0)
        
        self.scrollView.contentInset = inset
    }
    
    override func willHideKeyboard(notification: Notification) {
        self.scrollView.contentInset = UIEdgeInsets.zero
    }
    
    private func updatePaymentButtonEnabledStatus() {
        var readyForPayment = self.isPaymentValid && self.isEmailValid
        if self.facility?.phoneNumberRequired == true {
            readyForPayment = readyForPayment && self.isPhoneNumberValid
        }
        if self.facility?.licensePlateRequired == true {
            readyForPayment = readyForPayment && self.isLicensePlateValid
        }
        self.paymentButton.isEnabled = readyForPayment
    }
    
    // MARK: Notification handling
    
    @objc
    private func applicationWillEnterForeground(_ notification: Notification) {
        if !self.datesValid() {
            self.showDatesInPastAlert { [weak self] _ in
                self?.navigationController?.popToRootViewController(animated: true)
            }
        }
    }
    
    private func showDatesInPastAlert(handler: ((UIAlertAction) -> Void)? = nil) {
        // Show an alert telling the user to update their times
        AlertView.presentErrorAlertView(LocalizedStrings.Error,
                                        message: LocalizedStrings.RateExpired,
                                        from: self,
                                        handler: handler)
    }
    
    private func datesValid() -> Bool {
        guard let rate = self.rate else {
            return false
        }
        return rate.starts.shp_isWithinAHalfHourOfDate(Date())
    }
    
    // MARK: Actions
    
    @IBAction private func paymentButtonTapped(_ sender: Any) {
        guard let email = self.emailTextField.text, self.datesValid() else {
            self.showDatesInPastAlert()
            return
        }
        
        ProgressHUD.showHUDAddedTo(self.view, withText: LocalizedStrings.Loading)
        
        do {
            let keychainItem = KeychainPasswordItem(account: email)
            let partnerRenterCardToken = try keychainItem.readPassword()
            self.createReservation(partnerRenterCardToken: partnerRenterCardToken,
                                   completion: self.createReservationCompletion(success:error:))
        } catch {
            self.getStripeToken { [weak self] token in
                guard
                    let token = token,
                    let strongSelf = self else {
                        ProgressHUD.hideHUDForView(self?.view)
                        return
                }
                
                self?.createReservation(token: token,
                                        completion: strongSelf.createReservationCompletion(success:error:))
            }
        }
    }
    
    @IBAction private func licensePlateFieldTapped() {
        let doesNotHaveSavedLicensePlate = UserDefaultsWrapper.licensePlate?.isEmpty ?? true
        // if the user is trying to change a saved license plate
        guard doesNotHaveSavedLicensePlate else {
            // make sure they know that they will need to re-enter everything
            self.showEditSavedInformationAlert()
            return
        }
        let licensePlateViewController = LicensePlateViewController.fromStoryboard()
        licensePlateViewController.delegate = self
        self.navigationController?.pushViewController(licensePlateViewController, animated: true)
    }
    
    @IBAction private func doneButtonTapped() {
        self.view.endEditing(true)
    }
    
    @IBAction private func saveInfoButtonTapped(_ sender: Any) {
        self.saveInfoButton.isSelected.toggle()
    }
    
    // MARK: Helpers
    
    /**
     Gets a stripe token for the user's credit card
     
     - parameter completion: Passes in stripe token if it is able to create it. Otherwise nil is passed in.
     */
    private func getStripeToken(_ completion: @escaping (String?) -> Void) {
        StripeWrapper.getToken(self.paymentInfoView.cardNumber,
                               expirationMonth: self.paymentInfoView.expirationMonth,
                               expirationYear: self.paymentInfoView.expirationYear,
                               cvc: self.paymentInfoView.cvc) { [weak self] token, error in
                                guard let self = self else {
                                    return
                                }
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
     creates the reservation.
     
     - parameter token:      Stripe Token
     - parameter completion: Passing in a bool. True if reservation was successfully created, false if an error occured
     */
    private func createReservation(token: String? = nil,
                                   partnerRenterCardToken: String? = nil,
                                   completion: @escaping (Bool, Error?) -> Void) {
        guard
            let facility = self.facility,
            let rate = self.rate else {
                assertionFailure("No facility or rate")
                completion(false, nil)
                return
        }
        
        guard let email = self.emailTextField.text else {
            assertionFailure("Cannot get email cell")
            completion(false, nil)
            return
        }
        
        if self.saveInfoButton.isSelected == true {
            UserDefaultsWrapper.saveUserInfo(email: email,
                                             phoneNumber: self.sanitizedPhoneNumber,
                                             licensePlate: self.licensePlateTextField.text,
                                             lastFour: self.paymentInfoView.lastFour,
                                             cardType: self.paymentInfoView.cardType)
        } else {
            UserDefaultsWrapper.setIsInfoSaved(false)
        }
        
        var phoneNumberForReservation: String?
        if self.facility?.phoneNumberRequired == true {
            // only pass in phone number information if the spot requires it
            phoneNumberForReservation = self.sanitizedPhoneNumber
        }
        
        var licensePlateForReservation: String?
        if self.facility?.licensePlateRequired == true {
            // only pass in a license plate if the spot requires it
            licensePlateForReservation = self.licensePlateTextField.text
        }
        ReservationAPI.createReservation(facility,
                                         rate: rate,
                                         saveInfo: self.saveInfoButton.isSelected,
                                         email: email,
                                         phone: phoneNumberForReservation,
                                         license: licensePlateForReservation,
                                         stripeToken: token,
                                         partnerRenterCardToken: partnerRenterCardToken) { [weak self] _, error in
                                            guard error == nil else {
                                                completion(false, error)
                                                return
                                            }
                                            
                                            if
                                                let rate = self?.rate,
                                                let facility = self?.facility {
                                                MixpanelWrapper.track(.userPurchased, properties: [
                                                    .price: rate.displayPrice,
                                                    .spotID: facility.parkingSpotID,
                                                    .spotHeroCity: facility.city,
                                                    .reservationLength: rate.duration,
                                                    .distance: facility.distanceInMeters,
                                                    .distanceFromSearchCenter: facility.distanceInMeters,
                                                    .paymentType: "Credit Card",
                                                    .requiredLicensePlate: facility.licensePlateRequired,
                                                    .requiredPhoneNumber: facility.phoneNumberRequired,
                                                    .emailAddress: email,
                                                    .timeFromReservationStart: rate.minutesToReservation(),
                                                ])
                                            }
                                            completion(true, nil)
        }
    }
    
    private func createReservationCompletion(success: Bool, error: Error?) {
        ProgressHUD.hideHUDForView(self.view)
        if success {
            self.performSegue(withIdentifier: Constants.Segue.Confirmation, sender: nil)
        } else {
            
            if
                let error = error as NSError?,
                let message = error.userInfo[SpotHeroPartnerSDK.UnlocalizedDescriptionKey] as? String {
                AlertView.presentErrorAlertView(message: message, from: self)
            } else {
                AlertView.presentErrorAlertView(message: LocalizedStrings.CreateReservationErrorMessage, from: self)
            }
        }
    }
    
    private func showEditSavedInformationAlert() {
        let alertActions = [
            UIAlertAction(title: LocalizedStrings.Cancel, style: .default),
            UIAlertAction(title: LocalizedStrings.Edit, style: .default) { _ in
                self.clearSavedInformation()
                self.updatePaymentButtonEnabledStatus()
            },
        ]
        AlertView.presentAlert(title: LocalizedStrings.EditInfoWarningTitle,
                               message: LocalizedStrings.EditInfoWarningMessage,
                               from: self,
                               alertActions: alertActions)
    }
    
    private func clearSavedInformation() {
        self.emailTextField.text = nil
        self.phoneNumberTextField.text = nil
        self.licensePlateTextField.text = nil
        self.paymentInfoView.removeUserInfo()
        UserDefaultsWrapper.clearUserInfo()
    }
}

// MARK: - PaymentInfoView

extension CheckoutViewController: PaymentInfoViewDelegate {
    func didValidateText(paymentInfoView: PaymentInfoView) {
        if !self.isPaymentValid {
            self.scrollView.scrollRectToVisible(self.paymentInfoView.frame, animated: true)
        }
        self.updatePaymentButtonEnabledStatus()
    }
    
    func didTapRemoveButton(paymentInfoView: PaymentInfoView) {
        // if the user is trying to remove a credit card, warn them about deleting saved data
        self.showEditSavedInformationAlert()
    }
}

extension CheckoutViewController: UITextFieldDelegate {
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        // if a user is changing saved information
        // make sure they know that they will need to re-enter everything
        guard !UserDefaultsWrapper.isInfoSaved else {
            if textField == self.phoneNumberTextField {
                // allow adding a phone number if one doesn't exist
                let hasNotSavedPhoneNumber = UserDefaultsWrapper.phoneNumber?.isEmpty ?? true
                if hasNotSavedPhoneNumber {
                    return true
                }
            }
            self.showEditSavedInformationAlert()
            return false
        }
        return true
    }
    
    func textField(_ textField: UITextField,
                   shouldChangeCharactersIn range: NSRange,
                   replacementString string: String) -> Bool {
        if textField == self.phoneNumberTextField {
            // If the format function handles the text change, don't replace the characters in this range again in this function
            // format returns boolean that represents whether the function changed the text or not
            let shouldReplaceText = !PhoneNumberFormatter.format(phoneTextField: textField,
                                                                 forRange: range,
                                                                 replacementString: string)
            if self.isPhoneNumberValid {
                textField.resignFirstResponder()
            }
            return shouldReplaceText
        }
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if textField == self.emailTextField {
            self.emailErrorContainer.isHidden = self.isEmailValid
            if !self.isEmailValid {
                self.scrollView.scrollRectToVisible(self.emailErrorContainer.frame, animated: true)
            }
        } else if textField == self.phoneNumberTextField {
            self.phoneNumberErrorContainer.isHidden = self.isPhoneNumberValid
            if !self.isPhoneNumberValid {
                self.scrollView.scrollRectToVisible(self.phoneNumberErrorContainer.frame, animated: true)
            }
        }
        self.updatePaymentButtonEnabledStatus()
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField === self.emailTextField {
            if UserDefaultsWrapper.isInfoSaved {
                self.view.endEditing(true)
            } else if self.facility?.phoneNumberRequired == true {
                self.phoneNumberTextField.becomeFirstResponder()
            } else {
                self.paymentInfoView.becomeActive()
            }
        }
        return true
    }
}

// MARK: - LicensePlateViewControllerDelegate

extension CheckoutViewController: LicensePlateViewControllerDelegate {
    func addedLicensePlate(_ licensePlate: String) {
        self.licensePlateTextField.text = licensePlate
        self.updatePaymentButtonEnabledStatus()
        self.navigationController?.popToViewController(self, animated: true)
    }
}
