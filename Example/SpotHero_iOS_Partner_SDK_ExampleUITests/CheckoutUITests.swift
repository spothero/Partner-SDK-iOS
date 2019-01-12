//
//  CheckoutUITests.swift
//  SpotHero_iOS_Partner_SDK
//
//  Created by SpotHeroMatt on 10/20/16.
//  Copyright © 2016 SpotHero, Inc. All rights reserved.
//

import KIF
@testable import SpotHero_iOS_Partner_SDK
@testable import SpotHero_iOS_Partner_SDK_Example
import XCTest

class CheckoutUITests: BaseUITests {
    let firstIndexPath = IndexPath(item: 0, section: 0)
    let enteredText = "Chicago"
    let expectedText = "Chicago, IL, United States"
    let visaCreditCard = "4242424242424242"
    let CVC = "123"
    let amExCreditCard = "345631899386110"
    let discoverCreditCard = "6011111111111117"
    let masterCardCreditCard = "5555555555554444"
    let amExCVC = "1234"
    let testEmail = "matt@test.com"
    let testExpiration = "1020"
    let emailOnlyAddress = "318 South Federal"
    let emailandPhoneOnlyAddress = "100 West Monroe"
    let emailAndLicenseOnlyAddress = "328 South Wabash"
    let emailPhoneAndLicenseAddress = "525 South Wabash"
    let visaCardType = "Visa"
    let amExCardType = "AExp"
    let discoverCardType = "Discover"
    let masterCardCardType = "Mastercard"
    let buttonTitle = "Payment Button"
    
    //MARK: - Helper Methods
    
    private func enterTextInFields(email: String,
                                   creditCardNumber: String,
                                   expiration: String? = nil,
                                   cvc: String? = nil,
                                   expectedCreditCard: String? = nil) {
        
        let lastFour = creditCardNumber[creditCardNumber.index(creditCardNumber.endIndex, offsetBy: -4)..<creditCardNumber.endIndex]
        let expectedCC = expectedCreditCard ?? String(lastFour)
        
        tester().enterText(email, intoViewWithAccessibilityLabel: LocalizedStrings.EmailAddressPlaceHolder)
        tester().enterText(creditCardNumber,
                           intoViewWithAccessibilityLabel: LocalizedStrings.CreditCardPlaceHolder,
                           traits: .none,
                           expectedResult: expectedCC)
        if let expiration = expiration {
            var expectedExpiration = expiration
            expectedExpiration.insert("/", at: expectedExpiration.index(expectedExpiration.startIndex, offsetBy: 2))
            tester().enterText(expiration,
                               intoViewWithAccessibilityLabel: LocalizedStrings.ExpirationDatePlaceHolder,
                               traits: .none,
                               expectedResult: expectedExpiration)
        }
        
        if let cvc = cvc {
            tester().enterText(cvc, intoViewWithAccessibilityLabel: LocalizedStrings.CVCPlaceHolder)
        }
    }
    
    private func purchaseSpot(creditCardNumber: String,
                              cvc: String,
                              cardType: String) {
        self.enterTextInFields(email: self.testEmail,
                               creditCardNumber: creditCardNumber,
                               expiration: self.testExpiration,
                               cvc: cvc)
        
        guard
            let cardImageView = tester().waitForView(withAccessibilityLabel: AccessibilityStrings.CardImage) as? UIImageView,
            let cardImage = cardImageView.image,
            let testImage = UIImage(shp_named: cardType) else {
                XCTFail("Cannot get card image")
                return
        }
        
        let cardImageData = cardImage.pngData()
        let cardData = testImage.pngData()
        
        XCTAssertEqual(cardImageData, cardData)
        
        guard let button = tester().waitForView(withAccessibilityLabel: self.buttonTitle) as? UIButton else {
            XCTFail("Cannot get payment button")
            return
        }
        
        XCTAssert(button.isEnabled)
        
        tester().tapView(withAccessibilityLabel: self.buttonTitle)
        
        tester().waitForView(withAccessibilityLabel: LocalizedStrings.BookAnother)
    }
        
    private func goToCheckoutScreen(searchBarText: String? = nil) {
        // Enter text into search bar and press return
        let text = searchBarText ?? self.enteredText
        self.enterTextIntoSearchBar(text, expectedText: text)
        
        guard let predictionTableView = tester().waitForView(withAccessibilityLabel: AccessibilityStrings.PredictionTableView) as? UITableView else {
            XCTFail("Cannot get predictions")
            return
        }
        
        tester().tapRow(at: IndexPath(row: 0, section: 0), in: predictionTableView)
        tester().tapView(withAccessibilityLabel: LocalizedStrings.SearchSpots)
        
        // Get collection view and tap book it button
        guard
            let collectionView = tester().waitForView(withAccessibilityLabel: AccessibilityStrings.SpotCards) as? UICollectionView else {
                XCTFail("Cannot get spot cards collection view")
                return
        }
        
        tester().waitForCell(at: firstIndexPath, in: collectionView)
        tester().tapView(withAccessibilityLabel: LocalizedStrings.BookSpot)
        tester().waitForView(withAccessibilityLabel: AccessibilityStrings.CheckoutScreen)
    }
    
