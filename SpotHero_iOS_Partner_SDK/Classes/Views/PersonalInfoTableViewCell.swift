//
//  PersonalInfoTableViewCell.swift
//  Pods
//
//  Created by Matthew Reed on 7/27/16.
//
//

import UIKit

protocol PersonalInfoTableViewCellDelegate: class {
    func textFieldShouldReturn(_ type: PersonalInfoRow)
}

class PersonalInfoTableViewCell: UITableViewCell, ValidatorCell {
    @IBOutlet private(set) weak var titleLabel: UILabel!
    @IBOutlet private(set) weak var textField: UITextField!
    @IBOutlet private(set) weak var errorLabel: UILabel!
    
    var type: PersonalInfoRow = .email
    
    weak var delegate: ValidatorCellDelegate?
    weak var personalInfoCellDelegate: PersonalInfoTableViewCellDelegate?
    var validationClosure: ((String) throws -> Void)?
    var valid = false {
        didSet {
            self.backgroundColor = self.valid ? .white : .shp_errorRed()
            self.errorLabel.isHidden = self.valid
            delegate?.didValidateText()
        }
    }
    
    static let reuseIdentifier = "personalInfoCell"
    
    override func awakeFromNib() {
        super.awakeFromNib()
        textField.delegate = self
    }
}

extension PersonalInfoTableViewCell: UITextFieldDelegate {
    func textFieldDidEndEditing(_ textField: UITextField) {
        guard let text = textField.text else {
            return
        }
        
        do {
            if let validationClosure = self.validationClosure {
                try validationClosure(text)
            } else {
                assertionFailure("Validation closure not set")
            }
            self.setErrorState(nil)
        } catch let error as ValidatorError {
            self.setErrorState(error)
        } catch {
            assertionFailure("Some other error was thrown")
        }
    }
    
    func textField(_ textField: UITextField,
                   shouldChangeCharactersIn range: NSRange,
                   replacementString string: String) -> Bool {
        guard let text = textField.text else {
            return true
        }
        
        let subString = (text as NSString).replacingCharacters(in: range, with: string)
        
        if self.type == .phone {
            let cursorLocation = textField.shp_getCursorPosition(range, string: string)
            let (formatted, unformatted) = Formatter.formatPhoneNumber(subString)
            textField.text = formatted
            textField.shp_setCursorPosition(cursorLocation)
            
            if unformatted.characters.count == 10 {
                textField.resignFirstResponder()
                self.personalInfoCellDelegate?.textFieldShouldReturn(self.type)
            }
            
            return false
        }
        
        return true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        self.personalInfoCellDelegate?.textFieldShouldReturn(self.type)
        return false
    }
    
    func setErrorState(_ error: ValidatorError?) {
        if let error = error {
            switch error {
            case .fieldBlank(let fieldName):
                self.errorLabel.text = String(format: LocalizedStrings.blankFieldErrorFormat, fieldName)
            case .fieldInvalid(_, let message):
                self.errorLabel.text = message
            }
        }
        
        self.valid = (error == nil)
    }
}
