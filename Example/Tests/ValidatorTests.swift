//
//  ValidatorTests.swift
//  SpotHero_iOS_Partner_SDK
//
//  Created by SpotHeroMatt on 7/29/16.
//  Copyright © 2016 SpotHero, Inc. All rights reserved.
//

import XCTest

@testable import SpotHero_iOS_Partner_SDK

// TODO: Refactor repeated code
class ValidatorTests: XCTestCase {

    func testValidFullName() {
        let validFullName = "Matt Reed"
        do {
            try Validator.validateFullName(validFullName)
            XCTAssert(true, "Did not throw an error")
        } catch let error {
            XCTFail("Validator threw an error: \(error)")
        }
    }
    
    func testInvalidFullName() {
        let invalidFullNameOneWord = "Matt"
        do {
            try Validator.validateFullName(invalidFullNameOneWord)
            XCTFail("Did not throw error")
        } catch ValidatorError.FieldInvalid(let fieldName, let message) {
            XCTAssertEqual(fieldName, LocalizedStrings.FullName)
            XCTAssertEqual(message, "Full Name must have at least 2 words")
        } catch {
            XCTFail("Validator threw the wrong error")
        }
    }
    
    func testBlankName() {
        let blankName = ""
        let blankSpace = " "
        
        do {
            try Validator.validateFullName(blankName)
            XCTFail("Did not throw error")
        } catch ValidatorError.FieldBlank(let fieldName) {
            XCTAssertEqual(fieldName, LocalizedStrings.FullName)
        } catch {
            XCTFail("Validator threw the wrong error")
        }
        
        do {
            try Validator.validateFullName(blankSpace)
            XCTFail("Did not throw error")
        } catch ValidatorError.FieldBlank(let fieldName) {
            XCTAssertEqual(fieldName, LocalizedStrings.FullName)
        } catch {
            XCTFail("Validator threw the wrong error")
        }
    }
    
    func testValidEmail() {
        let validEmail = "matt.reed@spothero.com"
        do {
            try Validator.validateEmail(validEmail)
            XCTAssert(true, "Did not throw an error")
        } catch let error {
            XCTFail("Validator threw an error: \(error)")
        }
    }

    func testInvalidEmail() {
        let invalidEmailNoTLD = "matt.reed@spothero"
        let invalidUsername = "matt..reed@spothero.com"
        let invalidTLD = "matt.reed@spothero.c"
        let invalidEmailNoUsername = "@spothero.com"
        
        do {
            try Validator.validateEmail(invalidEmailNoTLD)
            XCTFail("Did not throw error")
        } catch ValidatorError.FieldInvalid(let fieldName, let message) {
            XCTAssertEqual(fieldName, LocalizedStrings.Email)
            XCTAssertEqual(message, "Please enter a valid email")
        } catch {
            XCTFail("Validator threw the wrong error")
        }
        
        do {
            try Validator.validateEmail(invalidUsername)
            XCTFail("Did not throw error")
        } catch ValidatorError.FieldInvalid(let fieldName, let message) {
            XCTAssertEqual(fieldName, LocalizedStrings.Email)
            XCTAssertEqual(message, "Please enter a valid email")
        } catch {
            XCTFail("Validator threw the wrong error")
        }
        
        do {
            try Validator.validateEmail(invalidTLD)
            XCTFail("Did not throw error")
        } catch ValidatorError.FieldInvalid(let fieldName, let message) {
            XCTAssertEqual(fieldName, LocalizedStrings.Email)
            XCTAssertEqual(message, "Please enter a valid email")
        } catch {
            XCTFail("Validator threw the wrong error")
        }
        
        do {
            try Validator.validateEmail(invalidEmailNoUsername)
            XCTFail("Did not throw error")
        } catch ValidatorError.FieldInvalid(let fieldName, let message) {
            XCTAssertEqual(fieldName, LocalizedStrings.Email)
            XCTAssertEqual(message, "Please enter a valid email")
        } catch {
            XCTFail("Validator threw the wrong error")
        }
    }
    
