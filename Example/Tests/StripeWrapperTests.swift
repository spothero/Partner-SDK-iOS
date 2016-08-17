//
//  StripeWrapperTests.swift
//  SpotHero_iOS_Partner_SDK
//
//  Created by Matthew Reed on 7/26/16.
//  Copyright © 2016 SpotHero, Inc. All rights reserved.
//

import XCTest

@testable import SpotHero_iOS_Partner_SDK

class StripeWrapperTests: XCTestCase {

    func testGetToken() {
        let expectation = self.expectationWithDescription("testGetToken")
        
        StripeWrapper.getToken("4242424242424242",
                               expirationMonth: "12",
                               expirationYear: "2017",
                               cvc: "123") {
                                token, error in
                                XCTAssertNil(error)
                                XCTAssertNotNil(token)
                                expectation.fulfill()
        }
        
        self.waitForExpectationsWithTimeout(60, handler: nil)
    }

}
