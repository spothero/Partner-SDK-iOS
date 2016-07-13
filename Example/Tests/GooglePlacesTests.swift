//
//  GooglePlacesTests.swift
//  SpotHero_iOS_Partner_SDK
//
//  Created by SpotHeroMatt on 7/12/16.
//  Copyright © 2016 SpotHero, Inc. All rights reserved.
//

import XCTest
import CoreLocation
@testable import SpotHero_iOS_Partner_SDK

class GooglePlacesTests: XCTestCase {
    let waitDuration: NSTimeInterval = 10

    func testGetPredictionsWithAddressSubstring() {
        let expectation = self.expectationWithDescription("testGetPredictionsWithAddressSubstring")
        
        GooglePlacesWrapper.getPredictions("325 W Huron",
                                           location: Constants.ChicagoLocation) {
                                                predictions, error in
                                                expectation.fulfill()
                                                XCTAssertNil(error)
                                                XCTAssertGreaterThanOrEqual(predictions.count, 1)
                                                XCTAssertLessThanOrEqual(predictions.count, 5)
                                                XCTAssertEqual(predictions.first?.description, "325 W Huron St, Chicago, IL, United States")
                                                XCTAssertEqual(predictions.first?.placeID, "ChIJs9x2O7UsDogR6kgNUj4svDQ")
        }
        
        self.waitForExpectationsWithTimeout(self.waitDuration, handler: nil)
    }

    func testGetPredictionsWithPlaceName() {
        let expectation = self.expectationWithDescription("testGetPredictionsWithPlaceName")
        
        GooglePlacesWrapper.getPredictions("SpotHero",
                                           location: Constants.ChicagoLocation) {
                                            predictions, error in
                                            expectation.fulfill()
                                            XCTAssertNil(error)
                                            XCTAssertGreaterThanOrEqual(predictions.count, 1)
                                            XCTAssertLessThanOrEqual(predictions.count, 5)
                                            XCTAssertEqual(predictions.first?.description, "SpotHero, West Huron Street, Chicago, IL, United States")
                                            XCTAssertEqual(predictions.first?.placeID, "ChIJEyn6463TD4gR9Ta3uIauNyo")
        }
        
        self.waitForExpectationsWithTimeout(self.waitDuration, handler: nil)
    }
    
    func testNoResults() {
        let expectation = self.expectationWithDescription("testNoResults")
        
        // Just passing in jibberish so it finds no predictions
        GooglePlacesWrapper.getPredictions("fjkaiofnaic",
                                           location: Constants.ChicagoLocation) {
                                            predictions, error in
                                            expectation.fulfill()
                                            XCTAssertNotNil(error)
                                            XCTAssertEqual((error as? GooglePlacesError), GooglePlacesError.NoPredictions)
                                            XCTAssertEqual(predictions.count, 0)
        }
        
        self.waitForExpectationsWithTimeout(self.waitDuration, handler: nil)
    }
}