    func testBlankEmail() {
        let blankEmail = ""
        let blankSpace = " "
        
        do {
            try Validator.validateEmail(blankEmail)
            XCTFail("Did not throw error")
        } catch ValidatorError.FieldBlank(let fieldName) {
            XCTAssertEqual(fieldName, LocalizedStrings.Email)
        } catch {
            XCTFail("Validator did threw the wrong error")
        }
        
        do {
            try Validator.validateEmail(blankSpace)
            XCTFail("Did not throw error")
        } catch ValidatorError.FieldBlank(let fieldName) {
            XCTAssertEqual(fieldName, LocalizedStrings.Email)
        } catch {
            XCTFail("Validator threw the wrong error")
        }
    }
    
    func testValidPhone() {
        let validPhone = "312-566-7768"
        
        do {
            try Validator.validatePhone(validPhone)
            XCTAssert(true, "Did not throw an error")
        } catch let error {
            XCTFail("Validator threw an error: \(error)")
        }
    }
    
    func testInvalidPhone() {
        let invalidPhoneNotTenDigits = "312-566"
        let invalidPhoneNonNumeric = "232-2d23-2232"
        
        do {
            try Validator.validatePhone(invalidPhoneNotTenDigits)
            XCTFail("Did not throw error")
        } catch ValidatorError.FieldInvalid(let fieldName, let message) {
            XCTAssertEqual(fieldName, LocalizedStrings.Phone)
            XCTAssertEqual(message, "Please enter a valid phone number")
        } catch {
            XCTFail("Validator threw the wrong error")
        }
        
        do {
            try Validator.validatePhone(invalidPhoneNonNumeric)
            XCTFail("Did not throw error")
        } catch ValidatorError.FieldInvalid(let fieldName, let message) {
            XCTAssertEqual(fieldName, LocalizedStrings.Phone)
            XCTAssertEqual(message, "Please enter a valid phone number")
        } catch {
            XCTFail("Validator threw the wrong error")
        }
    }
    
    func testBlankPhone() {
        let blankPhone = ""
        let blankSpace = " "
        
        do {
            try Validator.validatePhone(blankPhone)
            XCTFail("Did not throw error")
        } catch ValidatorError.FieldBlank(let fieldName) {
            XCTAssertEqual(fieldName, LocalizedStrings.Phone)
        } catch {
            XCTFail("Validator did threw the wrong error")
        }
        
        do {
            try Validator.validatePhone(blankSpace)
            XCTFail("Did not throw error")
        } catch ValidatorError.FieldBlank(let fieldName) {
            XCTAssertEqual(fieldName, LocalizedStrings.Phone)
        } catch {
            XCTFail("Validator threw the wrong error")
        }
    }
    
    func testValidVisa() {
        let validVisa = "4556 6580 0837 9641"
        
        do {
            let cardType = try Validator.validateCreditCard(validVisa)
            XCTAssertEqual(cardType, CardType.Visa)
        } catch let error {
            XCTFail("Validator threw an error: \(error)")
        }
    }
    
    func testValidDiscover() {
        let validDiscover = "6011 2313 8733 6725"
        
        do {
            let cardType = try Validator.validateCreditCard(validDiscover)
            XCTAssertEqual(cardType, CardType.Discover)
        } catch let error {
            XCTFail("Validator threw an error: \(error)")
        }
    }
    
    func testValidMasterCard() {
        let validMasterCard = "5459 4943 0766 9580"
        
        do {
            let cardType = try Validator.validateCreditCard(validMasterCard)
            XCTAssertEqual(cardType, CardType.MasterCard)
        } catch let error {
            XCTFail("Validator threw an error: \(error)")
        }
    }
    
    func testValidAmex() {
        let validAmex = "3456 318993 86110"
        
        do {
            let cardType = try Validator.validateCreditCard(validAmex)
            XCTAssertEqual(cardType, CardType.Amex)
        } catch let error {
            XCTFail("Validator threw an error: \(error)")
        }
    }
    
