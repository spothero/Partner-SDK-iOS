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
            delegate?.didValidateText()
        }
    }
    
    static let reuseIdentifier = "personalInfoCell"
    
    override func awakeFromNib() {
        super.awakeFromNib()
        textField.delegate = self
    }
    
    func setErrorState(error: ValidatorError) {
        self.backgroundColor = .shp_errorRed()
        self.errorLabel.hidden = false
        switch error {
        case .FieldBlank(let fieldName):
            self.errorLabel.text = String(format: LocalizedStrings.blankFieldErrorFormat, fieldName)
        case .FieldInvalid(let fieldName, let message):
            self.errorLabel.text = message
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
            self.valid = true
        } catch let error as ValidatorError {
            self.setErrorState(error)
            self.valid = false
        } catch {
            assertionFailure("Some other error was thrown")
        }
    }
    
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        guard let text = (textField.text as? NSString)?.stringByReplacingCharactersInRange(range, withString: string) else {
            return true
        }
        
        if self.type == .Phone {
            let formatted = Formatter.formatPhoneNumber(text).formatted
            textField.text = formatted
            return false
        }
        
        return true
    }
}
