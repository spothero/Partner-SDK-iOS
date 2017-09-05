//
//  PaymentInfoTableViewCell.swift
//  Pods
//
//  Created by Matthew Reed on 7/27/16.
//
//

import UIKit

class PaymentInfoTableViewCell: UITableViewCell, ValidatorCell {
    enum ErrorKey: String {
        case
        CreditCard,
        Expiration,
        CVC
    }
    
    @IBOutlet private(set) weak var creditCardView: UIView!
    @IBOutlet private(set) weak var cardImage: UIImageView!
    @IBOutlet private(set) weak var creditCardTextField: UITextField!
    @IBOutlet private(set) weak var creditCardTextFieldWidthConstraint: NSLayoutConstraint!
    @IBOutlet private(set) weak var creditCardContainerView: UIView!
    @IBOutlet private(set) weak var warningLabel: UILabel!
    @IBOutlet private(set) weak var expirationDateTextField: UITextField!
    @IBOutlet private(set) weak var cvcTextField: UITextField!
    @IBOutlet private(set) weak var cvcTextFieldWidthConstraint: NSLayoutConstraint!
    @IBOutlet private(set) weak var textFieldContainer: UIView!
    @IBOutlet private(set) weak var errorLabel: UILabel!
    
    weak var delegate: ValidatorCellDelegate?
    var cardNumber = ""
    var expirationMonth = ""
    var expirationYear = ""
    var cvc = ""
    var cardType: CardType = .unknown {
        didSet {
            self.cardImage.image = self.cardType.image()
        }
    }
    
    var errors = [ErrorKey: ValidatorError]() {
        didSet {
            var valid = true
            for value in self.errors.values {
                valid = false
                self.setErrorState(value)
                break
            }
            
            self.valid = valid
            
            if self.valid {
                self.errorLabel.isHidden = true
                self.creditCardContainerView.backgroundColor = .white
            }
        }
    }
    
    var valid: Bool = false {
        didSet {
            self.delegate?.didValidateText()
        }
    }
    
    static let reuseIdentifier = "paymentInfoCell"

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.creditCardView.layer.borderWidth = 1
        self.creditCardView.layer.borderColor = UIColor.shp_lightGray().cgColor
        self.creditCardView.layer.cornerRadius = HeightsAndLengths.standardCornerRadius
        self.creditCardContainerView.layer.cornerRadius = HeightsAndLengths.standardCornerRadius
        self.warningLabel.text = LocalizedStrings.CreditCardWarning
        self.creditCardTextField.delegate = self
        self.expirationDateTextField.delegate = self
        self.cvcTextField.delegate = self
        
        self.cardImage.accessibilityLabel = AccessibilityStrings.CardImage
        
        self.creditCardTextField.placeholder = LocalizedStrings.CreditCardPlaceHolder
        self.expirationDateTextField.placeholder = LocalizedStrings.ExpirationDatePlaceHolder
        self.cvcTextField.placeholder = LocalizedStrings.CVCPlaceHolder
        
        self.creditCardTextField.accessibilityLabel = LocalizedStrings.CreditCardPlaceHolder
        self.expirationDateTextField.accessibilityLabel = LocalizedStrings.ExpirationDatePlaceHolder
        self.cvcTextField.accessibilityLabel = LocalizedStrings.CVCPlaceHolder
    }
    
    func showExpirationDateAndCVCTextFields(show: Bool) {
        let width: CGFloat = show ? (self.textFieldContainer.frame.width / 3) : 0
        
        if !show {
            self.expirationDateTextField.resignFirstResponder()
            self.cvcTextField.resignFirstResponder()
        }
        
        UIView.animate(withDuration: Constants.ViewAnimationDuration) {
            self.creditCardTextFieldWidthConstraint.isActive = show
            self.creditCardTextField.textAlignment = show ? .center : .left
            self.cvcTextFieldWidthConstraint.constant = width
            self.layoutIfNeeded()
        }
    }
    
    //MARK: Helpers
    
    func lastFourDigits(_ digits: String) -> String {
        let endIndex = digits.endIndex
        return digits.substring(with: digits.index(endIndex, offsetBy: -4)..<endIndex)
    }
    
    func fieldValidChanged() {
        self.delegate?.didValidateText()
    }
    
    func formatCreditCard(_ text: String) {
        if text.isEmpty {
            self.cardType = .unknown
        }
        
        let cardLength = self.cardType == .amex ? 15 : 16
        
        switch self.cardType {
        case .amex:
            let (formatted, unformatted) = Formatter.formatCreditCardAmex(text)
            
            if unformatted.characters.count <= cardLength {
                self.creditCardTextField.text = formatted
            }
            
            self.cardNumber = unformatted
            
            if unformatted.characters.count == cardLength {
                self.creditCardTextField.resignFirstResponder()
            }
        default:
            let (formatted, unformatted) = Formatter.formatCreditCard(text)
            
            if unformatted.characters.count <= cardLength {
                self.creditCardTextField.text = formatted
            }
            
            self.cardNumber = unformatted
            
            if unformatted.characters.count == cardLength {
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
        if unformatted.characters.count <= 4 {
            self.expirationDateTextField.text = formatted
        }
        
        if unformatted.characters.count == 4 {
            self.cvcTextField.becomeFirstResponder()
        }
    }
    
    func formatCVC(_ text: String) -> Bool {
        let cvcLength = self.cardType == .amex ? 4 : 3
        if text.characters.count > cvcLength {
            return false
        }
        
        if text.characters.count == cvcLength {
            self.cvcTextField.text = text
            self.cvcTextField.resignFirstResponder()
        }
        
        return true
    }
}

// MARK: - UITextFieldDelegate

extension PaymentInfoTableViewCell: UITextFieldDelegate {
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
                self.errors[.CreditCard] = nil
                self.showExpirationDateAndCVCTextFields(show: true)
                self.expirationDateTextField.becomeFirstResponder()
                self.creditCardTextField.text = self.lastFourDigits(text)
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
                self.errors[.Expiration] = nil
            case self.cvcTextField:
                if cardType == .amex {
                    try Validator.validateCVC(text, amex: true)
                } else {
                    try Validator.validateCVC(text)
                }
                self.cvc = text
                self.errors[.CVC] = nil
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
            self.errors[.CreditCard] = error
        case self.expirationDateTextField:
            self.errors[.Expiration] = error
        case self.cvcTextField:
            self.errors[.CVC] = error
        default:
            break
        }
    }
    
    fileprivate func setErrorState(_ error: ValidatorError) {
        self.errorLabel.isHidden = false
        
        self.creditCardContainerView.backgroundColor = .shp_errorRed()
        
        switch error {
        case .fieldBlank(let fieldName):
            self.errorLabel.text = String(format: LocalizedStrings.blankFieldErrorFormat, fieldName)
        case .fieldInvalid(_, let message):
            self.errorLabel.text = message
        }
    }
}