    func testInvalidVisa() {
        let invalidVisa = "4242 42 4242 234"
        
        do {
            try Validator.validateCreditCard(invalidVisa)
            XCTFail("Validator did not throw an error")
        } catch ValidatorError.FieldInvalid(let fieldName, let message) {
            XCTAssertEqual(fieldName, LocalizedStrings.CreditCard)
            XCTAssertEqual(message, "Please enter a valid credit card number")
        } catch let error {
            XCTFail("Validator threw the wrong error: \(error)")
        }
    }
    
    func testInvalidDiscover() {
        let invalidDiscover = "6011 2313 33 6725"
        
        do {
            try Validator.validateCreditCard(invalidDiscover)
            XCTFail("Validator did not throw an error")
        } catch ValidatorError.FieldInvalid(let fieldName, let message) {
            XCTAssertEqual(fieldName, LocalizedStrings.CreditCard)
            XCTAssertEqual(message, "Please enter a valid credit card number")
        } catch let error {
            XCTFail("Validator threw the wrong error: \(error)")
        }
    }
    
    func testInvalidMasterCard() {
        let validMasterCard = "5459 4943 066 9580"
        
        do {
            try Validator.validateCreditCard(validMasterCard)
            XCTFail("Validator did not throw an error")
        } catch ValidatorError.FieldInvalid(let fieldName, let message) {
            XCTAssertEqual(fieldName, LocalizedStrings.CreditCard)
            XCTAssertEqual(message, "Please enter a valid credit card number")
        } catch let error {
            XCTFail("Validator threw the wrong error: \(error)")
        }
    }
    
    func testInvalidAMEX() {
        let invalidAMEX = "3456 31893 86110"
        
        do {
            try Validator.validateCreditCard(invalidAMEX)
            XCTFail("Validator did not throw an error")
        } catch ValidatorError.FieldInvalid(let fieldName, let message) {
            XCTAssertEqual(fieldName, LocalizedStrings.CreditCard)
            XCTAssertEqual(message, "Please enter a valid credit card number")
        } catch let error {
            XCTFail("Validator threw the wrong error: \(error)")
        }
    }
    
    func testInvalidCreditCard() {
        let invalidCreditCard = "1234 5678 1234 5678"
        
        do {
            try Validator.validateCreditCard(invalidCreditCard)
            XCTFail("Validator did not throw an error")
        } catch ValidatorError.FieldInvalid(let fieldName, let message) {
            XCTAssertEqual(fieldName, LocalizedStrings.CreditCard)
            XCTAssertEqual(message, "Please enter a Visa, Discover, MasterCard, or American Express card.")
        } catch let error {
            XCTFail("Validator threw the wrong error: \(error)")
        }
    }
    
    func testBlankCreditCard() {
        let blankCreditCard = ""
        let blankSpace = " "
        
        do {
            try Validator.validateCreditCard(blankCreditCard)
            XCTFail("Validator did not throw an error")
        } catch ValidatorError.FieldBlank(let fieldName) {
            XCTAssertEqual(fieldName, LocalizedStrings.CreditCard)
        } catch let error {
            XCTFail("Validator threw the wrong error: \(error)")
        }
        
        do {
            try Validator.validateCreditCard(blankSpace)
            XCTFail("Validator did not throw an error")
        } catch ValidatorError.FieldBlank(let fieldName) {
            XCTAssertEqual(fieldName, LocalizedStrings.CreditCard)
        } catch let error {
            XCTFail("Validator threw the wrong error: \(error)")
        }
    }
    
    func testValidExpirationDate() {
        let date = NSDate().dateByAddingTimeInterval(60 * 60 * 24 * 365)
        let calendar = NSCalendar(calendarIdentifier: NSCalendarIdentifierGregorian)
        
        if let dateComponents = calendar?.components([.Month, .Year], fromDate: date) {
            let month = String(dateComponents.month)
            let year = String(dateComponents.year)
            
            do {
                try Validator.validateExpiration(month, year: year)
                XCTAssert(true, "Did not throw an error")
            } catch let error {
                XCTFail("Validator threw an error: \(error)")
            }
        } else {
            XCTFail("Cannot get date")
        }
    }
    
