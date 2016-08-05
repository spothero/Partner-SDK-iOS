//
//  PersonalInfoTableViewCell.swift
//  Pods
//
//  Created by Matthew Reed on 7/27/16.
//
//

import UIKit

protocol PersonalInfoTableViewCellDelegate {
    func didValidateText(error: ValidatorError?)
}

class PersonalInfoTableViewCell: UITableViewCell {
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var textField: UITextField!
    
    var delegate: PersonalInfoTableViewCellDelegate?
    var validationClosure: ((String) throws -> ())?
    var error: ValidatorError? {
        didSet {
            if let
                error = self.error,
                delegate = self.delegate {
                delegate.didValidateText(error)
                self.backgroundColor = .redColor()
            } else if let delegate = self.delegate where oldValue != nil {
                delegate.didValidateText(nil)
                self.backgroundColor = .whiteColor()
            }
        }
    }
    
    static let reuseIdentifier = "personalInfoCell"
    
    override func awakeFromNib() {
        super.awakeFromNib()
        textField.delegate = self
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
}
