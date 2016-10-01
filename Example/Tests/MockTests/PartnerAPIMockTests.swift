//
//  PartnerAPIMockTests.swift
//  SpotHero_iOS_Partner_SDK
//
//  Created by Matthew Reed on 7/21/16.
//  Copyright © 2016 SpotHero, Inc. All rights reserved.
//

import XCTest
import VOKMockUrlProtocol
import CoreLocation

@testable import SpotHero_iOS_Partner_SDK

enum PartnerAPIMockTestsError: ErrorType {
    case CannotParseDate
}

class PartnerAPIMockTests: BaseTests {
    let timeoutDuration: NSTimeInterval = 10
    let startDate = DateFormatter.ISO8601NoSeconds.dateFromString("2016-08-02T19:01")
    let endDate = DateFormatter.ISO8601NoSeconds.dateFromString("2016-08-03T00:01")
    let reservationStartDate = DateFormatter.ISO8601NoMillisecondsUTC.dateFromString("2016-08-02T00:08:00Z")
    let reservationEndDate = DateFormatter.ISO8601NoMillisecondsUTC.dateFromString("2016-08-02T05:08:00Z")
    
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
    
    private func getFacilities(location: CLLocation, completion: FacilityCompletion) {
        if let
            startDate = self.startDate,
            endDate = self.endDate {
                FacilityAPI.fetchFacilities(location.coordinate,
                                            starts: startDate,
                                            ends: endDate,
                                            completion: completion)
        } else {
            completion(facilities: [], error: PartnerAPIMockTestsError.CannotParseDate, hasMorePages: false)
            XCTFail("Cannot parse dates")
        }
    }
    
    func testMockGetFacilities() {
        let expectation = self.expectationWithDescription("Got facilities")
        self.getFacilities(Constants.ChicagoLocation) {
            facilities, error, hasMorePages in
            
            if let returnedError = error {
                XCTFail("Unexpected error: \(returnedError)")
                
                //Nothing else to wait for - fulfill and bail.
                expectation.fulfill()
                return
            }
            
            XCTAssertNil(error)
            XCTAssertEqual(facilities.count, 137)
            guard let
                facility = facilities.first,
                rate = facility.availableRates.first else {
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
            XCTAssertEqual(rate.starts, self.startDate)
            XCTAssertEqual(rate.ends, self.endDate)
            XCTAssertFalse(rate.unavailable)
            XCTAssertEqual(rate.price, 1500)
            XCTAssertEqual(rate.ruleGroupID, 1390)
            XCTAssertNil(rate.unavailableReason)
            
            expectation.fulfill()
        }
        
        self.waitForExpectationsWithTimeout(self.timeoutDuration, handler: nil)
    }
    
    func testMockCreateReservation() {
        let expectation = self.expectationWithDescription("Created reservation")
        
        self.getFacilities(Constants.ChicagoLocation) {
            facilities, error, hasMorePages in
            if let returnedError = error {
                XCTFail("Unexpected error fetching facilities: \(returnedError)")
                
                //Nothing else to wait for - fulfill and bail.
                expectation.fulfill()
                return
            }
            
            if let facility = facilities.first, rate = facility.availableRates.first {
                ReservationAPI.createReservation(facility,
                                                 rate: rate,
                                                 email: self.testEmail,
                                                 stripeToken: "",
                                                 completion: {
                                                    reservation, reservationError in
                                                    
                                                    if let returnedReservationError = reservationError {
                                                        XCTFail("Unexpected error making reservation: \(returnedReservationError)")
                                                        
                                                        //Nothing else to wait for - fulfill and bail.
                                                        expectation.fulfill()
                                                        return
                                                    }
                                                    
                                                    XCTAssertNotNil(reservation)
                                                    XCTAssertEqual(reservation?.status, "valid")
                                                    XCTAssertEqual(reservation?.rentalID, 3559198)
                                                    XCTAssertEqual(reservation?.starts, self.reservationStartDate)
                                                    XCTAssertEqual(reservation?.ends, self.reservationEndDate)
                                                    XCTAssertEqual(reservation?.price, 1500)
                                                    XCTAssertEqual(reservation?.receiptAccessKey,
                                                        "bdce43f47b539e06e0cce19ffff2fa2f37e5b0d391caf2a76b5e9afbd34a9292")
                                                    
                                                    expectation.fulfill()
                })
            } else {
                XCTFail("Cannot get facility and rate")
            }
        }
        
        self.waitForExpectationsWithTimeout(self.timeoutDuration, handler: nil)
    }
}
