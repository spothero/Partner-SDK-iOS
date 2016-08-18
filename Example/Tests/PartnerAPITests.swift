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

class PartnerAPITests: BaseTests {
    let timeoutDuration: NSTimeInterval = 60
    
    override func setUp() {
        super.setUp()
        SpotHeroPartnerSDK.SharedInstance.partnerApplicationKey = "246691fb79c08b02c36d4a265a359c639ed75578"
    }
    
    func getFacilities(location: CLLocation, completion: ([Facility], ErrorType?) -> Void) {
        let startDate = NSDate().dateByAddingTimeInterval(60 * 60 * 5)
        let endDate = NSDate().dateByAddingTimeInterval(60 * 60 * 10)
        FacilityAPI.fetchFacilities(location,
                                    starts: startDate,
                                    ends: endDate,
                                    completion: completion)
    }
    
    func testGetFacilities() {
        let expectation = self.expectationWithDescription("testGetFacilities")
        
        self.getFacilities(Constants.ChicagoLocation) {
            facilities, error in
            XCTAssertNil(error)
            XCTAssert(facilities.count > 0)
            expectation.fulfill()
        }
        
        self.waitForExpectationsWithTimeout(self.timeoutDuration, handler: nil)
    }
    
    func testNoFacilities() {
        let expectation = self.expectationWithDescription("testNoFacilities")
        
        // Location in london so no facilities will be found
        let location = CLLocation(latitude: 51.5074, longitude: 0.1278)
        
        self.getFacilities(location) {
            facilities, error in
            XCTAssertNotNil(error)
            XCTAssert(facilities.count == 0)
            expectation.fulfill()
        }
        
       self.waitForExpectationsWithTimeout(self.timeoutDuration, handler: nil)
    }
    
    func testCreateReservation() {
        let expectation = self.expectationWithDescription("testCreateReservation")
        
        self.getFacilities(Constants.ChicagoLocation) {
            facilities, error in
            if let facility = facilities.first, rate = facility.rates.first {
                StripeWrapper.getToken("4242424242424242",
                                       expirationMonth: "12",
                                       expirationYear: "2017",
                                       cvc: "123") {
                                        token, error in
                                        guard let token = token else {
                                            XCTFail("Failed to get token")
                                            return
                                        }
                                        
                                        ReservationAPI.createReservation(facility,
                                                                         rate: rate,
                                                                         email: self.testEmail,
                                                                         stripeToken: token,
                                                                         completion: {
                                                                            reservation, error in
                                                                            XCTAssertNil(error)
                                                                            XCTAssertNotNil(reservation)
                                                                            if let reservation = reservation {
                                                                                // Cancel Reservation so spots don't run out
                                                                                ReservationAPI.cancelReservation(reservation, completion: { (error) -> (Void) in
                                                                                    XCTAssertNil(error)
                                                                                    expectation.fulfill()
                                                                                })
                                                                            } else {
                                                                                XCTFail("Could not get reservation")
                                                                            }
                                        })
                }
                
            } else {
                XCTFail("Cannot get facility and rate")
            }
        }
        
        self.waitForExpectationsWithTimeout(self.timeoutDuration, handler: nil)
    }
}
