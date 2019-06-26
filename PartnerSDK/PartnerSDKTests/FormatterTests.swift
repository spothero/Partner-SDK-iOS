//
//  FormatterTests.swift
//  SpotHero_iOS_Partner_SDK
//
//  Created by SpotHeroMatt on 8/8/16.
//  Copyright © 2016 SpotHero, Inc. All rights reserved.
//

@testable import SpotHero_iOS_Partner_SDK
import XCTest

class FormatterTests: XCTestCase {

    func testFormatPhoneNumber() {
        let fullPhoneNumber = "3125667768"
        let partialPhoneNumber = "312566"
        let areaCode = "312"
        
        let formattedFullNumber = Formatter.formatPhoneNumber(fullPhoneNumber)
        let formattedPartialNumber = Formatter.formatPhoneNumber(partialPhoneNumber)
        let formattedAreaCode = Formatter.formatPhoneNumber(areaCode)
        
        XCTAssertEqual(formattedFullNumber.formatted, "312-566-7768")
        XCTAssertEqual(formattedPartialNumber.formatted, "312-566")
        XCTAssertEqual(formattedAreaCode.formatted, areaCode)
    }

    func testFormatCreditCard() {
        let fullCreditCard = "4245355645544354"
        let partialCreditCard = "42424242424"
        let firstFour = "4242"
        
        let formattedFullCreditCard = Formatter.formatCreditCard(fullCreditCard)
        let formattedPartialCreditCard = Formatter.formatCreditCard(partialCreditCard)
        let formattedFirstFour = Formatter.formatCreditCard(firstFour)
        
        XCTAssertEqual(formattedFullCreditCard.formatted, "4245 3556 4554 4354")
        XCTAssertEqual(formattedPartialCreditCard.formatted, "4242 4242 424")
        XCTAssertEqual(formattedFirstFour.formatted, firstFour)
    }
    
    func testFormatCreditCardAmex() {
        let fullCreditCard = "345631899386110"
        let partialCreditCard = "345631899"
        let firstFour = "3456"
        
        let formattedFullCreditCard = Formatter.formatCreditCardAmex(fullCreditCard)
        let formattedPartialCreditCard = Formatter.formatCreditCardAmex(partialCreditCard)
        let formattedFirstFour = Formatter.formatCreditCardAmex(firstFour)
        
        XCTAssertEqual(formattedFullCreditCard.formatted, "3456 318993 86110")
        XCTAssertEqual(formattedPartialCreditCard.formatted, "3456 31899")
        XCTAssertEqual(formattedFirstFour.formatted, firstFour)
    }
}
