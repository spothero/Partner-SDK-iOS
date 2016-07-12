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
    func testGetPredictionsWithAddressSubstring() {
        let exp = self.expectationWithDescription("testGetPredictionsWithAddressSubstring")
        
        GooglePlacesWrapper.getPredictions("325 W Huron", location: CLLocation(latitude: 41.894503, longitude: -87.636659)) { predictions in
            exp.fulfill()
            XCTAssertEqual(predictions.count, 5)
            XCTAssertEqual(predictions.first?.description, "325 W Huron St, Chicago, IL, United States")
        }
        
        self.waitForExpectationsWithTimeout(10, handler: nil)
    }

    func testGetPredictionsWithPlaceName() {
        let exp = self.expectationWithDescription("testGetPredictionsWithPlaceName")
        
        GooglePlacesWrapper.getPredictions("SpotHero", location: CLLocation(latitude: 41.894503, longitude: -87.636659)) { predictions in
            exp.fulfill()
            XCTAssertEqual(predictions.count, 1)
            XCTAssertEqual(predictions.first?.description, "SpotHero, West Huron Street, Chicago, IL, United States")
        }
        
        self.waitForExpectationsWithTimeout(10, handler: nil)
    }
}
