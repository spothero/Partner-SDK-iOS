//
//  BaseTests.swift
//  SpotHero_iOS_Partner_SDK
//
//  Created by SpotHeroMatt on 8/1/16.
//  Copyright © 2016 SpotHero, Inc. All rights reserved.
//

@testable import SpotHero_iOS_Partner_SDK
import XCTest

class BaseTests: XCTestCase {
    let testEmail = "matt@gmail.com"
    
    // Create random email to deal with rate limiting emails
    var testEmailRandom: String {
        let rand = arc4random_uniform(100000)
        return "matt\(rand)@test.com"
    }
    
    let testPhone = "3125555555"
    
    override func setUp() {
        super.setUp()
        let expectation = self.expectation(description: "Retrieved API Keys")
        APIKeyConfig.sharedInstance.getKeys {
            success in
            expectation.fulfill()
            XCTAssert(success)
            XCTAssertNotNil(APIKeyConfig.sharedInstance.googleApiKey)
            XCTAssertNotNil(APIKeyConfig.sharedInstance.stripeApiKey)
            XCTAssertNotNil(APIKeyConfig.sharedInstance.mixpanelApiKey)
        }
        self.waitForExpectations(timeout: 10.0, handler: nil)
    }
}
