//
//  PaymentInfoView.swift
//  Pods
//
//  Created by Matthew Reed on 7/27/16.
//
//

import UIKit

protocol PaymentInfoViewDelegate: class {
    func didValidateText(paymentInfoView: PaymentInfoView)
    func didTapRemoveButton(paymentInfoView: PaymentInfoView)
}

class PaymentInfoView: UIView {
    enum ErrorKey: String {
        case
        creditCard,
        expiration,
        cvc
    }
    
    @IBOutlet private var cardImage: UIImageView!
    @IBOutlet fileprivate var creditCardTextField: SHPTextField!
    @IBOutlet private var warningLabel: UILabel!
    @IBOutlet fileprivate var expirationDateTextField: SHPTextField!
    @IBOutlet fileprivate var cvcTextField: SHPTextField!
    @IBOutlet fileprivate var errorLabel: UILabel!
    @IBOutlet fileprivate var errorContainerView: UIView!
    @IBOutlet private var removeButton: UIButton!
    
    weak var delegate: PaymentInfoViewDelegate?
    var cardNumber = ""
    var expirationMonth = ""
    var expirationYear = ""
    var cvc = ""
    var lastFour = "" {
        didSet {
            if !self.lastFour.isEmpty {
                self.creditCardTextField.text = self.lastFour
            }
        }
    }
    var cardType: CardType = .unknown {
        didSet {
            self.cardImage.image = self.cardType.image()
        }
    }
    
    var errors = [ErrorKey: ValidatorError]() {
        didSet {
            var isValid = true
            for value in self.errors.values {
                isValid = false
                self.setErrorState(value)
                break
            }
            
            self.isValid = isValid
            
            if self.isValid {
                self.errorContainerView.isHidden = true
            }
        }
    }
    
    var isValid: Bool = false {
        didSet {
            self.delegate?.didValidateText(paymentInfoView: self)
        }
    }
    
    static let reuseIdentifier = "paymentInfoCell"

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.warningLabel.text = LocalizedStrings.CreditCardWarning
        self.creditCardTextField.delegate = self
        self.expirationDateTextField.delegate = self
        self.cvcTextField.delegate = self
        
        self.cardImage.accessibilityLabel = AccessibilityStrings.CardImage
        
        self.creditCardTextField.setAttributedPlaceholder(text: LocalizedStrings.CreditCardPlaceHolder)
        self.expirationDateTextField.setAttributedPlaceholder(text: LocalizedStrings.ExpirationDatePlaceHolder)
        self.cvcTextField.setAttributedPlaceholder(text: LocalizedStrings.CVCPlaceHolder)
        
        self.creditCardTextField.accessibilityLabel = LocalizedStrings.CreditCardPlaceHolder
        self.expirationDateTextField.accessibilityLabel = LocalizedStrings.ExpirationDatePlaceHolder
        self.cvcTextField.accessibilityLabel = LocalizedStrings.CVCPlaceHolder
        
        let toolBar = UIToolbar()
        toolBar.autoresizingMask = .flexibleHeight
        let doneButton = UIBarButtonItem(title: LocalizedStrings.Done,
                                         style: .plain,
                                         target: self,
                                         action: #selector(self.doneButtonTapped))
        toolBar.items = [UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil), doneButton]
        self.creditCardTextField.inputAccessoryView = toolBar
        self.expirationDateTextField.inputAccessoryView = toolBar
        self.cvcTextField.inputAccessoryView = toolBar
        self.removeButton.setTitle(LocalizedStrings.Remove, for: .normal)
    }
    
    func showExpirationDateAndCVCTextFields(show: Bool) {
        if !show {
            self.expirationDateTextField.resignFirstResponder()
            self.cvcTextField.resignFirstResponder()
        }
        
        self.cvcTextField.isHidden = !show
        self.expirationDateTextField.isHidden = !show
    }
    
    func toggleRemoveButton(show: Bool) {
        self.creditCardTextField.isEnabled = !show
        self.removeButton.isHidden = !show
        if show {
            self.creditCardTextField.text = "\(self.cardType.localizedName)* \(self.lastFour)"
        }
    }
    
    func removeUserInfo() {
        self.toggleRemoveButton(show: false)
        self.creditCardTextField.text = nil
        self.cardType = .unknown
        self.delegate?.didTapRemoveButton(paymentInfoView: self)
    }
    
    @IBAction private func doneButtonTapped() {
        self.endEditing(true)
    }
    
    @IBAction private func removeButtonTapped(_ sender: Any) {
        self.removeUserInfo()
    }
    
    //MARK: Helpers
    
    func becomeActive() {
        self.creditCardTextField.becomeFirstResponder()
    }
    
    func lastFourDigits(_ digits: String) -> String {
        let endIndex = digits.endIndex
        return String(digits[digits.index(endIndex, offsetBy: -4)..<endIndex])
    }
    
    func fieldValidChanged() {
        self.delegate?.didValidateText(paymentInfoView: self)
    }
    
    func formatCreditCard(_ text: String) {
        if text.isEmpty {
            self.cardType = .unknown
        }
        
        let cardLength = self.cardType == .amex ? 15 : 16
        
        switch self.cardType {
        case .amex:
            let (formatted, unformatted) = Formatter.formatCreditCardAmex(text)
            
            if unformatted.count <= cardLength {
                self.creditCardTextField.text = formatted
            }
            
            self.cardNumber = unformatted
            
            if unformatted.count == cardLength {
                self.creditCardTextField.resignFirstResponder()
            }
        default:
            let (formatted, unformatted) = Formatter.formatCreditCard(text)
            
            if unformatted.count <= cardLength {
                self.creditCardTextField.text = formatted
            }
            
            self.cardNumber = unformatted
            
            if unformatted.count == cardLength {
                self.creditCardTextField.resignFirstResponder()
            }
        }
        
        if self.cardNumber.isEmpty {
            self.cardType = Validator.getCardType(text)
        } else {
            self.cardType = Validator.getCardType(self.cardNumber)
        }
    }
    
    func formatExpirationDate(_ text: String) {
        let (formatted, unformatted) = Formatter.formatExpirationDate(text)
        if unformatted.count <= 4 {
            self.expirationDateTextField.text = formatted
        }
        
        if unformatted.count == 4 {
            self.cvcTextField.becomeFirstResponder()
        }
    }
    
    func formatCVC(_ text: String) -> Bool {
        let cvcLength = self.cardType == .amex ? 4 : 3
        if text.count > cvcLength {
            return false
        }
        
        if text.count == cvcLength {
            self.cvcTextField.text = text
            self.cvcTextField.resignFirstResponder()
        }
        
        return true
    }
}

