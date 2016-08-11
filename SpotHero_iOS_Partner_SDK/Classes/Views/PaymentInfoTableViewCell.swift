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
    
    var cardNumber = ""
    var cardType: CardType = .Unknown {
        didSet {
            self.cardImage.image = self.cardType.image()
        }
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
}

extension PaymentInfoTableViewCell: UITextFieldDelegate {
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        guard let text = (textField.text as? NSString)?.stringByReplacingCharactersInRange(range, withString: string) else {
            return true
        }
        
        do {
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
                        textField.resignFirstResponder()
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
                return false
            } else if textField === self.cvcTextField {
                let cvcLength = self.cardType == .Amex ? 4 : 3
                if text.characters.count > cvcLength {
                    return false
                }
            }
        } catch let error as ValidatorError {
            self.handleValidationError(error)
        } catch {
            assertionFailure("Some other error was thrown")
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
        
        if textField === self.creditCardTextField {
            do {
                self.cardType = Validator.getCardType(text)
            } catch let error as ValidatorError {
                self.handleValidationError(error)
            } catch {
                assertionFailure("Some other error was thrown")
            }
        }
    }
    
    func showExpirationDateAndCVCTextFields(show show: Bool) {
        let width: CGFloat = show ? self.textFieldContainer.frame.width / 3 : 0
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
    
    func handleValidationError(error: ValidatorError) {
        switch error {
        case .FieldBlank(let fieldName):
            // TODO: Show blank field error
            break
        case .FieldInvalid(let fieldName, let message):
            // TODO: Show invalid field error
            break
        }
    }
}
