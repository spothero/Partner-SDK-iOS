//
//  SpotHero_Google_Places_Wrapper_ExampleTests.swift
//  SpotHero_Google_Places_Wrapper_ExampleTests
//
//  Created by Husein Kareem on 11/9/16.
//  Copyright © 2016 SpotHero, Inc. All rights reserved.
//

import XCTest
import CoreLocation
@testable import SpotHero_iOS_Google_Places_Wrapper

class SpotHero_Google_Places_Wrapper_ExampleTests: XCTestCase {
    private let waitDuration: NSTimeInterval = 10.0
    private let chicagoLocation: CLLocation = CLLocation(latitude: 41.894503, longitude: -87.636659)
    
    override func setUp() {
        super.setUp()
        
        GooglePlacesAPIWrapper.storeGoogleAPIKey("AIzaSyD9IZRte-MspRDQxxeuf-U6wioXN1x0_68")
    }
    func testGetPredictionWithInput() {
        let expectation = self.expectationWithDescription("testGetPredictionWithInput")
        
        GooglePlacesAPIWrapper.getPredictions("325 W Huron", completion: {
            predictions, error in
            XCTAssertNil(error)
            XCTAssertGreaterThanOrEqual(predictions.count, 1)
            XCTAssertLessThanOrEqual(predictions.count, 5)
            expectation.fulfill()
        })
        
        self.waitForExpectationsWithTimeout(self.waitDuration, handler: nil)
    }
    
    func testGetPredictionWithPlaceName() {
        let expectation = self.expectationWithDescription("testGetPredictionWithPlaceName")
        
        GooglePlacesAPIWrapper.getPredictions("SpotHero", completion: {
            predictions, error in
            XCTAssertNil(error)
            XCTAssertGreaterThanOrEqual(predictions.count, 1)
            XCTAssertLessThanOrEqual(predictions.count, 5)
            expectation.fulfill()
        })
        
        self.waitForExpectationsWithTimeout(self.waitDuration, handler: nil)
    }
    
    func testGetPlaceDetails() {
        let expectation = self.expectationWithDescription("testGetPlaceDetails")
        let prediction = GooglePlacesPredictionWrapper(predictionDescription: "SpotHero, West Huron Street, Chicago, IL, United States",
                                                       placeID: "ChIJEyn6463TD4gR9Ta3uIauNyo",
                                                       terms: [])
        GooglePlacesAPIWrapper.getPlaceDetails(prediction, completion: {
            placeDetails, error in
            
            XCTAssertNil(error)
            XCTAssertNotNil(placeDetails)
            if let placeDetails = placeDetails {
                XCTAssertEqual(placeDetails.name, "SpotHero")
                XCTAssertEqual(placeDetails.placeID, prediction.placeID)
                XCTAssertEqualWithAccuracy(placeDetails.location.coordinate.latitude,
                    self.chicagoLocation.coordinate.latitude,
                    accuracy: 0.001,
                    "The two locacations are not within 0.001")
                XCTAssertEqualWithAccuracy(placeDetails.location.coordinate.longitude,
                    self.chicagoLocation.coordinate.longitude,
                    accuracy: 0.001,
                    "The two locacations are not within 0.001")
            } else {
                XCTFail("Place Details is nil")
            }
            
            expectation.fulfill()
        })
        
        self.waitForExpectationsWithTimeout(self.waitDuration, handler: nil)
    }
}
