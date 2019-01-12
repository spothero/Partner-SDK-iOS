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
    @IBOutlet fileprivate var emailTextField: SHPTextField!
    @IBOutlet fileprivate var paymentInfoView: PaymentInfoView!
    @IBOutlet private var paymentButton: UIButton!
    @IBOutlet private var paymentButtonContainer: UIView!
    @IBOutlet fileprivate var emailErrorLabel: ErrorLabel!
    @IBOutlet private var emailErrorContainer: UIView!
    @IBOutlet private var scrollView: UIScrollView!
    @IBOutlet private var saveInfoButton: UIButton!
    
    fileprivate var paymentValid = false {
        didSet {
            self.paymentButton.isEnabled = self.paymentValid && self.emailValid
            if !self.paymentValid {
                self.scrollView.scrollRectToVisible(self.paymentInfoView.frame, animated: true)
            }
        }
    }
    
    fileprivate var emailValid = false {
        didSet {
            self.emailErrorContainer.isHidden = self.emailValid
            self.paymentButton.isEnabled = self.paymentValid && self.emailValid
            if !self.emailValid {
                self.scrollView.scrollRectToVisible(self.emailErrorContainer.frame, animated: true)
            }
        }
    }
    
    var facility: Facility?
    var rate: Rate?
    
    //MARK: - View Lifecycle
    
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
        self.view.layoutIfNeeded() //Make sure the views are the right size before rendering the shadow
        self.paymentButtonContainer.shp_addShadow()
        self.paymentInfoView.delegate = self
        self.emailTextField.delegate = self
        self.emailTextField.setAttributedPlaceholder(text: LocalizedStrings.EmailAddressPlaceHolder)
        self.emailTextField.keyboardType = .emailAddress
        self.addressLabel.textColor = .shp_tire
        self.saveInfoButton.setTitle(LocalizedStrings.SaveInfo, for: .normal)
        if
            let username = UserDefaultsWrapper.username,
            let lastFour = UserDefaultsWrapper.lastFour,
            let cardType = UserDefaultsWrapper.cardType,
            UserDefaultsWrapper.isInfoSaved {
                self.emailTextField.text = username
                self.emailValid = true
                self.paymentInfoView.lastFour = lastFour
                self.paymentInfoView.cardType = cardType
                self.paymentInfoView.toggleRemoveButton(show: true)
                self.paymentValid = true
        }
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
    
    //MARK: Notification handling
    
    @objc private func applicationWillEnterForeground(_ notification: Notification) {
        if !self.datesValid() {
            self.showDatesInPastAlert {
                [weak self]
                _ in
                self?.navigationController?.popToRootViewController(animated: true)
            }
        }
    }
    
    private func showDatesInPastAlert(handler: ((UIAlertAction) -> Void)? = nil) {
        // Show and alert telling the user to update their times
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
    
    //MARK: Actions
    
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
            self.getStripeToken {
                [weak self]
                token in
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
    
    @IBAction private func doneButtonTapped() {
        self.view.endEditing(true)
    }
    
    @IBAction func saveInfoButtonTapped(_ sender: Any) {
        self.saveInfoButton.isSelected = !self.saveInfoButton.isSelected
    }
    
    //MARK: Helpers
    
    /**
     Gets a stripe token for the user's credit card
     
     - parameter completion: Passes in stripe token if it is able to create it. Otherwise nil is passed in.
     */
    private func getStripeToken(_ completion: @escaping (String?) -> Void) {
        StripeWrapper.getToken(self.paymentInfoView.cardNumber,
                               expirationMonth: self.paymentInfoView.expirationMonth,
                               expirationYear: self.paymentInfoView.expirationYear,
                               cvc: self.paymentInfoView.cvc) {
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
                                             lastFour: self.paymentInfoView.lastFour,
                                             cardType: self.paymentInfoView.cardType)
        }
        
        ReservationAPI.createReservation(facility,
                                         rate: rate,
                                         email: email,
                                         stripeToken: token,
                                         partnerRenterCardToken: partnerRenterCardToken,
                                         saveInfo: self.saveInfoButton.isSelected,
                                         completion: {
                                            [weak self]
                                            _, error in
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
        })
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
}

//MARK: - PaymentInfoView

extension CheckoutViewController: PaymentInfoViewDelegate {
    func didValidateText(paymentInfoView: PaymentInfoView) {
        self.paymentValid = paymentInfoView.isValid
    }
    
    func didTapRemoveButton(paymentInfoView: PaymentInfoView) {
        self.paymentValid = false
        UserDefaultsWrapper.clearUserInfo {
            _ in
        }
    }
}

extension CheckoutViewController: UITextFieldDelegate {
    func textField(_ textField: UITextField,
                   shouldChangeCharactersIn range: NSRange,
                   replacementString string: String) -> Bool {
        if UserDefaultsWrapper.isInfoSaved {
            self.paymentInfoView.removeUserInfo()
        }
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        guard let text = textField.text else {
            //TODO: Show email is empty
            self.emailErrorLabel.text = LocalizedStrings.EmailErrorMessage
            self.emailValid = false
            return
        }
        
        do {
            try Validator.validateEmail(text)
            self.emailValid = true
        } catch {
            self.emailErrorLabel.text = LocalizedStrings.EmailErrorMessage
            self.emailValid = false
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField === self.emailTextField {
            if UserDefaultsWrapper.isInfoSaved {
                self.view.endEditing(true)
            } else {
                self.paymentInfoView.becomeActive()
            }
        }
        return true
    }
}
