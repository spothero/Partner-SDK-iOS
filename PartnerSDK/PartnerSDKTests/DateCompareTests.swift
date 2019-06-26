//
//  DateCompareTests.swift
//  SpotHero_iOS_Partner_SDK
//
//  Created by Ellen Shapiro (Work) on 9/29/16.
//  Copyright © 2016 SpotHero, Inc. All rights reserved.
//

@testable import SpotHero_iOS_Partner_SDK
import XCTest

class DateCompareTests: XCTestCase {

    func testDateComparison() {
        let calendar = Calendar.current
        let now = Date()
        var components = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: now)
        components.day? += 1
        
        guard let tomorrow = calendar.date(from: components) else {
            XCTFail("Could not create date from components!")
            return
        }
        
        XCTAssertTrue(now.shp_isBeforeDate(tomorrow))
        XCTAssertFalse(now.shp_isAfterDate(tomorrow))

        XCTAssertTrue(tomorrow.shp_isAfterDate(now))
        XCTAssertFalse(tomorrow.shp_isBeforeDate(now))
    }
}
