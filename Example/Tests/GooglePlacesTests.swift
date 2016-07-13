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
    let chicagoLocation = CLLocation(latitude: 41.894503, longitude: -87.636659)
    let spotheroQuery = "SpotHero"
    let spotheroPrediction = GooglePlacesPrediction(description: "SpotHero, West Huron Street, Chicago, IL, United States", placeID: "ChIJEyn6463TD4gR9Ta3uIauNyo")
    let invalidPrediction = GooglePlacesPrediction(description: "Invalid", placeID: "Invalid")

    func testGetPredictionsWithAddressSubstring() {
        let expectation = self.expectationWithDescription("testGetPredictionsWithAddressSubstring")
        
        GooglePlacesWrapper.getPredictions("325 W Huron",
                                           location: self.chicagoLocation) {
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
        
        GooglePlacesWrapper.getPredictions(spotheroQuery,
                                           location: self.chicagoLocation) {
                                            predictions, error in
                                            expectation.fulfill()
                                            XCTAssertNil(error)
                                            XCTAssertGreaterThanOrEqual(predictions.count, 1)
                                            XCTAssertLessThanOrEqual(predictions.count, 5)
                                            XCTAssertEqual(predictions.first?.description, self.spotheroPrediction.description)
                                            XCTAssertEqual(predictions.first?.placeID, self.spotheroPrediction.placeID)
        }
        
        self.waitForExpectationsWithTimeout(self.waitDuration, handler: nil)
    }
    
    func testNoResults() {
        let expectation = self.expectationWithDescription("testNoResults")
        
        // Just passing in jibberish so it finds no predictions
        GooglePlacesWrapper.getPredictions("fjkaiofnaic",
                                           location: self.chicagoLocation) {
                                            predictions, error in
                                            expectation.fulfill()
                                            XCTAssertNotNil(error)
                                            XCTAssertEqual((error as? GooglePlacesError), GooglePlacesError.NoPredictions)
                                            XCTAssertEqual(predictions.count, 0)
        }
        
        self.waitForExpectationsWithTimeout(self.waitDuration, handler: nil)
    }
    
    func testGetPlaceDetails() {
        let expectation = self.expectationWithDescription("testGetPlaceDetails")
        
        GooglePlacesWrapper.getPlaceDetails(self.spotheroPrediction) { placeDetails, error in
            expectation.fulfill()
            XCTAssertNil(error)
            XCTAssertNotNil(placeDetails)
            XCTAssertEqual(placeDetails?.name, "SpotHero")
            XCTAssertEqual(placeDetails?.placeID, self.spotheroPrediction.placeID)
            XCTAssertNotNil(placeDetails?.location)
        }
        
        self.waitForExpectationsWithTimeout(self.waitDuration, handler: nil)
    }
    
    func testInvalidPlaceID() {
        let expectation = self.expectationWithDescription("testGetPlaceDetails")
        
        GooglePlacesWrapper.getPlaceDetails(self.invalidPrediction) { placeDetails, error in
            expectation.fulfill()
            XCTAssertNotNil(error)
            XCTAssertNil(placeDetails)
            XCTAssertEqual((error as? GooglePlacesError), GooglePlacesError.PlaceDetailsNotFound)
        }
        
        self.waitForExpectationsWithTimeout(self.waitDuration, handler: nil)
    }
}
