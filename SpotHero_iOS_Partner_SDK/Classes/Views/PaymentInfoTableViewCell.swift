//
//  PaymentInfoTableViewCell.swift
//  Pods
//
//  Created by Matthew Reed on 7/27/16.
//
//

import UIKit

class PaymentInfoTableViewCell: UITableViewCell, ValidatorCell {
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
    
    var delegate: ValidatorCellDelegate?
    var cardNumber = ""
    var cardType: CardType = .Unknown {
        didSet {
            self.cardImage.image = self.cardType.image()
        }
    }
    
    var creditCardValid: Bool? {
        didSet {
            self.fieldValidChanged()
        }
    }
    
    var expirationDateValid: Bool? {
        didSet {
            self.fieldValidChanged()
        }
    }
    
    var cvcValid: Bool? {
        didSet {
            self.fieldValidChanged()
        }
    }
    
    var valid: Bool {
        if let creditCardValid = self.creditCardValid, expirationDateValid = self.expirationDateValid, cvcValid = self.cvcValid {
            return creditCardValid && expirationDateValid && cvcValid
        }
        return false
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
    
    func lastFourDigits(digits: String) -> String {
        let endIndex = digits.endIndex
        return digits.substringWithRange(endIndex.advancedBy(-4)..<endIndex)
    }
    
    func setErrorState(valid: Bool, error: ValidatorError?) {
        guard self.creditCardValid != nil && self.expirationDateValid != nil && self.cvcValid != nil else {
            return
        }
        
        self.errorLabel.hidden = valid
        
        if let error = error {
            switch error {
            case .FieldBlank(let fieldName):
                self.errorLabel.text = String(format: LocalizedStrings.blankFieldErrorFormat, fieldName)
            case .FieldInvalid(let fieldName, let message):
                self.errorLabel.text = message
            }
        }
    }
    
    func fieldValidChanged() {
        self.delegate?.didValidateText()
    }
}

extension PaymentInfoTableViewCell: UITextFieldDelegate {
    func textField(textField: UITextField,
                   shouldChangeCharactersInRange range: NSRange,
                   replacementString string: String) -> Bool {
        guard let text = (textField.text as? NSString)?.stringByReplacingCharactersInRange(range, withString: string) else {
            return true
        }
        
        if textField === self.creditCardTextField {
            if text.isEmpty {
                self.cardType = .Unknown
            }
            
            let cardLength = self.cardType == .Amex ? 15 : 16
            
            switch self.cardType {
            case .Amex:
                let (formatted, unformatted) = Formatter.formatCreditCardAmex(text)
                
                if unformatted.characters.count <= cardLength {
                    textField.text = formatted
                } else {
                    return false
                }
                
                self.cardNumber = unformatted

                if unformatted.characters.count == cardLength {
                    self.showExpirationDateAndCVCTextFields(show: true)
                    textField.text = self.lastFourDigits(text)
                    textField.resignFirstResponder()
                    self.expirationDateTextField.becomeFirstResponder()
                }
            default:
                let (formatted, unformatted) = Formatter.formatCreditCard(text)
                
                if unformatted.characters.count <= cardLength {
                    textField.text = formatted
                } else {
                    return false
                }
                
                self.cardNumber = unformatted
                
                if unformatted.characters.count == cardLength {
                    self.showExpirationDateAndCVCTextFields(show: true)
                    textField.text = self.lastFourDigits(unformatted)
                    self.expirationDateTextField.becomeFirstResponder()
                }
            }
            
            if self.cardNumber.isEmpty {
                self.cardType = Validator.getCardType(text)
            } else {
                self.cardType = Validator.getCardType(self.cardNumber)
            }
            
            return false
        } else if textField === self.expirationDateTextField {
            let (formatted, unformatted) = Formatter.formatExpirationDate(text)
            if unformatted.characters.count <= 4 {
                textField.text = formatted
            }
            if unformatted.characters.count == 4 {
                self.cvcTextField.becomeFirstResponder()
            }
            return false
        } else if textField === self.cvcTextField {
            let cvcLength = self.cardType == .Amex ? 4 : 3
            if text.characters.count > cvcLength {
                return false
            }
            
            if text.characters.count == cvcLength {
                textField.text = text
                textField.resignFirstResponder()
            }
        }
        
        return true
    }
    
    func textFieldDidBeginEditing(textField: UITextField) {
        if textField === self.creditCardTextField && !self.cardNumber.isEmpty {
            switch self.cardType {
            case .Amex:
                textField.text = Formatter.formatCreditCardAmex(self.cardNumber).formatted
            default:
                textField.text = Formatter.formatCreditCard(self.cardNumber).formatted
            }
            self.showExpirationDateAndCVCTextFields(show: false)
        }
    }
    
    func textFieldDidEndEditing(textField: UITextField) {
        guard let text = textField.text else {
            return
        }
        
        do {
            if textField === self.creditCardTextField {
                self.cardType = Validator.getCardType(text)
                try Validator.validateCreditCard(self.cardNumber)
                self.creditCardValid = true
            } else if textField === self.expirationDateTextField {
                let parts = text.componentsSeparatedByString("/")
                if let month = parts.first, year = parts.last {
                    try Validator.validateExpiration(month, year: "20\(year)")
                } else {
                    throw ValidatorError.FieldInvalid(fieldName: LocalizedStrings.ExpirationDate, message: LocalizedStrings.InvalidDateErrorMessage)
                }
                self.expirationDateValid = true
            } else if textField === self.cvcTextField {
                if cardType == .Amex {
                    try Validator.validateCVC(text, amex: true)
                } else {
                    try Validator.validateCVC(text)
                }
                self.cvcValid = true
            }
            self.setErrorState(true, error: nil)
        } catch let error as ValidatorError {
            self.setErrorState(false, error: error)
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
        } catch {
            assertionFailure("Some other error was thrown")
        }
    }
}
