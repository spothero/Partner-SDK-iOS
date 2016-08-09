//
//  PersonalInfoTableViewCell.swift
//  Pods
//
//  Created by Matthew Reed on 7/27/16.
//
//

import UIKit

protocol PersonalInfoTableViewCellDelegate {
    func didValidateText()
}

class PersonalInfoTableViewCell: UITableViewCell {
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var errorLabel: UILabel!
    
    var type: PersonalInfoRow = .FullName
    
    var delegate: PersonalInfoTableViewCellDelegate?
    var validationClosure: ((String) throws -> ())?
    var error: ValidatorError? {
        didSet {
            self.setErrorState(oldValue)
            self.valid = (error == nil)
        }
    }
    var valid = false {
        didSet {
            delegate?.didValidateText()
        }
    }
    
    static let reuseIdentifier = "personalInfoCell"
    
    override func awakeFromNib() {
        super.awakeFromNib()
        textField.delegate = self
    }
    
    private func setErrorState(oldValue: ValidatorError?) {
        if let error = self.error {
            self.backgroundColor = .shp_errorRed()
            self.errorLabel.hidden = false
            switch error {
            case .FieldBlank(let fieldName):
                self.errorLabel.text = String(format: LocalizedStrings.blankFieldErrorFormat, fieldName)
            case .FieldInvalid(let fieldName, let message):
                self.errorLabel.text = message
            }
        } else {
            self.errorLabel.hidden = true
            self.backgroundColor = .whiteColor()
        }
    }
}

extension PersonalInfoTableViewCell: UITextFieldDelegate {
    func textFieldDidEndEditing(textField: UITextField) {
        guard let text = textField.text else {
            return
        }
        
        do {
            if let validationClosure = self.validationClosure {
                try validationClosure(text)
            } else {
                assertionFailure("Validation closure not set")
            }
            self.error = nil
        } catch let error as ValidatorError {
            self.error = error
        } catch {
            assertionFailure("Some other error was thrown")
        }
    }
    
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        guard let text = (textField.text as? NSString)?.stringByReplacingCharactersInRange(range, withString: string) else {
            return true
        }
        
        if self.type == .Phone {
            let formatted = Formatter.formatPhoneNumber(text)
            textField.text = formatted
            return false
        }
        
        return true
    }
}
