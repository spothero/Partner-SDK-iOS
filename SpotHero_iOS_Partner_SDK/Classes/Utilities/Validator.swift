//
//  Validator.swift
//  Pods
//
//  Created by Matthew Reed on 7/29/16.
//
//

import Foundation

enum ValidatorError: ErrorType {
    case FieldBlank(fieldName: String)
    case FieldInvalid(fieldName: String, message: String)
}

enum CardType {
    case
    Visa,
    Amex,
    MasterCard,
    Discover,
    Unknown
    
    func image() -> UIImage? {
        let bundle = NSBundle.shp_resourceBundle()
        switch self {
        case .Visa:
            return UIImage(named: "Visa",
                           inBundle: bundle,
                           compatibleWithTraitCollection: nil)
        case .Amex:
            return UIImage(named: "AExp",
                           inBundle: bundle,
                           compatibleWithTraitCollection: nil)
        case .MasterCard:
            return UIImage(named: "Mastercard",
                           inBundle: bundle,
                           compatibleWithTraitCollection: nil)
        case .Discover:
            return UIImage(named: "Discover",
                           inBundle: bundle,
                           compatibleWithTraitCollection: nil)
        case .Unknown:
            return UIImage(named: "credit_card",
                           inBundle: bundle,
                           compatibleWithTraitCollection: nil)
        }
    }
}

enum Validator {
    /**
     Validates that a string is an email
     
     - parameter email: string to validate
     
     - throws: throws an error if string is empty or invalid
     */
    static func validateEmail(email: String) throws {
        let fieldName = LocalizedStrings.Email
        let message = LocalizedStrings.EmailErrorMessage
        
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
        
        if !usernamePredicate.evaluateWithObject(username) || self.usernameInvalid(username) {
            throw ValidatorError.FieldInvalid(fieldName: fieldName, message: message)
        } else if domain.isEmpty || !domainPredicate.evaluateWithObject(domain) {
            throw ValidatorError.FieldInvalid(fieldName: fieldName, message: message)
        } else if !tldPredicate.evaluateWithObject(tld) {
            throw ValidatorError.FieldInvalid(fieldName: fieldName, message: message)
        }
    }
    
    /**
     Validates that a string is a phone number
     
     - parameter phone: string to validate
     
     - throws: throws an error if string is empty or invalid
     */
    static func validatePhone(phone: String) throws {
        let fieldName = LocalizedStrings.Phone
        let message = LocalizedStrings.PhoneErrorMessage
        
        // Trim trailing spaces
        let trimmedPhone = phone.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
        
        if trimmedPhone.isEmpty {
            throw ValidatorError.FieldBlank(fieldName: fieldName)
        }
        
        // Remove dashes
        let digits = trimmedPhone.stringByReplacingOccurrencesOfString("-", withString: "")
        
        // Check there are ten digits and Check phone number is numeric
        if digits.characters.count != 10 || !self.isStringNumeric(digits) {
            throw ValidatorError.FieldInvalid(fieldName: fieldName, message: message)
        }
    }
    
    /**
     Returns the type of credit card
     
     - parameter creditCard: Credit card number
     
     - returns: Type of card
     */
    static func getCardType(creditCard: String) -> CardType {
        let trimmedCreditCard = creditCard.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
        
        if trimmedCreditCard.isEmpty {
            return .Unknown
        }
        
        if trimmedCreditCard.hasPrefix("4") {
            return .Visa
        } else if trimmedCreditCard.hasPrefix("34") ||
            trimmedCreditCard.hasPrefix("37") {
            return .Amex
        } else if trimmedCreditCard.hasPrefix("51") ||
            trimmedCreditCard.hasPrefix("52") ||
            trimmedCreditCard.hasPrefix("53") ||
            trimmedCreditCard.hasPrefix("54") ||
            trimmedCreditCard.hasPrefix("55") {
            return .MasterCard
        } else if trimmedCreditCard.hasPrefix("6011") {
            return .Discover
        } else {
            return .Unknown
        }
    }
    
    /**
     Validates that a string is a credit card number
     
     - parameter creditCard: string to validate
     
     - throws: throws an error if string is empty or invalid
    */
    static func validateCreditCard(creditCard: String) throws {
        let fieldName = LocalizedStrings.CreditCard
        let trimmedCreditCard = creditCard.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
        let cardType = self.getCardType(trimmedCreditCard)
        
        if trimmedCreditCard.isEmpty {
            throw ValidatorError.FieldBlank(fieldName: fieldName)
        }
        
        if cardType == .Unknown {
            throw ValidatorError.FieldInvalid(fieldName: fieldName, message: LocalizedStrings.NonAcceptedCreditCardErrorMessage)
        }
        
        try self.validateCreditCard(trimmedCreditCard, isAmex: cardType == .Amex)
    }
    