// MARK: - UITextFieldDelegate

extension PaymentInfoView: UITextFieldDelegate {
    func textField(_ textField: UITextField,
                   shouldChangeCharactersIn range: NSRange,
                   replacementString string: String) -> Bool {
        guard let text = textField.text else {
            return true
        }
        
        let subString = (text as NSString).replacingCharacters(in: range, with: string)
        
        let cursorLocation = textField.shp_getCursorPosition(range, string: string)
        
        switch textField {
        case self.creditCardTextField:
            if string.isEmpty // If replacement string is is blank
                && (text as NSString).substring(with: range) == " " // If deleted string is a space
                && range.location > 2 { // make sure there are at least 3 charaters in the text field
                let rangeBefore = NSRange(location: range.location - 1, length: 1)
                let newText = (subString as NSString).replacingCharacters(in: rangeBefore, with: "")
                self.creditCardTextField.text = newText
            } else {
                self.formatCreditCard(subString)
            }
            textField.shp_setCursorPosition(cursorLocation)
            return false
        case self.expirationDateTextField:
            self.formatExpirationDate(subString)
            textField.shp_setCursorPosition(cursorLocation)
            return false
        case self.cvcTextField:
            return self.formatCVC(subString)
        default:
            return true
        }
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        guard textField === self.creditCardTextField && !self.cardNumber.isEmpty else {
            return
        }
        
        switch self.cardType {
        case .amex:
            textField.text = Formatter.formatCreditCardAmex(self.cardNumber).formatted
        default:
            textField.text = Formatter.formatCreditCard(self.cardNumber).formatted
        }
        self.showExpirationDateAndCVCTextFields(show: false)
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        guard let text = textField.text else {
            return
        }
        
        do {
            switch textField {
            case self.creditCardTextField:
                self.cardType = Validator.getCardType(text)
                try Validator.validateCreditCard(self.cardNumber)
                self.errors[.creditCard] = nil
                self.showExpirationDateAndCVCTextFields(show: true)
                self.expirationDateTextField.becomeFirstResponder()
                self.lastFour = self.lastFourDigits(text)
            case self.expirationDateTextField:
                let parts = text.components(separatedBy: "/")
                if
                    let month = parts.first,
                    let year = parts.last {
                        self.expirationMonth = month
                        self.expirationYear = "20\(year)"
                        try Validator.validateExpiration(self.expirationMonth, year: self.expirationYear)
                } else {
                    throw ValidatorError.fieldInvalid(fieldName: LocalizedStrings.ExpirationDate, message: LocalizedStrings.InvalidDateErrorMessage)
                }
                self.errors[.expiration] = nil
            case self.cvcTextField:
                if cardType == .amex {
                    try Validator.validateCVC(text, amex: true)
                } else {
                    try Validator.validateCVC(text)
                }
                self.cvc = text
                self.errors[.cvc] = nil
            default:
                break
            }
        } catch let error as ValidatorError {
            self.handleValidatorError(error, in: textField)
        } catch let error {
            assertionFailure("Some other error was thrown: \(error)")
        }
    }
    
    private func handleValidatorError(_ error: ValidatorError, in textField: UITextField) {
        switch textField {
        case self.creditCardTextField:
            self.errors[.creditCard] = error
        case self.expirationDateTextField:
            self.errors[.expiration] = error
        case self.cvcTextField:
            self.errors[.cvc] = error
        default:
            break
        }
    }
    
    fileprivate func setErrorState(_ error: ValidatorError) {
        self.errorContainerView.isHidden = false
        
        switch error {
        case .fieldBlank(let fieldName):
            self.errorLabel.text = String(format: LocalizedStrings.BlankFieldErrorFormat, fieldName)
        case .fieldInvalid(_, let message):
            self.errorLabel.text = message
        }
    }
}
