//
//  StripeWrapperTests.swift
//  SpotHero_iOS_Partner_SDK
//
//  Created by Matthew Reed on 7/26/16.
//  Copyright © 2016 SpotHero, Inc. All rights reserved.
//

import XCTest

@testable import SpotHero_iOS_Partner_SDK

class StripeWrapperTests: BaseTests {

    func testGetToken() {
        let expectation = self.expectationWithDescription("testGetToken")
        
        StripeWrapper.getToken(Constants.Test.CreditCardNumber,
                               expirationMonth: Constants.Test.ExpirationMonth,
                               expirationYear: Constants.Test.ExpirationYear,
                               cvc: Constants.Test.CVC) {
                                token, error in
                                XCTAssertNil(error)
                                XCTAssertNotNil(token)
                                expectation.fulfill()
        }
        
        self.waitForExpectationsWithTimeout(60, handler: nil)
    }

}
