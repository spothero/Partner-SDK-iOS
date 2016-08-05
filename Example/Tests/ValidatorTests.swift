//
//  ValidatorTests.swift
//  SpotHero_iOS_Partner_SDK
//
//  Created by SpotHeroMatt on 7/29/16.
//  Copyright © 2016 SpotHero, Inc. All rights reserved.
//

import XCTest

@testable import SpotHero_iOS_Partner_SDK

class ValidatorTests: XCTestCase {
    private let emptyString = ""
    private let blankSpace = " "
    
    //MARK: Helpers
    
    private func validateThatErrorIsNotThrown(file: StaticString = #file,
                                      line: UInt = #line,
                                      closure: () throws -> ()) {
        do {
            try closure()
            XCTAssert(true, "Did not throw an error",
                      file: file,
                      line: line)
        } catch let error {
            XCTFail("Validator threw an error: \(error)",
                    file: file,
                    line: line)
        }
    }
    
    private func validateThatFieldBlankErrorThrown(errorFieldName: String,
                                           file: StaticString = #file,
                                           line: UInt = #line,
                                           closure: () throws -> ()) {
        do {
            try closure()
            XCTFail("Did not throw an error",
                    file: file,
                    line: line)
        } catch ValidatorError.FieldBlank(let fieldName) {
            XCTAssertEqual(fieldName,
                           errorFieldName,
                           file: file,
                           line: line)
        } catch let error {
            XCTFail("The wrong error was thrown: \(error)",
                    file: file,
                    line: line)
        }
    }
    
    private func validateThatFieldInvalidErrorIsThrown(errorFieldName: String,
                                               errorMessage: String,
                                               file: StaticString = #file,
                                               line: UInt = #line,
                                               closure: () throws ->()) {
        do {
            try closure()
            XCTFail("Did not throw an error",
                    file: file,
                    line: line)
        } catch ValidatorError.FieldInvalid(let fieldName, let message) {
            XCTAssertEqual(fieldName,
                           errorFieldName,
                           file: file,
                           line: line)
            XCTAssertEqual(message,
                           errorMessage,
                           file: file,
                           line: line)
        } catch {
            XCTFail("The wrong error was thrown: \(error)",
                    file: file,
                    line: line)
        }
    }
    
    //MARK: Tests
    
    //MARK: Full Name
    
    func testValidFullName() {
        let validFullName = "Matt Reed"
        
        self.validateThatErrorIsNotThrown {
            try Validator.validateFullName(validFullName)
        }
    }
    
    func testInvalidFullName() {
        let invalidFullNameOneWord = "Matt"
        
        self.validateThatFieldInvalidErrorIsThrown(LocalizedStrings.FullName, errorMessage: LocalizedStrings.FullNameErrorMessage) {
            try Validator.validateFullName(invalidFullNameOneWord)
        }
    }
    
    func testBlankName() {
        self.validateThatFieldBlankErrorThrown(LocalizedStrings.FullName) {
            try Validator.validateFullName(self.emptyString)
        }
        
        self.validateThatFieldBlankErrorThrown(LocalizedStrings.FullName) {
            try Validator.validateFullName(self.blankSpace)
        }
    }
    
    //MARK: Email
    
    func testValidEmail() {
        let validEmail = "matt.reed@spothero.com"
        
        self.validateThatErrorIsNotThrown {
            try Validator.validateEmail(validEmail)
        }
    }

    func testInvalidEmail() {
        let invalidEmailNoTLD = "matt.reed@spothero"
        let invalidUsername = "matt..reed@spothero.com"
        let invalidTLD = "matt.reed@spothero.c"
        let invalidEmailNoUsername = "@spothero.com"
        
        self.validateThatFieldInvalidErrorIsThrown(LocalizedStrings.Email, errorMessage: LocalizedStrings.EmailErrorMessage) { 
            try Validator.validateEmail(invalidEmailNoTLD)
        }
        
        self.validateThatFieldInvalidErrorIsThrown(LocalizedStrings.Email, errorMessage: LocalizedStrings.EmailErrorMessage) {
            try Validator.validateEmail(invalidUsername)
        }
        
        self.validateThatFieldInvalidErrorIsThrown(LocalizedStrings.Email, errorMessage: LocalizedStrings.EmailErrorMessage) {
            try Validator.validateEmail(invalidTLD)
        }
        
        self.validateThatFieldInvalidErrorIsThrown(LocalizedStrings.Email, errorMessage: LocalizedStrings.EmailErrorMessage) {
            try Validator.validateEmail(invalidEmailNoUsername)
        }
    }
    
    func testBlankEmail() {
        self.validateThatFieldBlankErrorThrown(LocalizedStrings.Email) {
            try Validator.validateEmail(self.emptyString)
        }
        
        self.validateThatFieldBlankErrorThrown(LocalizedStrings.Email) {
            try Validator.validateEmail(self.blankSpace)
        }
    }
    
    //MARK: Phone
    
