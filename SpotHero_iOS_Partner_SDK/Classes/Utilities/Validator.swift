//
//  Validator.swift
//  Pods
//
//  Created by Matthew Reed on 7/29/16.
//
//

import Foundation

enum ValidatorError: Error {
    case fieldBlank(fieldName: String)
    case fieldInvalid(fieldName: String, message: String)
}

enum CardType {
    case
    visa,
    amex,
    masterCard,
    discover,
    unknown
    
    func image() -> UIImage? {
        let bundle = Bundle.shp_resourceBundle()
        switch self {
        case .visa:
            return UIImage(named: "Visa",
                           in: bundle,
                           compatibleWith: nil)
        case .amex:
            return UIImage(named: "AExp",
                           in: bundle,
                           compatibleWith: nil)
        case .masterCard:
            return UIImage(named: "Mastercard",
                           in: bundle,
                           compatibleWith: nil)
        case .discover:
            return UIImage(named: "Discover",
                           in: bundle,
                           compatibleWith: nil)
        case .unknown:
            return UIImage(named: "credit_card",
                           in: bundle,
                           compatibleWith: nil)
        }
    }
}

enum Validator {
    /**
     Validates that a string is an email
     
     - parameter email: string to validate
     
     - throws: throws an error if string is empty or invalid
     */
    static func validateEmail(_ email: String) throws {
        let fieldName = LocalizedStrings.Email
        let message = LocalizedStrings.EmailErrorMessage
        
        // Trim trailing spaces
        let trimmedEmail = email.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        
        if trimmedEmail.isEmpty {
            throw ValidatorError.fieldBlank(fieldName: fieldName)
        }
        
        let fullEmailPredicate = NSPredicate(format: "SELF MATCHES %@", "^\\b.+@.+\\..+\\b$")
        if !fullEmailPredicate.evaluate(with: trimmedEmail) {
            throw ValidatorError.fieldInvalid(fieldName: fieldName, message: message)
        }
        
        let emailParts = self.emailParts(trimmedEmail)
        
        let username = emailParts[0]
        let domain = emailParts[1]
        let tld = emailParts[2]
        
        let usernamePredicate = NSPredicate(format: "SELF MATCHES %@", "[A-Z0-9a-z.!#$%&'*+-/=?^_`{|}~]+")
        let domainPredicate = NSPredicate(format: "SELF MATCHES %@", "[A-Z0-9a-z.-]+")
        let tldPredicate = NSPredicate(format: "SELF MATCHES %@", "[A-Za-z][A-Z0-9a-z-]{0,22}[A-Z0-9a-z]")
        
        if !usernamePredicate.evaluate(with: username) || self.usernameInvalid(username) {
            throw ValidatorError.fieldInvalid(fieldName: fieldName, message: message)
        } else if domain.isEmpty || !domainPredicate.evaluate(with: domain) {
            throw ValidatorError.fieldInvalid(fieldName: fieldName, message: message)
        } else if !tldPredicate.evaluate(with: tld) {
            throw ValidatorError.fieldInvalid(fieldName: fieldName, message: message)
        }
    }
    
    /**
     Validates that a string is a phone number
     
     - parameter phone: string to validate
     
     - throws: throws an error if string is empty or invalid
     */
    static func validatePhone(_ phone: String) throws {
        // Trim trailing spaces
        let trimmedPhone = phone.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        
        // If phone number is blank return
        guard !trimmedPhone.isEmpty else {
            return
        }
        
        // Remove dashes
        let digits = trimmedPhone.replacingOccurrences(of: "-", with: "")
        
        // Check there are ten digits and Check phone number is numeric
        if digits.characters.count != 10 || !self.isStringNumeric(digits) {
            let fieldName = LocalizedStrings.Phone
            let message = LocalizedStrings.PhoneErrorMessage
            
            throw ValidatorError.fieldInvalid(fieldName: fieldName, message: message)
        }
    }
    
    /**
     Returns the type of credit card
     
     - parameter creditCard: Credit card number
     
     - returns: Type of card
     */
    static func getCardType(_ creditCard: String) -> CardType {
        let trimmedCreditCard = creditCard.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        
        if trimmedCreditCard.isEmpty {
            return .unknown
        }
        
        if trimmedCreditCard.hasPrefix("4") {
            return .visa
        } else if trimmedCreditCard.hasPrefix("34") ||
            trimmedCreditCard.hasPrefix("37") {
            return .amex
        } else if trimmedCreditCard.hasPrefix("51") ||
            trimmedCreditCard.hasPrefix("52") ||
            trimmedCreditCard.hasPrefix("53") ||
            trimmedCreditCard.hasPrefix("54") ||
            trimmedCreditCard.hasPrefix("55") {
            return .masterCard
        } else if trimmedCreditCard.hasPrefix("6011") {
            return .discover
        } else {
            return .unknown
        }
    }
    
    /**
     Validates that a string is a credit card number
     
     - parameter creditCard: string to validate
     
     - throws: throws an error if string is empty or invalid
     */
    static func validateCreditCard(_ creditCard: String) throws {
        let fieldName = LocalizedStrings.CreditCard
        let trimmedCreditCard = creditCard.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        let cardType = self.getCardType(trimmedCreditCard)
        
        if trimmedCreditCard.isEmpty {
            throw ValidatorError.fieldBlank(fieldName: fieldName)
        }
        
        if cardType == .unknown {
            throw ValidatorError.fieldInvalid(fieldName: fieldName, message: LocalizedStrings.NonAcceptedCreditCardErrorMessage)
        }
        
        try self.validateCreditCard(trimmedCreditCard, isAmex: cardType == .amex)
    }
    