    private static func validateCreditCard(creditCard: String, isAmex: Bool) throws {
        let fieldName = LocalizedStrings.CreditCard
        let message = LocalizedStrings.CreditCardErrorMessage
        let numberOfDigits = isAmex ? 15 : 16
        
        // Remove spaces
        let digits = creditCard.stringByReplacingOccurrencesOfString(" ", withString: "")
        
        // Check if there are an incorrect number of digits and Check if non numeric
        if digits.characters.count != numberOfDigits || !self.isStringNumeric(digits) {
            throw ValidatorError.FieldInvalid(fieldName: fieldName, message: message)
        }
    }
    
    /**
     Validates that a string is an expiration date
     
     - parameter month: string to validate
     - parameter year:  string to validate
     
     - throws: throws an error if string is empty or invalid
     */
    static func validateExpiration(month: String, year: String) throws {
        let fieldName = LocalizedStrings.ExpirationDate

        let trimmedMonth = month.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
        let trimmedYear = year.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
    
        if trimmedMonth.isEmpty || trimmedYear.isEmpty {
            throw ValidatorError.FieldBlank(fieldName: fieldName)
        }
        
        let invalidDateMessage = LocalizedStrings.InvalidDateErrorMessage
        let dateInThePastMessage = LocalizedStrings.DateInThePastErrorMessage
        
        let dateComponents = NSDateComponents()
        if let
            monthInt = Int(trimmedMonth),
            yearInt = Int(trimmedYear) {
            dateComponents.month = monthInt
            dateComponents.year = yearInt
            let calendar = NSCalendar(calendarIdentifier: NSCalendarIdentifierGregorian)
            
            if dateComponents.month < 0 || dateComponents.month > 12 {
                throw ValidatorError.FieldInvalid(fieldName: fieldName, message: invalidDateMessage)
            } else if let date = calendar?.dateFromComponents(dateComponents)
                    where date.shp_isBeforeDate(NSDate()) {
                throw ValidatorError.FieldInvalid(fieldName: fieldName, message: dateInThePastMessage)
            } else if calendar?.dateFromComponents(dateComponents) == nil {
                throw ValidatorError.FieldInvalid(fieldName: fieldName, message: invalidDateMessage)
            } else {
                // Date is valid. Nothing to do
            }
        } else {
            throw ValidatorError.FieldInvalid(fieldName: fieldName, message: invalidDateMessage)
        }
    }

    /**
     Validates that a string is a cvc
     
     - parameter cvc:  string to validate
     - parameter amex: whether card is an amex
     
     - throws: throws an error if string is empty or invalid
     */
    static func validateCVC(cvc: String, amex: Bool = false) throws {
        let fieldName = LocalizedStrings.CVC
        let message = LocalizedStrings.CVCErrorMessage
        
        let trimmedCVC = cvc.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
        
        if trimmedCVC.isEmpty {
            throw ValidatorError.FieldBlank(fieldName: fieldName)
        }
        
        if amex && cvc.characters.count != 4 {
            throw ValidatorError.FieldInvalid(fieldName: fieldName, message: message)
        } else if !amex && cvc.characters.count != 3 {
            throw ValidatorError.FieldInvalid(fieldName: fieldName, message: message)
        } else {
            // CVC is valid. Nothing to do
        }
    }
    
    /**
     Validates that a string is a zip code
     
     - parameter zip: string to validate
     
     - throws: throws an error if string is empty or invalid
     */
    static func validateZip(zip: String) throws {
        let fieldName = LocalizedStrings.ZipCode
        let trimmedZip = zip.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
        
        if trimmedZip.isEmpty {
           throw ValidatorError.FieldBlank(fieldName: fieldName)
        }
        
        if trimmedZip.characters.count != 5 || !self.isStringNumeric(trimmedZip) {
            throw ValidatorError.FieldInvalid(fieldName: fieldName, message: LocalizedStrings.ZipErrorMessage)
        }
    }
    
    /**
     Validates that a string is a license plate number
     
     - parameter license: string to validate
     
     - throws: throws an error if string is blank or in valid
     */
    static func validateLicense(license: String) throws {
        let trimmedLicense = license.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
        
        let fieldName = LocalizedStrings.LicensePlate
        let message = LocalizedStrings.LicensePlateErrorMessage
        
        let validLicensePlateCharacters = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz1234567890 "
        let maxPlateCharacters = 12
        
        let invalidPlateCharacters = NSCharacterSet(charactersInString: validLicensePlateCharacters).invertedSet
        
        if trimmedLicense.rangeOfCharacterFromSet(invalidPlateCharacters) != nil || trimmedLicense.characters.count > maxPlateCharacters {
            throw ValidatorError.FieldInvalid(fieldName: fieldName, message: message)
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
    
    private static func usernameInvalid(username: String) -> Bool {
        return username.isEmpty ||
            username.hasPrefix(".") ||
            username.hasSuffix(".") ||
            username.rangeOfString("..") != nil
    }
    
    static func isStringNumeric(string: String) -> Bool {
        let allNonNumbers = NSCharacterSet.decimalDigitCharacterSet().invertedSet
        return string.rangeOfCharacterFromSet(allNonNumbers) == nil
    }
}