    func testInvalidExpirationDate() {
        let date = NSDate()
        let calendar = NSCalendar(calendarIdentifier: NSCalendarIdentifierGregorian)
    
        
        
        if let dateComponents = calendar?.components([.Month, .Year], fromDate: date) {
            let month = String(dateComponents.month)
            let year = String(dateComponents.year)
            
            let pastMonth: String
            if dateComponents.month == 1 {
                pastMonth = "12"
            } else {
                pastMonth = String(dateComponents.month - 1)
            }
            
            let pastYear = String(dateComponents.year - 1)
            let invalidMonth = "14"
            let invalidYear = "200e3"
            
            do {
                if month == "12" {
                    try Validator.validateExpiration(pastMonth, year: pastYear)
                } else {
                    try Validator.validateExpiration(pastMonth, year: year)
                }
                
                XCTFail("Validator did not throw an error")
            } catch ValidatorError.FieldInvalid(let fieldName, let message) {
                XCTAssertEqual(fieldName, LocalizedStrings.ExpirationDate)
                XCTAssertEqual(message, "Please enter an expiration date in the future")
            } catch let error {
                XCTFail("Validator threw the wrong error: \(error)")
            }
            
            do {
                try Validator.validateExpiration(month, year: pastYear)
                XCTFail("Validator did not throw an error")
            } catch ValidatorError.FieldInvalid(let fieldName, let message) {
                XCTAssertEqual(fieldName, LocalizedStrings.ExpirationDate)
                XCTAssertEqual(message, "Please enter an expiration date in the future")
            } catch let error {
                XCTFail("Validator threw the wrong error: \(error)")
            }
            
            do {
                try Validator.validateExpiration(month, year: invalidYear)
                XCTFail("Validator did not throw an error")
            } catch ValidatorError.FieldInvalid(let fieldName, let message) {
                XCTAssertEqual(fieldName, LocalizedStrings.ExpirationDate)
                XCTAssertEqual(message, "Please enter a valid expiration date")
            } catch let error {
                XCTFail("Validator threw the wrong error: \(error)")
            }
            
            do {
                try Validator.validateExpiration(invalidMonth, year: year)
                XCTFail("Validator did not throw an error")
            } catch ValidatorError.FieldInvalid(let fieldName, let message) {
                XCTAssertEqual(fieldName, LocalizedStrings.ExpirationDate)
                XCTAssertEqual(message, "Please enter a valid expiration date")
            } catch let error {
                XCTFail("Validator threw the wrong error: \(error)")
            }
        } else {
            XCTFail("Cannot get date")
        }
    }
    
    func testBlankExpirationDate() {
        let blank = ""
        let space = " "
        
        do {
            try Validator.validateExpiration(blank, year: blank)
            XCTFail("Did not throw an error")
        } catch ValidatorError.FieldBlank(let fieldName) {
            XCTAssertEqual(fieldName, LocalizedStrings.ExpirationDate)
        } catch let error {
            XCTFail("Validator threw the wrong error: \(error)")
        }
        
        do {
            try Validator.validateExpiration(space, year: space)
            XCTFail("Did not throw an error")
        } catch ValidatorError.FieldBlank(let fieldName) {
            XCTAssertEqual(fieldName, LocalizedStrings.ExpirationDate)
        } catch let error {
            XCTFail("Validator threw the wrong error: \(error)")
        }
    }
    
    func testValidCVC() {
        let validCVCNonAmex = "123"
        let validCVCAmex = "1234"
        
        do {
            try Validator.validateCVC(validCVCNonAmex)
            XCTAssert(true, "Did not throw error")
        } catch let error {
            XCTFail("Threw error: \(error)")
        }
        
        do {
            try Validator.validateCVC(validCVCAmex, amex: true)
            XCTAssert(true, "Did not throw error")
        } catch let error {
            XCTFail("Threw error: \(error)")
        }
    }
    