    private static func validateCreditCard(_ creditCard: String, isAmex: Bool) throws {
        let fieldName = LocalizedStrings.CreditCard
        let message = LocalizedStrings.CreditCardErrorMessage
        let numberOfDigits = isAmex ? 15 : 16
        
        // Remove spaces
        let digits = creditCard.replacingOccurrences(of: " ", with: "")
        
        // Check if there are an incorrect number of digits and Check if non numeric
        if digits.characters.count != numberOfDigits || !self.isStringNumeric(digits) {
            throw ValidatorError.fieldInvalid(fieldName: fieldName, message: message)
        }
    }
    
    /**
     Validates that a string is an expiration date
     
     - parameter month: string to validate
     - parameter year:  string to validate
     
     - throws: throws an error if string is empty or invalid
     */
    static func validateExpiration(_ month: String, year: String) throws {
        let fieldName = LocalizedStrings.ExpirationDate
        
        let trimmedMonth = month.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        let trimmedYear = year.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        
        if trimmedMonth.isEmpty || trimmedYear.isEmpty {
            throw ValidatorError.fieldBlank(fieldName: fieldName)
        }
        
        let invalidDateMessage = LocalizedStrings.InvalidDateErrorMessage
        let dateInThePastMessage = LocalizedStrings.DateInThePastErrorMessage
        
        var dateComponents = DateComponents()
        
        if
            let monthInt = Int(trimmedMonth),
            let yearInt = Int(trimmedYear) {
                dateComponents.month = monthInt
                dateComponents.year = yearInt
                let calendar = Calendar(identifier: Calendar.Identifier.gregorian)
                
                if monthInt < 0 || monthInt > 12 {
                    throw ValidatorError.fieldInvalid(fieldName: fieldName, message: invalidDateMessage)
                } else if let date = calendar.date(from: dateComponents), date.shp_isBeforeDate(Date()) {
                    throw ValidatorError.fieldInvalid(fieldName: fieldName, message: dateInThePastMessage)
                } else if calendar.date(from: dateComponents) == nil {
                    throw ValidatorError.fieldInvalid(fieldName: fieldName, message: invalidDateMessage)
                } else {
                    // Date is valid. Nothing to do
                }
        } else {
            throw ValidatorError.fieldInvalid(fieldName: fieldName, message: invalidDateMessage)
        }
    }
    
    /**
     Validates that a string is a cvc
     
     - parameter cvc:  string to validate
     - parameter amex: whether card is an amex
     
     - throws: throws an error if string is empty or invalid
     */
    static func validateCVC(_ cvc: String, amex: Bool = false) throws {
        let fieldName = LocalizedStrings.CVC
        let message = LocalizedStrings.CVCErrorMessage
        
        let trimmedCVC = cvc.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        
        if trimmedCVC.isEmpty {
            throw ValidatorError.fieldBlank(fieldName: fieldName)
        }
        
        if amex && cvc.characters.count != 4 {
            throw ValidatorError.fieldInvalid(fieldName: fieldName, message: message)
        } else if !amex && cvc.characters.count != 3 {
            throw ValidatorError.fieldInvalid(fieldName: fieldName, message: message)
        } else {
            // CVC is valid. Nothing to do
        }
    }
    
    /**
     Validates that a string is a zip code
     
     - parameter zip: string to validate
     
     - throws: throws an error if string is empty or invalid
     */
    static func validateZip(_ zip: String) throws {
        let fieldName = LocalizedStrings.ZipCode
        let trimmedZip = zip.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        
        if trimmedZip.isEmpty {
            throw ValidatorError.fieldBlank(fieldName: fieldName)
        }
        
        if trimmedZip.characters.count != 5 || !self.isStringNumeric(trimmedZip) {
            throw ValidatorError.fieldInvalid(fieldName: fieldName, message: LocalizedStrings.ZipErrorMessage)
        }
    }
    
    /**
     Validates that a string is a license plate number
     
     - parameter license: string to validate
     
     - throws: throws an error if string is blank or in valid
     */
    static func validateLicense(_ license: String) throws {
        let trimmedLicense = license.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        
        let fieldName = LocalizedStrings.LicensePlate
        let message = LocalizedStrings.LicensePlateErrorMessage
        
        let validLicensePlateCharacters = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz1234567890 "
        let maxPlateCharacters = 12
        
        let invalidPlateCharacters = CharacterSet(charactersIn: validLicensePlateCharacters).inverted
        
        if trimmedLicense.rangeOfCharacter(from: invalidPlateCharacters) != nil || trimmedLicense.characters.count > maxPlateCharacters {
            throw ValidatorError.fieldInvalid(fieldName: fieldName, message: message)
        }
    }
    
    // MARK: Helpers
    
    private static func emailParts(_ email: String) -> [String] {
        var username = ""
        var domain = ""
        var tld = ""
        
        if let atRange = email.range(of: "@") {
            username = email.substring(to: atRange.lowerBound)
            if let periodRange = email.range(of: ".", options: .backwards) {
                domain = email.substring(with: atRange.upperBound..<periodRange.lowerBound)
                tld = email.substring(with: periodRange.upperBound..<email.endIndex)
            }
        }
        
        return [username, domain, tld]
    }
    
    private static func usernameInvalid(_ username: String) -> Bool {
        return username.isEmpty ||
            username.hasPrefix(".") ||
            username.hasSuffix(".") ||
            username.range(of: "..") != nil
    }
    
    static func isStringNumeric(_ string: String) -> Bool {
        let allNonNumbers = CharacterSet.decimalDigits.inverted
        return string.rangeOfCharacter(from: allNonNumbers) == nil
    }
}
