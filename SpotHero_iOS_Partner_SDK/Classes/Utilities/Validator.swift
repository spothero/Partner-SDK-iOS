//
//  Validator.swift
//  Pods
//
//  Created by SpotHeroMatt on 7/29/16.
//
//

import Foundation

enum ValidatorError: ErrorType {
    case FieldBlank(fieldName: String)
    case FieldInvalid(fieldName: String, message: String)
}

enum CardType: String {
    case
    Visa,
    Amex = "American Express",
    MasterCard,
    Discover,
    Unknown
}

//TODO: Localize error messages
enum Validator {
    
    /**
     Validates that a string is a full name
     
     - parameter fullName: string to validate
     
     - throws: throws an error if string is empty or invalid
     */
    static func validateFullName(fullName: String) throws {
        let fieldName = "Full Name"
        
        // Trim trailing spaces
        let trimmedFullName = fullName.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
        
        if trimmedFullName.isEmpty {
            throw ValidatorError.FieldBlank(fieldName: fieldName)
        } else if trimmedFullName.componentsSeparatedByString(" ").count < 2 {
            throw ValidatorError.FieldInvalid(fieldName: fieldName, message: "Full Name must have at least 2 words")
        }
    }
    
    /**
     Validates that a string is a
     
     - parameter email: string to validate
     
     - throws: throws an error if string is empty or invalid
     */
    static func validateEmail(email: String) throws {
        let fieldName = "Email"
        let message = "Please enter a valid email"
        
        // Trim trailing spaces
        let trimmedEmail = email.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
        
        if trimmedEmail.isEmpty {
            throw ValidatorError.FieldBlank(fieldName: fieldName)
        }
        
        let fullEmailPredicate = NSPredicate(format: "SELF MATCHES %@", "^\\b.+@.+\\..+\\b$")
        if !fullEmailPredicate.evaluateWithObject(trimmedEmail) {
            throw ValidatorError.FieldInvalid(fieldName: fieldName, message: message)
        }
        
        let emailParts = self.emailParts(trimmedEmail)
        
        let username = emailParts[0]
        let domain = emailParts[1]
        let tld = emailParts[2]
        
        let usernamePredicate = NSPredicate(format: "SELF MATCHES %@", "[A-Z0-9a-z.!#$%&'*+-/=?^_`{|}~]+")
        let domainPredicate = NSPredicate(format: "SELF MATCHES %@", "[A-Z0-9a-z.-]+")
        let tldPredicate = NSPredicate(format: "SELF MATCHES %@", "[A-Za-z][A-Z0-9a-z-]{0,22}[A-Z0-9a-z]")
        
        if !usernamePredicate.evaluateWithObject(username) || self.usernameValid(username) {
            throw ValidatorError.FieldInvalid(fieldName: fieldName, message: message)
        } else if domain.isEmpty || !domainPredicate.evaluateWithObject(domain) {
            throw ValidatorError.FieldInvalid(fieldName: fieldName, message: message)
        } else if !tldPredicate.evaluateWithObject(tld) {
            throw ValidatorError.FieldInvalid(fieldName: fieldName, message: message)
        }
    }
    
    /**
     Validates that a string is a
     
     - parameter phone: string to validate
     
     - throws: throws an error if string is empty or invalid
     */
    static func validatePhone(phone: String) throws {
        let fieldName = "Phone"
        let message = "Please enter a valid phone number"
        
        // Trim trailing spaces
        let trimmedPhone = phone.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
        
        if trimmedPhone.isEmpty {
            throw ValidatorError.FieldBlank(fieldName: fieldName)
        }
        
        // Remove dashes
        let digits = trimmedPhone.stringByReplacingOccurrencesOfString("-", withString: "")
        
        // Check there are ten digits and Check phone number is numeric
        if digits.characters.count != 10 || Int(digits) == nil {
            throw ValidatorError.FieldInvalid(fieldName: fieldName, message: message)
        }
    }
    
    /**
     Validates that a string is a
     
     - parameter creditCard: string to validate
     
     - throws: throws an error if string is empty or invalid
     
     - returns: Type of card
     */
    static func validateCreditCard(creditCard: String) throws -> CardType {
        let fieldName = "Credit Card"
        let trimmedCreditCard = creditCard.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
        
        if trimmedCreditCard.isEmpty {
            throw ValidatorError.FieldBlank(fieldName: fieldName)
            return .Unknown
        }
        
        let firstTwoCharacters = creditCard.substringToIndex(creditCard.startIndex.advancedBy(2))
        let firstFourCharacters = creditCard.substringToIndex(creditCard.startIndex.advancedBy(4))
        
        if creditCard.characters.first == "4" {
            try validateCreditCard(creditCard, cardType: .Visa)
            return .Visa
        } else if firstTwoCharacters == "34" ||
            firstTwoCharacters == "37" {
            try validateCreditCard(creditCard, cardType: .Amex)
            return .Amex
        } else if firstTwoCharacters == "51" ||
            firstTwoCharacters == "52" ||
            firstTwoCharacters == "53" ||
            firstTwoCharacters == "54" ||
            firstTwoCharacters == "55" {
            try validateCreditCard(creditCard, cardType: .MasterCard)
            return .MasterCard
        } else if firstFourCharacters == "6011" {
            try validateCreditCard(creditCard, cardType: .Discover)
            return .Discover
        } else {
            throw ValidatorError.FieldInvalid(fieldName: fieldName, message: "Please enter a Visa, Discover, MasterCard, or American Express card.")
            return .Unknown
        }
    
    }
    
