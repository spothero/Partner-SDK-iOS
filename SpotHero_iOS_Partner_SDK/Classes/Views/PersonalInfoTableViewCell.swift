//
//  PersonalInfoTableViewCell.swift
//  Pods
//
//  Created by Matthew Reed on 7/27/16.
//
//

import UIKit

class PersonalInfoTableViewCell: UITableViewCell, ValidatorCell {
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var errorLabel: UILabel!
    
    var type: PersonalInfoRow = .FullName
    
    var delegate: ValidatorCellDelegate?
    var validationClosure: ((String) throws -> ())?
    var valid = false {
        didSet {
            self.backgroundColor = self.valid ? .whiteColor() : .shp_errorRed()
            self.errorLabel.hidden = self.valid
            delegate?.didValidateText()
        }
    }
    
    static let reuseIdentifier = "personalInfoCell"
    
    override func awakeFromNib() {
        super.awakeFromNib()
        textField.delegate = self
    }
    
    func setErrorState(valid: Bool, error: ValidatorError?) {
        if let error = error {
            switch error {
            case .FieldBlank(let fieldName):
                self.errorLabel.text = String(format: LocalizedStrings.blankFieldErrorFormat, fieldName)
            case .FieldInvalid(let fieldName, let message):
                self.errorLabel.text = message
            }
        }
        
        self.valid = valid
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
            self.setErrorState(true, error: nil)
        } catch let error as ValidatorError {
            self.setErrorState(false, error: error)
        } catch {
            assertionFailure("Some other error was thrown")
        }
    }
    
    func textField(textField: UITextField,
                   shouldChangeCharactersInRange range: NSRange,
                   replacementString string: String) -> Bool {
        guard let text = (textField.text as? NSString)?.stringByReplacingCharactersInRange(range, withString: string) else {
            return true
        }
        
        if self.type == .Phone {
            let (formatted, unformatted) = Formatter.formatPhoneNumber(text)
            textField.text = formatted
            
            if unformatted.characters.count == 10 {
                textField.resignFirstResponder()
            }
            
            return false
        }
        
        return true
    }
}
