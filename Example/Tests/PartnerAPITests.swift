//
//  PartnerAPITests.swift
//  SpotHero_iOS_Partner_SDK_ExampleUITests
//
//  Created by Ellen Shapiro (Work) on 6/29/16.
//  Copyright © 2016 SpotHero, Inc. All rights reserved.
//

import XCTest
import CoreLocation
@testable import SpotHero_iOS_Partner_SDK

class PartnerAPITests: XCTestCase {
    let startDate = NSDate().dateByAddingTimeInterval(60 * 60 * 5)
    let endDate = NSDate().dateByAddingTimeInterval(60 * 60 * 10)
    let timeoutDuration: NSTimeInterval = 60
    
    override func setUp() {
        super.setUp()
        SpotHeroPartnerSDK.SharedInstance.partnerApplicationKey = "6b8382b154d9527c1f97341247708bfe7855207a"
    }
    
    func testGetFacilities() {
        let expectation = self.expectationWithDescription("testGetFacilities")
        
        FacilityAPI.fetchFacilities(Constants.ChicagoLocation,
                                    starts: self.startDate,
                                    ends: self.endDate) {
                                        facilities, error in
                                        XCTAssertNil(error)
                                        XCTAssert(facilities.count > 0)
                                        expectation.fulfill()
        }
        
        waitForExpectationsWithTimeout(self.timeoutDuration, handler: nil)
    }
    
    func testNoFacilities() {
        let expectation = self.expectationWithDescription("testNoFacilities")
        
        // Location in london so no facilities are found
        let location = CLLocation(latitude: 51.5074, longitude: 0.1278)
        
        FacilityAPI.fetchFacilities(location,
                                    starts: self.startDate,
                                    ends: self.endDate) {
                                        facilities, error in
                                        XCTAssertNotNil(error)
                                        XCTAssert(facilities.count == 0)
                                        expectation.fulfill()
        }
        
        waitForExpectationsWithTimeout(self.timeoutDuration, handler: nil)
    }
}
