//
//  CheckoutUITests.swift
//  SpotHero_iOS_Partner_SDK
//
//  Created by SpotHeroMatt on 10/20/16.
//  Copyright © 2016 SpotHero, Inc. All rights reserved.
//

import XCTest
import KIF
@testable import SpotHero_iOS_Partner_SDK_Example
@testable import SpotHero_iOS_Partner_SDK

class CheckoutUITests: BaseUITests {
    let emailIndexPath = NSIndexPath(forRow: PersonalInfoRow.Email.rawValue, inSection: CheckoutSection.PersonalInfo.rawValue)
    let phoneNumberIndexPath = NSIndexPath(forRow: PersonalInfoRow.Phone.rawValue, inSection: CheckoutSection.PersonalInfo.rawValue)
    let licenseIndexPath = NSIndexPath(forRow: PersonalInfoRow.License.rawValue, inSection: CheckoutSection.PersonalInfo.rawValue)
    let firstIndexPath = NSIndexPath(forItem: 0, inSection: 0)
    let enteredText = "Chicago\n"
    let expectedText = "Chicago, IL, United States"
    let visaCreditCard = "4242424242424242"
    let visaCVC = "123"
    let amExCreditCard = "345631899386110"
    let amExCVC = "1234"
    let testEmail = "matt@test.com"
    let testExpiration = "1020"
    
    func cancelReservation() {
        let expectation = self.expectationWithDescription("Reservation Cancelled")
        
        ReservationAPI.cancelLastReservation { (success) in
            XCTAssert(success, "Could not cancel last reservation")
            expectation.fulfill()
        }
        
        self.waitForExpectationsWithTimeout(10, handler: nil)
    }
    
    func enterTextInFields(email: String,
                           creditCardNumber: String,
                           expiration: String? = nil,
                           cvc: String? = nil,
                           expectedCreditCard: String? = nil) {
        
        let expectedCC = expectedCreditCard ??
            creditCardNumber.substringWithRange(creditCardNumber.endIndex.advancedBy(-4)..<creditCardNumber.endIndex)
        
        tester().enterText(email, intoViewWithAccessibilityLabel: AccessibilityStrings.EmailTextField)
        tester().enterText(creditCardNumber,
                           intoViewWithAccessibilityLabel: AccessibilityStrings.CreditCardTextField,
                           traits: UIAccessibilityTraitNone,
                           expectedResult: expectedCC)
        if let expiration = expiration {
            var expectedExpiration = expiration
            expectedExpiration.insert("/", atIndex: expectedExpiration.startIndex.advancedBy(2))
            tester().enterText(expiration,
                               intoViewWithAccessibilityLabel: AccessibilityStrings.ExpirationTextField,
                               traits: UIAccessibilityTraitNone,
                               expectedResult: expectedExpiration)

        }
        
        if let cvc = cvc {
            tester().enterText(cvc, intoViewWithAccessibilityLabel: AccessibilityStrings.CVCTextField)
        }
    }
    
    func purchaseSpot(creditCardNumber: String, cvc: String) {
        self.enterTextInFields(self.testEmail,
                               creditCardNumber: creditCardNumber,
                               expiration: self.testExpiration,
                               cvc: cvc)
        
        guard let button = tester().waitForViewWithAccessibilityLabel(AccessibilityStrings.PaymentButton) as? UIButton else {
            XCTFail("Cannot get payment button")
            return
        }
        
        XCTAssert(button.enabled)
        
        tester().tapViewWithAccessibilityLabel(AccessibilityStrings.PaymentButton)
        
        tester().waitForViewWithAccessibilityLabel(AccessibilityStrings.ConfirmationScreen)
        self.cancelReservation()
    }
        
    override func setUp() {
        super.setUp()
        
        // Enter text into search bar and press return
        self.enterTextIntoSearchBar(enteredText, expectedText: expectedText)
        
        // Get collection view and tap book it button
        guard
            let collectionView = tester().waitForViewWithAccessibilityLabel(AccessibilityStrings.SpotCards) as? UICollectionView else {
            XCTFail("Cannot get spot cards collection view")
            return
        }
        
        tester().waitForCellAtIndexPath(firstIndexPath, inCollectionView: collectionView)
        tester().tapViewWithAccessibilityLabel(LocalizedStrings.BookIt)
    }
    
