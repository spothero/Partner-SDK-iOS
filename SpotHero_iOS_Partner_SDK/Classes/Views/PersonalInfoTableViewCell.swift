//
//  PersonalInfoTableViewCell.swift
//  Pods
//
//  Created by Matthew Reed on 7/27/16.
//
//

import UIKit

class PersonalInfoTableViewCell: UITableViewCell {
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var textField: UITextField!
    
    static let reuseIdentifier = "personalInfoCell"
    
    func configureCell(row: PersonalInfoRow) {
        self.titleLabel.text = row.title()
        self.textField.placeholder = row.placeholder()
        
        switch row {
        case PersonalInfoRow.FullName:
            self.textField.autocapitalizationType = .Words
        case PersonalInfoRow.Email:
            self.textField.autocapitalizationType = .None
            self.textField.keyboardType = .EmailAddress
        case PersonalInfoRow.Phone:
            self.textField.keyboardType = .PhonePad
        }
    }
}
