//
//  BaseTests.swift
//  SpotHero_iOS_Partner_SDK
//
//  Created by SpotHeroMatt on 8/1/16.
//  Copyright © 2016 SpotHero, Inc. All rights reserved.
//

import XCTest
@testable import SpotHero_iOS_Partner_SDK

class BaseTests: XCTestCase {
    let testEmail = "matt@gmail.com"
    
    // Create random email to deal with rate limiting emails
    var testEmailRandom: String {
        let rand = arc4random_uniform(100000)
        return "matt\(rand)@test.com"
    }
    
    override func setUp() {
        let expectation = self.expectationWithDescription("Retrieved API Keys")
        APIKeyConfig.sharedInstance.getKeys {
            success in
            expectation.fulfill()
            XCTAssert(success)
        }
        self.waitForExpectationsWithTimeout(10.0, handler: nil)
    }
}
