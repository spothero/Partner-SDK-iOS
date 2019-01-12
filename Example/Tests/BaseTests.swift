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
    let creditCardNumber = "4242424242424242"
    let expirationMonth = "12"
    let expirationYear = "2020"
    let cvc = "123"
    let timeout = 10.0
    
    // Create random email to deal with rate limiting emails
    var testEmailRandom: String {
        let rand = arc4random_uniform(100000)
        return "matt\(rand)@test.com"
    }
    
    let testPhone = "3125555555"
    
    func waitForExpectations() {
        self.waitForExpectations(timeout: self.timeout, handler: nil)
    }
    
    override func setUp() {
        super.setUp()
        let expectation = self.expectation(description: "Retrieved API Keys")
        ServerEnvironment.CurrentEnvironment = .staging
        SpotHeroPartnerSDK.shared.partnerApplicationKey = "YOUR APPLICATION KEY HERE"
        APIKeyConfig.sharedInstance.getKeys {
            success in
            expectation.fulfill()
            XCTAssert(success)
            XCTAssertNotNil(APIKeyConfig.sharedInstance.googleApiKey)
            XCTAssertNotNil(APIKeyConfig.sharedInstance.stripeApiKey)
            XCTAssertNotNil(APIKeyConfig.sharedInstance.mixpanelApiKey)
        }
        self.waitForExpectations()
    }
}
