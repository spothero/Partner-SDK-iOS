//
//  CityListTests.swift
//  SpotHero_iOS_Partner_SDK_Tests
//
//  Created by Matthew Reed on 12/8/17.
//  Copyright © 2017 SpotHero, Inc. All rights reserved.
//

@testable import SpotHero_iOS_Partner_SDK
import XCTest

class CityListTests: BaseTests {
    func testGetCities() {
        let expectation = self.expectation(description: "Got cities")
        CityListAPI.getCities { cities in
            XCTAssertFalse(cities.isEmpty)
            cities.forEach { XCTAssertTrue($0.isSpotHeroCity) }
            expectation.fulfill()
        }
        self.waitForExpectations()
    }
}
