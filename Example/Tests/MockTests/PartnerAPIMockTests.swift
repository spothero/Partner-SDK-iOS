//
//  PartnerAPIMockTests.swift
//  SpotHero_iOS_Partner_SDK
//
//  Created by SpotHeroMatt on 7/21/16.
//  Copyright © 2016 SpotHero, Inc. All rights reserved.
//

import XCTest
import VOKMockUrlProtocol

@testable import SpotHero_iOS_Partner_SDK

class PartnerAPIMockTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
        SpotHeroPartnerAPIController.sph_startUsingMockData()
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        SpotHeroPartnerAPIController.sph_stopUsingMockData()
        super.tearDown()
    }
    
    func skip_testGetFacilities() {
        let expectation = self.expectationWithDescription("testGetFacilities")
        let startDate = NSDate().dateByAddingTimeInterval(60 * 60 * 5)
        let endDate = NSDate().dateByAddingTimeInterval(60 * 60 * 10)
        
        FacilityAPI.fetchFacilities(Constants.ChicagoLocation,
                                    starts: startDate,
                                    ends: endDate) {
                                        facilities, error in
                                        XCTAssertNil(error)
                                        XCTAssert(facilities.count > 0)
                                        expectation.fulfill()
        }
        
        waitForExpectationsWithTimeout(60, handler: nil)
    }
    
}
