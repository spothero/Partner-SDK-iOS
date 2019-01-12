//
//  PartnerAPITests.swift
//  SpotHero_iOS_Partner_SDK_ExampleUITests
//
//  Created by Ellen Shapiro (Work) on 6/29/16.
//  Copyright © 2016 SpotHero, Inc. All rights reserved.
//

import CoreLocation
@testable import SpotHero_iOS_Partner_SDK
import XCTest

class PartnerAPITests: BaseTests {
    let timeoutDuration: TimeInterval = 60
    
    func getFacilities(_ location: CLLocation, completion: @escaping FacilityCompletion) {
        let startDate = Date().addingTimeInterval(60 * 60 * 5)
        let endDate = Date().addingTimeInterval(60 * 60 * 10)
        FacilityAPI.fetchFacilities(location.coordinate,
                                    starts: startDate,
                                    ends: endDate,
                                    completion: completion)
    }
    
    func testGetFacilities() {
        let expectation = self.expectation(description: "testGetFacilities")
        
        self.getFacilities(Constants.ChicagoLocation) {
            facilities, error, hasMorePages in
            if hasMorePages {
                XCTAssertNil(error)
                XCTAssertFalse(facilities.isEmpty)
            } else {
                expectation.fulfill()
            }
        }
        
        self.waitForExpectations(timeout: self.timeoutDuration, handler: nil)
    }
    
    func testCancelGetFacilities() {
        self.getFacilities(Constants.ChicagoLocation) {
            facilities, error, hasMorePages in
            XCTAssertEqual(facilities.count, 0)
            XCTAssertNotNil(error)
            XCTAssertFalse(hasMorePages)
            if let error = error as NSError? {
                XCTAssertEqual(error.code, URLError.cancelled.rawValue)
            } else {
                XCTFail("Received the wrong error type")
            }
        }
        
        FacilityAPI.stopSearching()
        XCTAssertFalse(FacilityAPI.searching())
    }
    
    func testNoFacilities() {
        let expectation = self.expectation(description: "testNoFacilities")
        
        // Location in london so no facilities will be found
        let location = CLLocation(latitude: 51.5074, longitude: 0.1278)
        
        self.getFacilities(location) {
            facilities, error, hasMorePages in
            XCTAssertNotNil(error)
            XCTAssertTrue(facilities.isEmpty)
            XCTAssertFalse(hasMorePages)
            expectation.fulfill()
        }
        
       self.waitForExpectations(timeout: self.timeoutDuration, handler: nil)
    }
    
    func testCreateReservation() {
        let expectation = self.expectation(description: "testCreateReservation")
    
        var testExecuting = false
        self.getFacilities(Constants.HuronStLocation) {
            facilities, error, _ in
            
            // This is another set of results from getting the facilities.
            if testExecuting {
                return
            }
            
            testExecuting = true
            var testFacility: Facility? = nil
            for facility in facilities {
                if !facility.phoneNumberRequired && !facility.licensePlateRequired {
                    testFacility = facility
                    break
                }
            }
            
            if let facility = testFacility,
                let rate = facility.availableRates.first {
                StripeWrapper.getToken(self.creditCardNumber,
                                       expirationMonth: self.expirationMonth,
                                       expirationYear: self.expirationYear,
                                       cvc: self.cvc) {
                                        token, error in
                                        guard let token = token else {
                                            XCTFail("Failed to get token")
                                            expectation.fulfill()
                                            return
                                        }
                                        
                                        ReservationAPI.createReservation(facility,
                                                                         rate: rate,
                                                                         email: self.testEmailRandom,
                                                                         phone: self.testPhone,
                                                                         stripeToken: token,
                                                                         saveInfo: false,
                                                                         completion: {
                                                                            reservation, error in
                                                                            XCTAssertNil(error)
                                                                            XCTAssertNotNil(reservation)
                                                                            if let reservation = reservation {
                                                                                // Cancel Reservation so spots don't run out
                                                                                ReservationAPI.cancelReservation(reservation) {
                                                                                    error in
                                                                                    XCTAssertNil(error)
                                                                                    expectation.fulfill()
                                                                                }
                                                                            } else {
                                                                                XCTFail("Could not get reservation")
                                                                                expectation.fulfill()
                                                                            }
                                        })
                }
                
            } else {
                XCTFail("Cannot get facility and rate")
            }
        }
        
        self.waitForExpectations(timeout: self.timeoutDuration, handler: nil)
    }
}
