//
//  ValidatorTests.swift
//  SpotHero_iOS_Partner_SDK
//
//  Created by SpotHeroMatt on 7/29/16.
//  Copyright © 2016 SpotHero, Inc. All rights reserved.
//

@testable import SpotHero_iOS_Partner_SDK
import XCTest

class ValidatorTests: XCTestCase {
    private let emptyString = ""
    private let blankSpace = " "
    
    // MARK: Helpers
    
    fileprivate func validateThatErrorIsNotThrown(_ file: StaticString = #file,
                                                  line: UInt = #line,
                                                  closure: () throws -> Void) {
        do {
            try closure()
            XCTAssert(true,
                      "Did not throw an error",
                      file: file,
                      line: line)
        } catch {
            XCTFail("Validator threw an error: \(error)",
                    file: file,
                    line: line)
        }
    }
    
    fileprivate func validateThatFieldBlankErrorThrown(_ errorFieldName: String,
                                                       file: StaticString = #file,
                                                       line: UInt = #line,
                                                       closure: () throws -> Void) {
        do {
            try closure()
            XCTFail("Did not throw an error",
                    file: file,
                    line: line)
        } catch ValidatorError.fieldBlank(let fieldName) {
            XCTAssertEqual(fieldName,
                           errorFieldName,
                           file: file,
                           line: line)
        } catch {
            XCTFail("The wrong error was thrown: \(error)",
                    file: file,
                    line: line)
        }
    }
    
    fileprivate func validateThatFieldInvalidErrorIsThrown(_ errorFieldName: String,
                                                           errorMessage: String,
                                                           file: StaticString = #file,
                                                           line: UInt = #line,
                                                           closure: () throws -> Void) {
        do {
            try closure()
            XCTFail("Did not throw an error",
                    file: file,
                    line: line)
        } catch ValidatorError.fieldInvalid(let fieldName, let message) {
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
    
    // MARK: Tests
    
    // MARK: Email
    
    func testNilEmail() {
        self.validateThatFieldBlankErrorThrown(LocalizedStrings.Email) {
            try Validator.validateEmail(nil)
        }
    }
    
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
    
    // MARK: Credit Card
    // Fake credit cards from http://www.freeformatter.com/credit-card-number-generator-validator.html
    
    func testValidVisa() {
        let validVisa = "4556 6580 0837 9641"
        
        self.validateThatErrorIsNotThrown {
            let cardType = Validator.getCardType(validVisa)
            try Validator.validateCreditCard(validVisa)
            XCTAssertEqual(cardType, CardType.visa)
        }
    }
    
    func testValidDiscover() {
        let validDiscover = "6011 2313 8733 6725"
        
        self.validateThatErrorIsNotThrown {
            let cardType = Validator.getCardType(validDiscover)
            try Validator.validateCreditCard(validDiscover)
            XCTAssertEqual(cardType, CardType.discover)
        }
    }
    
    func testValidMasterCard() {
        let validMasterCard = "5459 4943 0766 9580"
        
        self.validateThatErrorIsNotThrown {
            let cardType = Validator.getCardType(validMasterCard)
            try Validator.validateCreditCard(validMasterCard)
            XCTAssertEqual(cardType, CardType.masterCard)
        }
    }
    
    func testValidAmex() {
        let validAmex = "3456 318993 86110"
        
        self.validateThatErrorIsNotThrown {
            let cardType = Validator.getCardType(validAmex)
            try Validator.validateCreditCard(validAmex)
            XCTAssertEqual(cardType, CardType.amex)
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
        self.validateThatFieldInvalidErrorIsThrown(LocalizedStrings.CreditCard, errorMessage: LocalizedStrings.NonAcceptedCreditCardErrorMessage) {
            try Validator.validateCreditCard(self.emptyString)
        }
        
        self.validateThatFieldInvalidErrorIsThrown(LocalizedStrings.CreditCard, errorMessage: LocalizedStrings.NonAcceptedCreditCardErrorMessage) {
            try Validator.validateCreditCard(self.blankSpace)
        }
    }
    
    // MARK: Expiration Date
    
    func testValidExpirationDate() {
        let date = Date()
        let calendar = Calendar(identifier: Calendar.Identifier.gregorian)
        
        let dateComponents = calendar.dateComponents([.month, .year], from: date)
        if
            let month = dateComponents.month,
            let year = dateComponents.year {
                let monthString = String(month)
                let yearString = String(year + 1)
                
                self.validateThatErrorIsNotThrown {
                    try Validator.validateExpiration(monthString, year: yearString)
                }
        } else {
            XCTFail("Cannot get date")
        }
    }
    
    func testInvalidExpirationDate() {
        let date = Date()
        let calendar = Calendar(identifier: Calendar.Identifier.gregorian)
        
        let dateComponents = calendar.dateComponents([.month, .year], from: date)
        if
            let month = dateComponents.month,
            let year = dateComponents.year {
                let monthString = String(month)
                let yearString = String(year)
                
                let pastMonth: String
                if dateComponents.month == 1 {
                    pastMonth = "12"
                } else {
                    pastMonth = String(month - 1)
                }
                
                let pastYear = String(year - 1)
                let invalidMonth = "14"
                let invalidYear = "200e3"
                
                self.validateThatFieldInvalidErrorIsThrown(LocalizedStrings.ExpirationDate,
                                                           errorMessage: LocalizedStrings.DateInThePastErrorMessage) {
                    if month == 1 {
                        try Validator.validateExpiration(pastMonth, year: pastYear)
                    } else {
                        try Validator.validateExpiration(pastMonth, year: yearString)
                    }
                }
                
                self.validateThatFieldInvalidErrorIsThrown(LocalizedStrings.ExpirationDate,
                                                           errorMessage: LocalizedStrings.DateInThePastErrorMessage) {
                    try Validator.validateExpiration(monthString, year: pastYear)
                }
                
                self.validateThatFieldInvalidErrorIsThrown(LocalizedStrings.ExpirationDate, errorMessage: LocalizedStrings.InvalidDateErrorMessage) {
                    try Validator.validateExpiration(monthString, year: invalidYear)
                }
                
                self.validateThatFieldInvalidErrorIsThrown(LocalizedStrings.ExpirationDate, errorMessage: LocalizedStrings.InvalidDateErrorMessage) {
                    try Validator.validateExpiration(invalidMonth, year: yearString)
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
    
    // MARK: CVC
    
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
}