    private func verifyPaymentButtonDisabled(file: StaticString = #file, line: UInt = #line) {
        guard let paymentButton = tester().waitForView(withAccessibilityLabel: self.buttonTitle) as? UIButton else {
            XCTFail("Cannot get payment button")
            return
        }
        
        XCTAssertFalse(paymentButton.isEnabled,
                       file: file,
                       line: line)
    }
    
    //MARK: - Test Lifecycle
    
    override func tearDown() {
        tester().tapView(withAccessibilityLabel: LocalizedStrings.Close)
        tester().tapView(withAccessibilityLabel: LocalizedStrings.PresentSDK)
        super.tearDown()
    }
    
    //MARK: - Test Methods
    
    func skip_testBuySpotVisa() {
        //GIVEN: I see the Checkout Table View
        self.goToCheckoutScreen()
        //WHEN: I enter an email, credit card number, expiration number and cvc
        //THEN: I see the confirmation screen
        self.purchaseSpot(creditCardNumber: self.visaCreditCard,
                          cvc: self.CVC,
                          cardType: self.visaCardType)
    }
    
    func skip_testBuySpotAmEx() {
        //GIVEN: I see the Checkout Table View
        self.goToCheckoutScreen()
        //WHEN: I enter an email, american express credit card number, expiration number and cvc
        //THEN: I should see the confirmation screen
        self.purchaseSpot(creditCardNumber: self.amExCreditCard,
                          cvc: self.amExCVC,
                          cardType: self.amExCardType)
    }
    
    func skip_testBuySpotDiscover() {
        //GIVEN: I see the Checkout Table View
        self.goToCheckoutScreen()
        //WHEN: I enter an email, american express credit card number, expiration number and cvc
        //THEN: I should see the confirmation screen
        self.purchaseSpot(creditCardNumber: self.discoverCreditCard,
                          cvc: self.CVC,
                          cardType: self.discoverCardType)
    }
    
    func skip_testBuySpotMasterCard() {
        //GIVEN: I see the Checkout Table View
        self.goToCheckoutScreen()
        //WHEN: I enter an email, american express credit card number, expiration number and cvc
        //THEN: I should see the confirmation screen
        self.purchaseSpot(creditCardNumber: self.masterCardCreditCard,
                          cvc: self.CVC,
                          cardType: self.masterCardCardType)
    }
    
    func skip_testBookAnotherButton() {
        //GIVEN: I see the confimation screen
        self.goToCheckoutScreen()
        self.purchaseSpot(creditCardNumber: self.visaCreditCard,
                          cvc: self.CVC,
                          cardType: self.visaCardType)
        
        //WHEN: I tap the Book Another button
        tester().waitForView(withAccessibilityLabel: LocalizedStrings.BookAnother)
        tester().tapView(withAccessibilityLabel: LocalizedStrings.BookAnother)
        
        //THEN: I should see the Map View
        tester().waitForView(withAccessibilityLabel: AccessibilityStrings.MapView)
    }
    
    func skip_testDoneButton() {
        //GIVEN: I see the confimation screen
        self.goToCheckoutScreen()
        self.purchaseSpot(creditCardNumber: self.visaCreditCard,
                          cvc: self.CVC,
                          cardType: self.visaCardType)
        
        //WHEN: I tap the Book Another button
        tester().waitForView(withAccessibilityLabel: LocalizedStrings.Done)
        tester().tapView(withAccessibilityLabel: LocalizedStrings.Done)
        
        //THEN: The view should dismiss
        tester().waitForView(withAccessibilityLabel: LocalizedStrings.PresentSDK)
        
        // Relaunch SDK
        tester().tapView(withAccessibilityLabel: LocalizedStrings.PresentSDK)
    }
    
    func skip_testInvalidEmail() {
        //GIVEN: I see the checkout screen
        self.goToCheckoutScreen()
        //WHEN: I enter an invalid email and valid credit card, expiration date and cvc
        self.enterTextInFields(email: "matt@test",
                               creditCardNumber: self.visaCreditCard,
                               expiration: self.testExpiration,
                               cvc: self.CVC)
        
        //THEN: The payment button should be disabled
        self.verifyPaymentButtonDisabled()
    }
    
    func skip_testInvalidCreditCardNumber() {
        //GIVEN: I see the checkout screen
        self.goToCheckoutScreen()
        //WHEN: I enter an invalid credit card number
        self.enterTextInFields(email: self.testEmail,
                               creditCardNumber: "1234567812345678",
                               expectedCreditCard: "1234 5678 1234 5678")
        
        //THEN: The payment button should be disabled
        self.verifyPaymentButtonDisabled()
    }
    