    override func tearDown() {
        tester().tapViewWithAccessibilityLabel(LocalizedStrings.Close)
        tester().tapViewWithAccessibilityLabel(LocalizedStrings.LaunchSDK)
        super.tearDown()
    }
    
    func testBuySpot() {
        //GIVEN: I see the Checkout Table View
        //WHEN: I enter an email, credit card number, expiration number and cvc
        //THEN: I see the confirmation screen
        self.purchaseSpot(self.visaCreditCard, cvc: self.visaCVC)
    }
    
    func testBuySpotAmEx() {
        //GIVEN: I see the Checkout Table View
        //WHEN: I enter an email, american express credit card number, expiration number and cvc
        //THEN: I should see the confirmation screen
        self.purchaseSpot(self.amExCreditCard, cvc: self.amExCVC)
    }
    
    func testBookAnotherButton() {
        //GIVEN: I see the confimation screen
        self.purchaseSpot(self.visaCreditCard, cvc: self.visaCVC)
        
        //WHEN: I tap the Book Another button
        tester().waitForViewWithAccessibilityLabel(LocalizedStrings.BookAnother)
        tester().tapViewWithAccessibilityLabel(LocalizedStrings.BookAnother)
        
        //THEN: I should see the Map View
        tester().waitForViewWithAccessibilityLabel(AccessibilityStrings.MapView)
    }
    
    func testDoneButton() {
        //GIVEN: I see the confimation screen
        self.purchaseSpot(self.visaCreditCard, cvc: self.visaCVC)
        
        //WHEN: I tap the Book Another button
        tester().waitForViewWithAccessibilityLabel(LocalizedStrings.Done)
        tester().tapViewWithAccessibilityLabel(LocalizedStrings.Done)
        
        //THEN: The view should dismiss
        tester().waitForViewWithAccessibilityLabel(LocalizedStrings.LaunchSDK)
        
        // Relaunch SDK
        tester().tapViewWithAccessibilityLabel(LocalizedStrings.LaunchSDK)
    }
    
    func testInvalidEmail() {
        //GIVEN: I see the checkout screen
        //WHEN: I enter an invalid email and valid
        self.enterTextInFields("matt@test",
                               creditCardNumber: self.visaCreditCard,
                               expiration: self.testExpiration,
                               cvc: self.visaCVC)
        
        //THEN: The payment button should be disabled
        if let paymentButton = tester().waitForViewWithAccessibilityLabel(AccessibilityStrings.PaymentButton) as? UIButton {
            XCTAssertFalse(paymentButton.enabled)
        } else {
            XCTFail("Cannot get payment button")
        }
    }
    
    func testInvalidCreditCardNumber() {
        //GIVEN: I see the checkout screen
        //WHEN: I enter an invalid credit card number
        self.enterTextInFields(self.testEmail,
                               creditCardNumber: "1234567812345678",
                               expectedCreditCard: "1234 5678 1234 5678")
        
        //THEN: The payment button should be disabled
        if let paymentButton = tester().waitForViewWithAccessibilityLabel(AccessibilityStrings.PaymentButton) as? UIButton {
            XCTAssertFalse(paymentButton.enabled)
        } else {
            XCTFail("Cannot get payment button")
        }
    }
    
    func testInvalidExpiration() {
        //GIVEN: I see the checkout screen
        //WHEN: I enter an invalid credit card number
        self.enterTextInFields(self.testEmail,
                               creditCardNumber: self.visaCreditCard,
                               expiration: "1013",
                               cvc: self.visaCVC)
        
        //THEN: The payment button should be disabled
        if let paymentButton = tester().waitForViewWithAccessibilityLabel(AccessibilityStrings.PaymentButton) as? UIButton {
            XCTAssertFalse(paymentButton.enabled)
        } else {
            XCTFail("Cannot get payment button")
        }
    }
}
