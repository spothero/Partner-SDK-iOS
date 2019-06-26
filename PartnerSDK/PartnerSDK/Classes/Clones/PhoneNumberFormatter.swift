// swiftlint:disable joined_default_parameter
//  PhoneNumberFormatter.swift
//  SpotHero
//
//  Created by Esteban Brenes on 9/6/16.
//
//

import Foundation

class PhoneNumberFormatter {
    
    private static func hasInvalidPhoneCharacters(_ phoneString: String) -> Bool {
        let invalidPhoneCharacters = CharacterSet.decimalDigits.inverted
        return phoneString.rangeOfCharacter(from: invalidPhoneCharacters) != nil
    }
    
    /**
     Wrapper for UITextFieldDelegate method specifically for formatting phone numbers
     
     - parameter textField: The text field where a phone is being entered.
     - parameter range:     The replacement range handed back from the UITextFieldDelegate.
     - parameter string:    The replacement string handed back from the UITextFieldDelegate.`
     
     - returns: true if the string is being set
     */
    @discardableResult
    static func format(phoneTextField textField: UITextField,
                       forRange range: NSRange,
                       replacementString string: String) -> Bool {
        
        // The system's predictive text will call shouldChangeCharactersInRange twice,
        // once with an empty string, and again with the phone number string. If we don't return false here,
        // shouldChangeCharactersInRange will return false on the first string, which tells the system not to pass in the next string.
        guard !string.sph_containsOnlyWhitespace else {
            return false
        }
        
        /// TODO: Update this to use string instead of NSString
        let textFieldText: NSString = (textField.text as NSString?) ?? ""
        var changedString: String = textFieldText.replacingCharacters(in: range, with: string)
        
        //if its a delete remove until deleting a digit
        //swiftlint:disable:next control_statement
        if (range.length == 1 && string.count < range.length && self.hasInvalidPhoneCharacters(textFieldText.substring(with: range))) {
            var location = changedString.count - 1
            if location > 0 {
                while location > 0 {
                    let index = changedString.index(changedString.startIndex, offsetBy: location)
                    let nextChar = changedString[index]
                    if !self.hasInvalidPhoneCharacters(String(nextChar)) {
                        break
                    }
                    location -= 1
                }
                changedString = String(changedString.prefix(upTo: changedString.index(changedString.startIndex, offsetBy: location)))
            }
        }
        
        let formattedText = self.filteredPhoneStringFromString(changedString)
        textField.text = formattedText
        textField.rightViewMode = PhoneNumberFormatter.isValid(formattedText) ? .always : .never
        return true
    }
    
    static func isValid(_ formattedText: String) -> Bool {
        let phoneArray: [String] = formattedText.components(separatedBy: CharacterSet.decimalDigits.inverted)
        let phoneNumber: String = phoneArray.joined(separator: "")
        
        //swiftlint:disable:next control_statement
        if ((phoneNumber.count == 10 && phoneNumber[phoneNumber.startIndex] != "1") ||
            (phoneNumber.count == 11 && phoneNumber[phoneNumber.startIndex] == "1")) {
            return true
        } else {
            return false
        }
    }
    
    static func filteredPhoneStringFromString(_ string: String) -> String {
        guard !string.isEmpty else {
            return string
        }
        
        var onOriginal = 0
        var onFilter = 0
        var onOutput = 0
        
        var filter: String
        
        if string.first == "1" {
            filter = "# (###) ###-####"
        } else {
            filter = "(###) ###-####"
        }
        //swiftlint:disable:next syntactic_sugar
        var outputString = Array<Character>(repeating: " ", count: filter.count)
        var done = false
        while onFilter < filter.count && !done {
            let filterChar = filter[filter.index(filter.startIndex, offsetBy: onFilter)]
            let originalChar = onOriginal >= string.count ? "\0" : string[string.index(string.startIndex, offsetBy: onOriginal)]
            if filterChar == "#" {
                if originalChar == "\0" {
                    done = true
                    break
                }
                if self.hasInvalidPhoneCharacters(String(originalChar)) {
                    onOriginal += 1
                } else {
                    outputString[onOutput] = originalChar
                    onOriginal += 1
                    onFilter += 1
                    onOutput += 1
                    
                }
            } else {
                outputString[onOutput] = filterChar
                onOutput += 1
                onFilter += 1
                if originalChar == filterChar {
                    onOriginal += 1
                }
            }
        }
        let untrimmedString = String(outputString)
        return untrimmedString.sph_trimmedOfAllWhitespace()
    }
    
    static func formatPhoneNumberFromMachineFormat(oldNumber: String?) -> String {
        guard let oldNumber = oldNumber else {
            return ""
        }
        
        // Remove all formatting
        var unformatted = oldNumber
            .components(separatedBy: CharacterSet.decimalDigits.inverted)
            .joined()
        
        // Remove "1" if number starts with a country code
        if unformatted.first == "1" {
            unformatted.remove(at: unformatted.startIndex)
        }
        
        guard unformatted.count == 10 else {
            return oldNumber
        }
        
        let startIndex = unformatted.startIndex
        let firstDivider = unformatted.index(startIndex, offsetBy: 3)
        let secondDivider = unformatted.index(startIndex, offsetBy: 6)
        
        let firstSection = unformatted[..<firstDivider]
        let secondSection = unformatted[firstDivider..<secondDivider]
        let thirdSection = unformatted[secondDivider...]
        
        return "(\(firstSection)) \(secondSection)-\(thirdSection)"
    }
    
    //replaces letters with corresponding number pad numbers and then removes non decimalDegit chars
    static func removePhoneFormat(from string: String) -> String {
        let numberPadMapping = [
            "a" : "2",
            "b" : "2",
            "c" : "2",
            "d" : "3",
            "e" : "3",
            "f" : "3",
            "g" : "4",
            "h" : "4",
            "i" : "4",
            "j" : "5",
            "k" : "5",
            "l" : "5",
            "m" : "6",
            "n" : "6",
            "o" : "6",
            "p" : "7",
            "q" : "7",
            "r" : "7",
            "s" : "7",
            "t" : "8",
            "u" : "8",
            "v" : "8",
            "w" : "9",
            "x" : "9",
            "y" : "9",
            "z" : "9",
        ]
        var replacedLetters = string.lowercased()
        numberPadMapping.forEach { letter, number in
            replacedLetters = replacedLetters.replacingOccurrences(of: letter, with: number)
        }
        return PhoneNumberFormatter.sanitizePhoneNumber(replacedLetters)
    }
    
    //removes all chars except for decimalDigits
    static func sanitizePhoneNumber(_ phoneNumber: String) -> String {
        return phoneNumber.components(separatedBy: CharacterSet.decimalDigits.inverted).joined(separator: "")
    }
}