    func testValidPhone() {
        let validPhone = "312-566-7768"
        
        self.validateThatErrorIsNotThrown { 
            try Validator.validatePhone(validPhone)
        }
    }
    
    func testInvalidPhone() {
        let invalidPhoneNotTenDigits = "312-566"
        let invalidPhoneNonNumeric = "232-2d23-2232"
        
        self.validateThatFieldInvalidErrorIsThrown(LocalizedStrings.Phone, errorMessage: LocalizedStrings.PhoneErrorMessage) { 
            try Validator.validatePhone(invalidPhoneNotTenDigits)
        }
        
        self.validateThatFieldInvalidErrorIsThrown(LocalizedStrings.Phone, errorMessage: LocalizedStrings.PhoneErrorMessage) { 
            try Validator.validatePhone(invalidPhoneNonNumeric)
        }
    }
    
    func testBlankPhone() {
        self.validateThatFieldBlankErrorThrown(LocalizedStrings.Phone) { 
            try Validator.validatePhone(self.emptyString)
        }
        
        self.validateThatFieldBlankErrorThrown(LocalizedStrings.Phone) {
            try Validator.validatePhone(self.blankSpace)
        }
    }
    
    //MARK: Credit Card
    //Fake credit cards from http://www.freeformatter.com/credit-card-number-generator-validator.html
    
    func testValidVisa() {
        let validVisa = "4556 6580 0837 9641"
        
        self.validateThatErrorIsNotThrown { 
            let cardType = try Validator.validateCreditCard(validVisa)
            XCTAssertEqual(cardType, CardType.Visa)
        }
    }
    
    func testValidDiscover() {
        let validDiscover = "6011 2313 8733 6725"
        
        self.validateThatErrorIsNotThrown {
            let cardType = try Validator.validateCreditCard(validDiscover)
            XCTAssertEqual(cardType, CardType.Discover)
        }
    }
    
    func testValidMasterCard() {
        let validMasterCard = "5459 4943 0766 9580"
        
        self.validateThatErrorIsNotThrown {
            let cardType = try Validator.validateCreditCard(validMasterCard)
            XCTAssertEqual(cardType, CardType.MasterCard)
        }
    }
    
    func testValidAmex() {
        let validAmex = "3456 318993 86110"
        
        self.validateThatErrorIsNotThrown {
            let cardType = try Validator.validateCreditCard(validAmex)
            XCTAssertEqual(cardType, CardType.Amex)
        }
    }
    
    func testInvalidVisa() {
        let invalidVisa = "4242 42 4242 234"
        
        self.validateThatFieldInvalidErrorIsThrown(LocalizedStrings.CreditCard, errorMessage: LocalizedStrings.CreditCardErrorMessage) { 
            try Validator.validateCreditCard(invalidVisa)
        }
    }
    
    func testInvalidDiscover() {
        let invalidDiscover = "6011 2313 33 6725"
        
        self.validateThatFieldInvalidErrorIsThrown(LocalizedStrings.CreditCard, errorMessage: LocalizedStrings.CreditCardErrorMessage) {
            try Validator.validateCreditCard(invalidDiscover)
        }
    }
    
    func testInvalidMasterCard() {
        let invalidMasterCard = "5459 4943 066 9580"
        
        self.validateThatFieldInvalidErrorIsThrown(LocalizedStrings.CreditCard, errorMessage: LocalizedStrings.CreditCardErrorMessage) {
            try Validator.validateCreditCard(invalidMasterCard)
        }
    }
    
    func testInvalidAMEX() {
        let invalidAMEX = "3456 31893 86110"
        
        self.validateThatFieldInvalidErrorIsThrown(LocalizedStrings.CreditCard, errorMessage: LocalizedStrings.CreditCardErrorMessage) {
            try Validator.validateCreditCard(invalidAMEX)
        }
    }
    
    func testInvalidCreditCard() {
        let invalidCreditCard = "1234 5678 1234 5678"
        
        self.validateThatFieldInvalidErrorIsThrown(LocalizedStrings.CreditCard, errorMessage: LocalizedStrings.NonAcceptedCreditCardErrorMessage) {
            try Validator.validateCreditCard(invalidCreditCard)
        }
    }
    
    func testBlankCreditCard() {
        self.validateThatFieldBlankErrorThrown(LocalizedStrings.CreditCard) { 
            try Validator.validateCreditCard(self.emptyString)
        }
        
        self.validateThatFieldBlankErrorThrown(LocalizedStrings.CreditCard) {
            try Validator.validateCreditCard(self.blankSpace)
        }
    }
    
    //MARK: Expiration Date
    
