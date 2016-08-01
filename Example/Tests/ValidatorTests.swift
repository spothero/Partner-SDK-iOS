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
            XCTAssertEqual(fieldName, "Full Name")
            XCTAssertEqual(message, "Full Name must have at least 2 words")
        } catch {
            XCTFail("Validator did threw the wrong error")
        }
    }
    
    func testBlankName() {
        let blankName = ""
        do {
            try Validator.validateFullName(blankName)
            XCTFail("Did not throw error")
        } catch ValidatorError.FieldBlank(let fieldName) {
            XCTAssertEqual(fieldName, "Full Name")
        } catch {
            XCTFail("Validator did threw the wrong error")
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
        let invalidEmail = "matt.reed@spothero"
        do {
            try Validator.validateEmail(invalidEmail)
            XCTFail("Did not throw error")
        } catch ValidatorError.FieldInvalid(let fieldName, let message) {
            XCTAssertEqual(fieldName, "Email")
            XCTAssertEqual(message, "Please enter a valid email")
        } catch {
            XCTFail("Validator did threw the wrong error")
        }
    }
    
    func testBlankEmail() {
        let blankEmail = ""
        do {
            try Validator.validateEmail(blankEmail)
            XCTFail("Did not throw error")
        } catch ValidatorError.FieldBlank(let fieldName) {
            XCTAssertEqual(fieldName, "Email")
        } catch {
            XCTFail("Validator did threw the wrong error")
        }
    }
    
    func testValidPhone() {
        let validPhone = "312-566-7768"
    }
    
    func testInvalidPhone() {
        let invalidPhone = "312-566"
    }
    
    func testValidCreditCard() {
        let validCreditCard = "4242 4242 4242 4242"
    }
    
    func testInvalidCreditCard() {
        let invalidCreditCard = "4242 42 4242 234"
    }
    
    func testValidCreditCardAMEX() {
        let validCreditCardAMEX = "4242 424242 42424"
    }
    
    func testInvalidCreditCardAMEX() {
        let invalidCreditCardAMEX = "4242 424242 234"
    }
    
    func testValidExpirationDate() {
        
    }
    
    func testInvalidExpirationDate() {
        
    }
}
