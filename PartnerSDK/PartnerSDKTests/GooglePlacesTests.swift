//
//  GooglePlacesTests.swift
//  SpotHero_iOS_Partner_SDK
//
//  Created by Matthew Reed on 7/12/16.
//  Copyright © 2016 SpotHero, Inc. All rights reserved.
//

import CoreLocation
@testable import SpotHero_iOS_Partner_SDK
import XCTest

class GooglePlacesTests: BaseTests {
    let waitDuration: TimeInterval = 10
    let spotheroPrediction = GooglePlacesPrediction(predictionDescription: "SpotHero, West Huron Street, Chicago, IL, United States",
                                                    placeID: "ChIJEyn6463TD4gR9Ta3uIauNyo",
                                                    terms: [])
    let invalidPrediction = GooglePlacesPrediction(predictionDescription: "Invalid",
                                                   placeID: "Invalid",
                                                   terms: [])
    
    func testGetPredictionsWithAddressSubstring() {
        let expectation = self.expectation(description: "testGetPredictionsWithAddressSubstring")
        
        GooglePlacesWrapper.getPredictions("325 W Huron",
                                           location: Constants.ChicagoLocation) { predictions, error in
                                            XCTAssertNil(error)
                                            XCTAssertGreaterThanOrEqual(predictions.count, 1)
                                            XCTAssertLessThanOrEqual(predictions.count, 5)
                                            expectation.fulfill()
        }
        
        self.waitForExpectations(timeout: self.waitDuration, handler: nil)
    }
    
    func testGetPredictionsWithPlaceName() {
        let expectation = self.expectation(description: "testGetPredictionsWithPlaceName")
        
        GooglePlacesWrapper.getPredictions(AccessibilityStrings.SpotHero,
                                           location: Constants.ChicagoLocation) { predictions, error in
                                            XCTAssertNil(error)
                                            XCTAssertGreaterThanOrEqual(predictions.count, 1)
                                            XCTAssertLessThanOrEqual(predictions.count, 5)
                                            expectation.fulfill()
        }
        
        self.waitForExpectations(timeout: self.waitDuration, handler: nil)
    }
    
    func testNoResults() {
        let expectation = self.expectation(description: "testNoResults")
        
        // Just passing in jibberish so it finds no predictions
        GooglePlacesWrapper.getPredictions("fgkgkbnvjjhkhjhjllhjjlgjl",
                                           location: Constants.ChicagoLocation) { predictions, error in
                                            XCTAssertNotNil(error)
                                            XCTAssertEqual((error as? GooglePlacesError), GooglePlacesError.noPredictions)
                                            XCTAssertEqual(predictions.count, 0)
                                            expectation.fulfill()
        }
        
        self.waitForExpectations(timeout: self.waitDuration, handler: nil)
    }
    
    func testGetPlaceDetails() {
        let expectation = self.expectation(description: "testGetPlaceDetails")
        
        GooglePlacesWrapper.getPlaceDetails(self.spotheroPrediction) { placeDetails, error in
            XCTAssertNil(error)
            XCTAssertNotNil(placeDetails)
            if let placeDetails = placeDetails {
                XCTAssertEqual(placeDetails.name, AccessibilityStrings.SpotHero)
                XCTAssertEqual(placeDetails.placeID, self.spotheroPrediction.placeID)
                XCTAssertEqual(placeDetails.location.coordinate.latitude,
                               Constants.ChicagoLocation.coordinate.latitude,
                               accuracy: 0.001,
                               "The two locacations are not within 0.001")
                XCTAssertEqual(placeDetails.location.coordinate.longitude,
                               Constants.ChicagoLocation.coordinate.longitude,
                               accuracy: 0.001,
                               "The two locacations are not within 0.001")
            } else {
                XCTFail("Place Details is nil")
            }
            expectation.fulfill()
        }
        
        self.waitForExpectations(timeout: self.waitDuration, handler: nil)
    }
    
    func testInvalidPlaceID() {
        let expectation = self.expectation(description: "testGetPlaceDetails")
        
        GooglePlacesWrapper.getPlaceDetails(self.invalidPrediction) { placeDetails, error in
            XCTAssertNotNil(error)
            XCTAssertNil(placeDetails)
            XCTAssertEqual((error as? GooglePlacesError), GooglePlacesError.placeDetailsNotFound)
            expectation.fulfill()
        }
        
        self.waitForExpectations(timeout: self.waitDuration, handler: nil)
    }
}