    private static func validateCreditCard(creditCard: String, cardType: CardType) throws {
        let fieldName = "Credit Card"
        let message = "Please enter a valid credit card number"
        let numberOfDigits = (cardType == .Amex) ? 15 : 16
        
        // Remove spaces
        let digits = creditCard.stringByReplacingOccurrencesOfString(" ", withString: "")
        
        // Check if there are 15 or 16 digits and Check if numeric
        if digits.characters.count != numberOfDigits || Int(creditCard) != nil {
            throw ValidatorError.FieldInvalid(fieldName: fieldName, message: message)
        }
    }
    
    /**
     Validates that a string is a
     
     - parameter month: string to validate
     - parameter year:  string to validate
     
     - throws: throws an error if string is empty or invalid
     */
    static func validateExpiration(month: String, year: String) throws {
        let fieldName = "Expiration Date"

        let trimmedMonth = month.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
        let trimmedYear = year.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
    
        if trimmedMonth.isEmpty || trimmedYear.isEmpty {
            throw ValidatorError.FieldBlank(fieldName: fieldName)
        }
        
        let invalidDateMessage = "Please enter a valid expiration date"
        let dateInThePastMessage = "Please enter an expiration date in the future"
        
        let dateComponents = NSDateComponents()
        if let monthInt = Int(month), yearInt = Int(year) {
            dateComponents.month = monthInt
            dateComponents.year = yearInt
            let calendar = NSCalendar(calendarIdentifier: NSCalendarIdentifierGregorian)
            
            if dateComponents.month < 0 || dateComponents.month > 12 {
                throw ValidatorError.FieldInvalid(fieldName: fieldName, message: invalidDateMessage)
            } else if let date = calendar?.dateFromComponents(dateComponents) where NSDate().compare(date) == NSComparisonResult.OrderedDescending  {
                throw ValidatorError.FieldInvalid(fieldName: fieldName, message: dateInThePastMessage)
            } else if calendar?.dateFromComponents(dateComponents) == nil {
                throw ValidatorError.FieldInvalid(fieldName: fieldName, message: invalidDateMessage)
            }
        } else {
            throw ValidatorError.FieldInvalid(fieldName: fieldName, message: invalidDateMessage)
        }
    }

    /**
     Validates that a string is a
     
     - parameter cvc:  string to validate
     - parameter amex: whether card is an amex
     
     - throws: throws an error if string is empty or invalid
     */
    static func validateCVC(cvc: String, amex: Bool = false) throws {
        let fieldName = "CVC"
        let message = "Please enter a valid cvc"
        
        let trimmedCVC = cvc.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
        
        if trimmedCVC.isEmpty {
            throw ValidatorError.FieldBlank(fieldName: fieldName)
        }
        
        if amex && cvc.characters.count != 4 {
            throw ValidatorError.FieldInvalid(fieldName: fieldName, message: message)
        } else if !amex && cvc.characters.count != 3 {
            throw ValidatorError.FieldInvalid(fieldName: fieldName, message: message)
        }
    }
    
    /**
     Validates that a string is a
     
     - parameter zip: string to validate
     
     - throws: throws an error if string is empty or invalid
     */
    static func validateZip(zip: String) throws {
        let fieldName = "Zip Code"
        let trimmedZip = zip.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
        
        if trimmedZip.isEmpty {
           throw ValidatorError.FieldBlank(fieldName: fieldName)
        }
        
        if trimmedZip.characters.count != 5 || Int(trimmedZip) == nil {
            throw ValidatorError.FieldInvalid(fieldName: fieldName, message: "Please enter a valid zip code")
        }
    }
    
    // MARK: Helpers
    
    private static func emailParts(email: String) -> [String] {
        var username = ""
        var domain = ""
        var tld = ""
        
        if let atRange = email.rangeOfString("@") {
            username = email.substringToIndex(atRange.startIndex)
            if let periodRange = email.rangeOfString(".", options: .BackwardsSearch) {
                domain = email.substringWithRange(atRange.endIndex..<periodRange.startIndex)
                tld = email.substringWithRange(periodRange.endIndex..<email.endIndex)
            }
        }
     
        return [username, domain, tld]
    }
    
    private static func usernameValid(username: String) -> Bool {
        return username.isEmpty ||
            username.hasPrefix(".") ||
            username.hasSuffix(".") ||
            username.rangeOfString("..") != nil
    }
}