    func testInvalidCVC() {
        let invalidCVC = "12"
        let invalidCVCAmex = "123"
        let invalidCVCNonAmex = "1234"
        
        do {
            try Validator.validateCVC(invalidCVC)
            XCTFail("Did not throw error")
        } catch ValidatorError.FieldInvalid(let fieldName, let message) {
            XCTAssertEqual(fieldName, LocalizedStrings.CVC)
            XCTAssertEqual(message, "Please enter a valid cvc")
        } catch let error {
            XCTFail("Threw wrong error: \(error)")
        }
        
        do {
            try Validator.validateCVC(invalidCVCNonAmex)
            XCTFail("Did not throw error")
        } catch ValidatorError.FieldInvalid(let fieldName, let message) {
            XCTAssertEqual(fieldName, LocalizedStrings.CVC)
            XCTAssertEqual(message, "Please enter a valid cvc")
        } catch let error {
            XCTFail("Threw wrong error: \(error)")
        }
        
        do {
            try Validator.validateCVC(invalidCVC, amex: true)
            XCTFail("Did not throw error")
        } catch ValidatorError.FieldInvalid(let fieldName, let message) {
            XCTAssertEqual(fieldName, LocalizedStrings.CVC)
            XCTAssertEqual(message, "Please enter a valid cvc")
        } catch let error {
            XCTFail("Threw wrong error: \(error)")
        }
        
        do {
            try Validator.validateCVC(invalidCVCAmex, amex: true)
            XCTFail("Did not throw error")
        } catch ValidatorError.FieldInvalid(let fieldName, let message) {
            XCTAssertEqual(fieldName, LocalizedStrings.CVC)
            XCTAssertEqual(message, "Please enter a valid cvc")
        } catch let error {
            XCTFail("Threw wrong error: \(error)")
        }
    }
    
    func testBlankCVC() {
        let blank = ""
        let space = " "
        
        do {
            try Validator.validateCVC(blank)
            XCTFail("Did not throw an error")
        } catch ValidatorError.FieldBlank(let fieldName) {
            XCTAssertEqual(fieldName, LocalizedStrings.CVC)
        } catch let error {
            XCTFail("Validator threw the wrong error: \(error)")
        }
        
        do {
            try Validator.validateCVC(space)
            XCTFail("Did not throw an error")
        } catch ValidatorError.FieldBlank(let fieldName) {
            XCTAssertEqual(fieldName, LocalizedStrings.CVC)
        } catch let error {
            XCTFail("Validator threw the wrong error: \(error)")
        }
    }
    
    func testValidZip() {
        let zip = "60601"
        
        do {
            try Validator.validateZip(zip)
            XCTAssert(true, "Did not throw and error")
        } catch let error {
            XCTFail("Threw an error: \(error)")
        }
    }
    
    func testInvalidZip() {
        let zipWrongLength = "6061"
        let zipNonNumeric = "353m3"
        
        do {
            try Validator.validateZip(zipWrongLength)
            XCTFail("Did not throw and error")
        } catch ValidatorError.FieldInvalid(let fieldName, let message) {
            XCTAssertEqual(fieldName, LocalizedStrings.ZipCode)
            XCTAssertEqual(message, "Please enter a valid zip code")
        } catch let error {
            XCTFail("Threw an error: \(error)")
        }
        
        do {
            try Validator.validateZip(zipNonNumeric)
            XCTFail("Did not throw and error")
        } catch ValidatorError.FieldInvalid(let fieldName, let message) {
            XCTAssertEqual(fieldName, LocalizedStrings.ZipCode)
            XCTAssertEqual(message, "Please enter a valid zip code")
        } catch let error {
            XCTFail("Threw an error: \(error)")
        }
    }
    
    func testBlankZip() {
        let blank = ""
        let space = " "
        
        do {
            try Validator.validateZip(blank)
            XCTFail("Did not throw an error")
        } catch ValidatorError.FieldBlank(let fieldName) {
            XCTAssertEqual(fieldName, LocalizedStrings.ZipCode)
        } catch let error {
            XCTFail("Validator threw the wrong error: \(error)")
        }
        
        do {
            try Validator.validateZip(space)
            XCTFail("Did not throw an error")
        } catch ValidatorError.FieldBlank(let fieldName) {
            XCTAssertEqual(fieldName, LocalizedStrings.ZipCode)
        } catch let error {
            XCTFail("Validator threw the wrong error: \(error)")
        }
    }
}