    func skip_testInvalidExpiration() {
        //GIVEN: I see the checkout screen
        self.goToCheckoutScreen()
        //WHEN: I enter an invalid expiration date
        self.enterTextInFields(email: self.testEmail,
                               creditCardNumber: self.visaCreditCard,
                               expiration: "1013",
                               cvc: self.CVC)
        
        //THEN: The payment button should be disabled
        self.verifyPaymentButtonDisabled()
    }
    
    func skip_testEmptyCreditCard() {
        //GIVEN: I see the checkout screen
        self.goToCheckoutScreen()
        //WHEN: I fill out all the fields except the credit card fields
        tester().enterText(self.testEmail, intoViewWithAccessibilityLabel: LocalizedStrings.EmailAddressPlaceHolder)
        
        //THEN: The payment button should be disabled
        self.verifyPaymentButtonDisabled()
    }
    
    func skip_testEmptyExpirationDate() {
        //GIVEN: I see the checkout screen
        self.goToCheckoutScreen()
        //WHEN: I fill out all the fields except the expiration date
        self.enterTextInFields(email: self.testEmail,
                               creditCardNumber: self.visaCreditCard,
                               expiration: nil,
                               cvc: self.CVC)
        //THEN: The payment button should be disabled
        self.verifyPaymentButtonDisabled()
    }
    
    func skip_testEmptyCVC() {
        //GIVEN: I see the checkout screen
        self.goToCheckoutScreen()
        //WHEN: I fill out all the fields except the cvc
        tester().tapView(withAccessibilityLabel: LocalizedStrings.CreditCardPlaceHolder)
        self.enterTextInFields(email: self.testEmail,
                               creditCardNumber: self.visaCreditCard,
                               expiration: self.testExpiration,
                               cvc: nil)
        tester().tapView(withAccessibilityLabel: LocalizedStrings.Done)
        //THEN: The payment button should be disabled
        self.verifyPaymentButtonDisabled()
    }
    
    func skip_testEmptyExpirationDateAndCVC() {
        //GIVEN: I see the checkout screen
        self.goToCheckoutScreen()
        //WHEN: I fill out all the fields except the expiration date and cvc
        tester().tapView(withAccessibilityLabel: LocalizedStrings.CreditCardPlaceHolder)
        self.enterTextInFields(email: self.testEmail, creditCardNumber: self.visaCreditCard)
        tester().tapView(withAccessibilityLabel: LocalizedStrings.Done)
        //THEN: The payment button should be disabled
        self.verifyPaymentButtonDisabled()
    }
    
    func skip_testEmailOnlyCheckout() {
        //GIVEN: I select a spot that only required an email address
        //WHEN: I see the checkout screen
        self.goToCheckoutScreen(searchBarText: self.emailOnlyAddress)
        //THEN: I should only see the email field
        tester().waitForView(withAccessibilityLabel: LocalizedStrings.EmailAddressPlaceHolder)
        tester().waitForAbsenceOfView(withAccessibilityLabel: LocalizedStrings.PhoneNumberPlaceHolder)
        tester().waitForAbsenceOfView(withAccessibilityLabel: LocalizedStrings.LicensePlatePlaceHolder)
    }
    
    func skip_testEmailandPhoneOnlyCheckout() {
        //GIVEN: I select a spot that only required an email address
        //WHEN: I see the checkout screen
        self.goToCheckoutScreen(searchBarText: self.emailandPhoneOnlyAddress)
        //THEN: I should only see the email and phone fields
        tester().waitForView(withAccessibilityLabel: LocalizedStrings.EmailAddressPlaceHolder)
        tester().waitForView(withAccessibilityLabel: LocalizedStrings.PhoneNumberPlaceHolder)
        tester().waitForAbsenceOfView(withAccessibilityLabel: LocalizedStrings.LicensePlatePlaceHolder)
    }
    
    func skip_testEmailAndLicenseOnlyCheckout() {
        //GIVEN: I select a spot that only required an email address
        //WHEN: I see the checkout screen
        self.goToCheckoutScreen(searchBarText: self.emailAndLicenseOnlyAddress)
        //THEN: I should only see the email and license fields
        tester().waitForView(withAccessibilityLabel: LocalizedStrings.EmailAddressPlaceHolder)
        tester().waitForAbsenceOfView(withAccessibilityLabel: LocalizedStrings.PhoneNumberPlaceHolder)
        tester().waitForView(withAccessibilityLabel: LocalizedStrings.LicensePlatePlaceHolder)
    }
    
    func skip_testEmailPhoneAndLicenseCheckout() {
        //GIVEN: I select a spot that only required an email address
        //WHEN: I see the checkout screen
        self.goToCheckoutScreen(searchBarText: self.emailPhoneAndLicenseAddress)
        //THEN: I should see the email, phone and license fields
        tester().waitForView(withAccessibilityLabel: LocalizedStrings.EmailAddressPlaceHolder)
        tester().waitForView(withAccessibilityLabel: LocalizedStrings.PhoneNumberPlaceHolder)
        tester().waitForView(withAccessibilityLabel: LocalizedStrings.LicensePlatePlaceHolder)
    }
}
