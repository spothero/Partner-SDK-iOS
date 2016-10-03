//
//  PaymentInfoTableViewCell.swift
//  Pods
//
//  Created by Matthew Reed on 7/27/16.
//
//

import UIKit

class PaymentInfoTableViewCell: UITableViewCell {
    @IBOutlet weak var creditCardView: UIView!
    @IBOutlet weak var cardImage: UIImageView!
    @IBOutlet weak var creditCardTextField: UITextField!
    @IBOutlet weak var creditCardTextFieldWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var creditCardContainerView: UIView!
    @IBOutlet weak var warningLabel: UILabel!
    @IBOutlet weak var expirationDateTextField: UITextField!
    @IBOutlet weak var cvcTextField: UITextField!
    @IBOutlet weak var cvcTextFieldWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var textFieldContainer: UIView!
    @IBOutlet weak var errorLabel: UILabel!
    
    weak var delegate: ValidatorCellDelegate?
    var cardNumber = ""
    var expirationMonth = ""
    var expirationYear = ""
    var cvc = ""
    var cardType: CardType = .Unknown {
        didSet {
            self.cardImage.image = self.cardType.image()
        }
    }
    
    var creditCardValid = true {
        didSet {
            self.fieldValidChanged()
        }
    }
    
    var expirationDateValid = true {
        didSet {
            self.fieldValidChanged()
        }
    }
    
    var cvcValid = true {
        didSet {
            self.fieldValidChanged()
        }
    }
    
    var valid: Bool {
        return creditCardValid && expirationDateValid && cvcValid
    }
    
