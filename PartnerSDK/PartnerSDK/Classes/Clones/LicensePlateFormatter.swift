//
//  LicensePlateFormatter.swift
//  SpotHero
//
//  Created by Ellen Shapiro (Work) on 8/14/16.
//
//

import UIKit

class LicensePlateFormatter {
    
    //California allows stars and hearts in vanity plates, because California.
    //We should update this to accomodate. https://spothero.atlassian.net/browse/IA-324
    static let ValidLicensePlateCharacters = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz1234567890 "
    static let MaxPlateCharacters = 18
    
    private static func hasInvalidPlateCharacters(_ plateString: String) -> Bool {
        let invalidPlateCharacters = CharacterSet(charactersIn: self.ValidLicensePlateCharacters).inverted
        
        return plateString.rangeOfCharacter(from: invalidPlateCharacters) != nil
    }
    
    /**
     Wrapper for UITextFieldDelegate method specifically for formatting license plates
     
     - parameter textField: The text field where a plate is being entered.
     - parameter range:     The replacement range handed back from the UITextFieldDelegate.
     - parameter string:    The replacement string handed back from the UITextFieldDelegate.`
     
     - returns: true, when the text is being modified, false when escaped with a return
     .
     */
    static func format(plateTextField textField: UITextField,
                       forRange range: NSRange,
                       replacementString string: String) -> Bool {
        guard string != "\n" else {
            //hitting the return key is allowed
            return false
        }
        
        let updatedLength = (textField.text?.count ?? 0) + string.count - range.length
        guard updatedLength <= self.MaxPlateCharacters else {
            return true
        }
        
        guard !self.hasInvalidPlateCharacters(string) else {
            return true
        }
        
        let beginning = textField.beginningOfDocument
        guard let
            start = textField.position(from: beginning, offset: range.location),
            let end = textField.position(from: start, offset: range.length),
            let textRange = textField.textRange(from: start, to: end) else {
                assertionFailure("Could not get range of string to replace!")
                return true
        }
        
        textField.replace(textRange, withText: string.uppercased())
        
        return true
    }
}
