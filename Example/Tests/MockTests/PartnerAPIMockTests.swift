//
//  PartnerAPIMockTests.swift
//  SpotHero_iOS_Partner_SDK
//
//  Created by SpotHeroMatt on 7/21/16.
//  Copyright © 2016 SpotHero, Inc. All rights reserved.
//

import XCTest
import VOKMockUrlProtocol
import CoreLocation

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
    
    func testGetFacilities() {
        let expectation = self.expectationWithDescription("testGetFacilities")
        if let
            startDate = DateFormatter.ISO8601NoSeconds.dateFromString("2016-08-01T16:18"),
            endDate = DateFormatter.ISO8601NoSeconds.dateFromString("2016-08-01T21:18") {
            FacilityAPI.fetchFacilities(Constants.ChicagoLocation,
                                        starts: startDate,
                                        ends: endDate) {
                                            facilities, error in
                                            XCTAssertNil(error)
                                            XCTAssertEqual(facilities.count, 188)
                                            guard let
                                                facility = facilities.first,
                                                rate = facility.rates.first else {
                                                    XCTFail("Did not get facility or rate")
                                                    return
                                            }
                                            
                                            XCTAssertEqual(facility.title, "320 W Erie St. - Valet")
                                            XCTAssert(facility.licensePlateRequired)
                                            XCTAssertEqual(facility.parkingSpotID, 1477)
                                            XCTAssertEqual(facility.timeZone, "America/Chicago")
                                            XCTAssertEqual(facility.location.coordinate.latitude, 41.894011708375274)
                                            XCTAssertEqual(facility.location.coordinate.longitude, -87.63697385787964)
                                            XCTAssertFalse(facility.phoneNumberRequired)
                                            
                                            XCTAssertEqual(rate.displayPrice, 15)
                                            XCTAssertEqual(rate.starts, startDate)
                                            XCTAssertEqual(rate.ends, endDate)
                                            XCTAssertFalse(rate.unavailable)
                                            XCTAssertEqual(rate.price, 1500)
                                            XCTAssertEqual(rate.ruleGroupID, 1390)
                                            XCTAssertNil(rate.unavailableReason)
                                            
                                            expectation.fulfill()
            }
        } else {
            XCTFail("Unable to parse dates")
        }
        
        waitForExpectationsWithTimeout(2, handler: nil)
    }
    
    
    
}