    static let reuseIdentifier = "paymentInfoCell"

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.creditCardView.layer.borderWidth = 1
        self.creditCardView.layer.borderColor = UIColor.shp_lightGray().CGColor
        self.creditCardView.layer.cornerRadius = HeightsAndLengths.standardCornerRadius
        self.creditCardContainerView.layer.cornerRadius = HeightsAndLengths.standardCornerRadius
        self.warningLabel.text = LocalizedStrings.CreditCardWarning
        self.creditCardTextField.delegate = self
        self.expirationDateTextField.delegate = self
        self.cvcTextField.delegate = self
    }
    
    func showExpirationDateAndCVCTextFields(show show: Bool) {
        let width: CGFloat = show ? (self.textFieldContainer.frame.width / 3) : 0
        
        if !show {
            self.expirationDateTextField.resignFirstResponder()
            self.cvcTextField.resignFirstResponder()
        }
        
        UIView.animateWithDuration(Constants.ViewAnimationDuration) {
            self.creditCardTextFieldWidthConstraint.active = show
            self.creditCardTextField.textAlignment = show ? .Center : .Left
            self.cvcTextFieldWidthConstraint.constant = width
            self.layoutIfNeeded()
        }
    }
    
    //MARK: Helpers
    
    func lastFourDigits(digits: String) -> String {
        let endIndex = digits.endIndex
        return digits.substringWithRange(endIndex.advancedBy(-4)..<endIndex)
    }
    
    func fieldValidChanged() {
        self.delegate?.didValidateText()
    }
    
    func formatCreditCard(text: String) -> Bool {
        if text.isEmpty {
            self.cardType = .Unknown
        }
        
        let cardLength = self.cardType == .Amex ? 15 : 16
        
        switch self.cardType {
        case .Amex:
            let (formatted, unformatted) = Formatter.formatCreditCardAmex(text)
            
            if unformatted.characters.count <= cardLength {
                self.creditCardTextField.text = formatted
            } else {
                return false
            }
            
            self.cardNumber = unformatted
            
            if unformatted.characters.count == cardLength {
                self.creditCardTextField.resignFirstResponder()
            }
        default:
            let (formatted, unformatted) = Formatter.formatCreditCard(text)
            
            if unformatted.characters.count <= cardLength {
                self.creditCardTextField.text = formatted
            } else {
                return false
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
        
        return false
    }
    
    func formatExpirationDate(text: String) -> Bool {
        let (formatted, unformatted) = Formatter.formatExpirationDate(text)
        if unformatted.characters.count <= 4 {
            self.expirationDateTextField.text = formatted
        }
        
        if unformatted.characters.count == 4 {
            self.cvcTextField.becomeFirstResponder()
        }
        
        return false
    }
    
    func formatCVC(text: String) -> Bool {
        let cvcLength = self.cardType == .Amex ? 4 : 3
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
    func textField(textField: UITextField,
                   shouldChangeCharactersInRange range: NSRange,
                   replacementString string: String) -> Bool {
        guard let text = (textField.text as? NSString)?.stringByReplacingCharactersInRange(range, withString: string) else {
            return true
        }
        
        switch textField {
        case self.creditCardTextField:
            return self.formatCreditCard(text)
        case self.expirationDateTextField:
            return self.formatExpirationDate(text)
        case self.cvcTextField:
            return self.formatCVC(text)
        default:
            return true
        }
    }
    
    func textFieldDidBeginEditing(textField: UITextField) {
        guard textField === self.creditCardTextField && !self.cardNumber.isEmpty else {
            return
        }
        
        switch self.cardType {
        case .Amex:
            textField.text = Formatter.formatCreditCardAmex(self.cardNumber).formatted
        default:
            textField.text = Formatter.formatCreditCard(self.cardNumber).formatted
        }
        self.showExpirationDateAndCVCTextFields(show: false)
    }
    
    func textFieldDidEndEditing(textField: UITextField) {
        guard let text = textField.text else {
            return
        }
        
        do {
            switch textField {
            case self.creditCardTextField:
                self.cardType = Validator.getCardType(text)
                try Validator.validateCreditCard(self.cardNumber)
                self.creditCardValid = true
                self.showExpirationDateAndCVCTextFields(show: true)
                self.expirationDateTextField.becomeFirstResponder()
                self.creditCardTextField.text = self.lastFourDigits(text)
            case self.expirationDateTextField:
                let parts = text.componentsSeparatedByString("/")
                if let month = parts.first, year = parts.last {
                    self.expirationMonth = month
                    self.expirationYear = "20\(year)"
                    try Validator.validateExpiration(self.expirationMonth, year: self.expirationYear)
                } else {
                    throw ValidatorError.FieldInvalid(fieldName: LocalizedStrings.ExpirationDate, message: LocalizedStrings.InvalidDateErrorMessage)
                }
                self.expirationDateValid = true
            case self.cvcTextField:
                if cardType == .Amex {
                    try Validator.validateCVC(text, amex: true)
                } else {
                    try Validator.validateCVC(text)
                }
                self.cvcValid = true
                self.cvc = text
            default:
                break
            }

            self.setErrorState(self.valid, error: nil)
        } catch let error as ValidatorError {
            switch textField {
            case self.creditCardTextField:
                self.creditCardValid = false
            case self.expirationDateTextField:
                self.expirationDateValid = false
            case self.cvcTextField:
                self.cvcValid = false
            default:
                break
            }
            self.setErrorState(self.valid, error:error)
        } catch let error {
            assertionFailure("Some other error was thrown: \(error)")
        }
    }
}

// MARK: - ValidatorCell

extension PaymentInfoTableViewCell: ValidatorCell {
    func setErrorState(valid: Bool, error: ValidatorError?) {
        self.errorLabel.hidden = valid
        
        self.creditCardContainerView.backgroundColor = valid ? .whiteColor() : .shp_errorRed()
        
        if let error = error {
            switch error {
            case .FieldBlank(let fieldName):
                self.errorLabel.text = String(format: LocalizedStrings.blankFieldErrorFormat, fieldName)
            case .FieldInvalid(let fieldName, let message):
                self.errorLabel.text = message
            }
        }
    }
}
