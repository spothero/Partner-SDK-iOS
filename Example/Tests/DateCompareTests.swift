//
//  DateCompareTests.swift
//  SpotHero_iOS_Partner_SDK
//
//  Created by Ellen Shapiro (Work) on 9/29/16.
//  Copyright © 2016 SpotHero, Inc. All rights reserved.
//

import XCTest
@testable import SpotHero_iOS_Partner_SDK

class DateCompareTests: XCTestCase {

    func testDateComparison() {
        let calendar = NSCalendar.currentCalendar()
        let now = NSDate()
        let components = calendar.components([.Year, .Month, .Day, .Hour, .Minute], fromDate: now)
        components.day += 1
        guard let tomorrow = calendar.dateFromComponents(components) else {
            XCTFail("Could not create date from components!")
            return
        }
        
        XCTAssertTrue(now.shp_isBeforeDate(tomorrow))
        XCTAssertFalse(now.shp_isAfterDate(tomorrow))

        XCTAssertTrue(tomorrow.shp_isAfterDate(now))
        XCTAssertFalse(tomorrow.shp_isBeforeDate(now))
    }
}
