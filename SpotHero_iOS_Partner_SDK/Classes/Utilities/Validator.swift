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

enum Validator {
    static func validateFullName(fullName: String) throws{
        let fieldName = "Full Name"
        
        if fullName.isEmpty {
            throw ValidatorError.FieldBlank(fieldName: fieldName)
        } else if fullName.componentsSeparatedByString(" ").count < 2 {
            throw ValidatorError.FieldInvalid(fieldName: fieldName, message: "Full Name must have at least 2 words")
        }
    }
    
    static func validateEmail(email: String) throws {
        if email.isEmpty {
            throw ValidatorError.FieldBlank(fieldName: "Email")
        }
        
        
    }
    
    static func validatePhone(phone: String) throws {
        
    }
    
    static func validateCreditCard(creditCard: String) throws {
        
    }
    
    static func validateCreditCardAMEX(creditCard: String) throws {
    }
    
    static func validateExpiration(expiration: String) throws {
    }
    
    static func validateCVC(cvc: String) throws {
    }
    
    static func validateCVCAMEX(cvc: String) throws {
    }
    
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
}