    func testValidExpirationDate() {
        let date = NSDate()
        let calendar = NSCalendar(calendarIdentifier: NSCalendarIdentifierGregorian)
        
        if let dateComponents = calendar?.components([.Month, .Year], fromDate: date) {
            let month = String(dateComponents.month)
            let year = String(dateComponents.year + 1)
            
            self.validateThatErrorIsNotThrown {
                try Validator.validateExpiration(month, year: year)
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
            
            self.validateThatFieldInvalidErrorIsThrown(LocalizedStrings.ExpirationDate, errorMessage: LocalizedStrings.DateInThePastErrorMessage) {
                if month == "12" {
                    try Validator.validateExpiration(pastMonth, year: pastYear)
                } else {
                    try Validator.validateExpiration(pastMonth, year: year)
                }
            }
            
            self.validateThatFieldInvalidErrorIsThrown(LocalizedStrings.ExpirationDate, errorMessage: LocalizedStrings.DateInThePastErrorMessage) {
                try Validator.validateExpiration(month, year: pastYear)
            }
            
            self.validateThatFieldInvalidErrorIsThrown(LocalizedStrings.ExpirationDate, errorMessage: LocalizedStrings.InvalidDateErrorMessage) {
                try Validator.validateExpiration(month, year: invalidYear)
            }
            
            self.validateThatFieldInvalidErrorIsThrown(LocalizedStrings.ExpirationDate, errorMessage: LocalizedStrings.InvalidDateErrorMessage) {
                try Validator.validateExpiration(invalidMonth, year: year)
            }
        } else {
            XCTFail("Cannot get date")
        }
    }
    
    func testBlankExpirationDate() {
        self.validateThatFieldBlankErrorThrown(LocalizedStrings.ExpirationDate) { 
            try Validator.validateExpiration(self.emptyString, year: self.emptyString)
        }
        
        self.validateThatFieldBlankErrorThrown(LocalizedStrings.ExpirationDate) {
            try Validator.validateExpiration(self.blankSpace, year: self.blankSpace)
        }
    }
    
    //MARK: CVC
    
    func testValidCVC() {
        let validCVCNonAmex = "123"
        let validCVCAmex = "1234"
        
        self.validateThatErrorIsNotThrown { 
            try Validator.validateCVC(validCVCNonAmex)
        }
        
        self.validateThatErrorIsNotThrown { 
            try Validator.validateCVC(validCVCAmex, amex: true)
        }
    }
    
    func testInvalidCVC() {
        let invalidCVC = "12"
        let invalidCVCAmex = "123"
        let invalidCVCNonAmex = "1234"
        
        self.validateThatFieldInvalidErrorIsThrown(LocalizedStrings.CVC, errorMessage: LocalizedStrings.CVCErrorMessage) { 
            try Validator.validateCVC(invalidCVC)
        }
        
        self.validateThatFieldInvalidErrorIsThrown(LocalizedStrings.CVC, errorMessage: LocalizedStrings.CVCErrorMessage) {
            try Validator.validateCVC(invalidCVCNonAmex)
        }
        
        self.validateThatFieldInvalidErrorIsThrown(LocalizedStrings.CVC, errorMessage: LocalizedStrings.CVCErrorMessage) {
            try Validator.validateCVC(invalidCVC, amex: true)
        }
        
        self.validateThatFieldInvalidErrorIsThrown(LocalizedStrings.CVC, errorMessage: LocalizedStrings.CVCErrorMessage) {
            try Validator.validateCVC(invalidCVCAmex, amex: true)
        }
        
        self.validateThatErrorIsNotThrown { 
            try Validator.validateCVC(invalidCVCAmex)
        }
        
        self.validateThatErrorIsNotThrown { 
            try Validator.validateCVC(invalidCVCNonAmex, amex: true)
        }
    }
    
    func testBlankCVC() {
        self.validateThatFieldBlankErrorThrown(LocalizedStrings.CVC) {
            try Validator.validateCVC(self.emptyString)
        }
        
        self.validateThatFieldBlankErrorThrown(LocalizedStrings.CVC) {
            try Validator.validateCVC(self.blankSpace)
        }
    }
    
    //MARK: Zip Code
    
    func testValidZip() {
        let zip = "60601"
        
        self.validateThatErrorIsNotThrown { 
            try Validator.validateZip(zip)
        }
    }
    
    func testInvalidZip() {
        let zipWrongLength = "6061"
        let zipNonNumeric = "353m3"
        
        self.validateThatFieldInvalidErrorIsThrown(LocalizedStrings.ZipCode, errorMessage: LocalizedStrings.ZipErrorMessage) { 
            try Validator.validateZip(zipWrongLength)
        }
        
        self.validateThatFieldInvalidErrorIsThrown(LocalizedStrings.ZipCode, errorMessage: LocalizedStrings.ZipErrorMessage) { 
            try Validator.validateZip(zipNonNumeric)
        }
    }
    
    func testBlankZip() {
        self.validateThatFieldBlankErrorThrown(LocalizedStrings.ZipCode) { 
            try Validator.validateZip(self.emptyString)
        }
        
        self.validateThatFieldBlankErrorThrown(LocalizedStrings.ZipCode) { 
            try Validator.validateZip(self.blankSpace)
        }
    }
}
