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
    let spotheroName = "SpotHero"
    let spotheroPrediction = GooglePlacesPrediction(description: "SpotHero, West Huron Street, Chicago, IL, United States",
                                                    placeID: "ChIJEyn6463TD4gR9Ta3uIauNyo",
                                                    terms: [])
    let invalidPrediction = GooglePlacesPrediction(description: "Invalid",
                                                   placeID: "Invalid",
                                                   terms: [])

    func testGetPredictionsWithAddressSubstring() {
        let expectation = self.expectationWithDescription("testGetPredictionsWithAddressSubstring")
        
        GooglePlacesWrapper.getPredictions("325 W Huron",
                                           location: self.chicagoLocation) {
                                            predictions, error in
                                            expectation.fulfill()
                                            XCTAssertNil(error)
                                            XCTAssertGreaterThanOrEqual(predictions.count, 1)
                                            XCTAssertLessThanOrEqual(predictions.count, 5)
                                            if let firstPrediction = predictions.first {
                                                XCTAssertEqual(firstPrediction.description, "325 W Huron St, Chicago, IL, United States")
                                                XCTAssertEqual(firstPrediction.placeID, "ChIJs9x2O7UsDogR6kgNUj4svDQ")
                                                XCTAssertGreaterThan(firstPrediction.terms.count, 0)
                                            } else {
                                                XCTFail()
                                            }
                                            

        }
        
        self.waitForExpectationsWithTimeout(self.waitDuration, handler: nil)
    }

    func testGetPredictionsWithPlaceName() {
        let expectation = self.expectationWithDescription("testGetPredictionsWithPlaceName")
        
        GooglePlacesWrapper.getPredictions(self.spotheroName,
                                           location: self.chicagoLocation) {
                                            predictions, error in
                                            expectation.fulfill()
                                            XCTAssertNil(error)
                                            XCTAssertGreaterThanOrEqual(predictions.count, 1)
                                            XCTAssertLessThanOrEqual(predictions.count, 5)
                                            if let firstPrediction = predictions.first {
                                                XCTAssertEqual(firstPrediction.description, self.spotheroPrediction.description)
                                                XCTAssertEqual(firstPrediction.placeID, self.spotheroPrediction.placeID)
                                                XCTAssertGreaterThan(firstPrediction.terms.count, 0)
                                            } else {
                                                XCTFail()
                                            }
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
        
        GooglePlacesWrapper.getPlaceDetails(self.spotheroPrediction) {
            placeDetails, error in
            expectation.fulfill()
            XCTAssertNil(error)
            XCTAssertNotNil(placeDetails)
            if let placeDetails = placeDetails {
                XCTAssertEqual(placeDetails.name, self.spotheroName)
                XCTAssertEqual(placeDetails.placeID, self.spotheroPrediction.placeID)
                XCTAssertEqualWithAccuracy(placeDetails.location.coordinate.latitude, self.chicagoLocation.coordinate.latitude, accuracy: 0.001, "The two locacations are not within 0.001")
                XCTAssertEqualWithAccuracy(placeDetails.location.coordinate.longitude, self.chicagoLocation.coordinate.longitude, accuracy: 0.001, "The two locacations are not within 0.001")
            }
        }
        
        self.waitForExpectationsWithTimeout(self.waitDuration, handler: nil)
    }
    
    func testInvalidPlaceID() {
        let expectation = self.expectationWithDescription("testGetPlaceDetails")
        
        GooglePlacesWrapper.getPlaceDetails(self.invalidPrediction) {
            placeDetails, error in
            expectation.fulfill()
            XCTAssertNotNil(error)
            XCTAssertNil(placeDetails)
            XCTAssertEqual((error as? GooglePlacesError), GooglePlacesError.PlaceDetailsNotFound)
        }
        
        self.waitForExpectationsWithTimeout(self.waitDuration, handler: nil)
    }
}
