//
//  DateUITests.swift
//  SpotHero_iOS_Partner_SDK
//
//  Created by SpotHeroMatt on 12/29/16.
//  Copyright © 2016 SpotHero, Inc. All rights reserved.
//

import XCTest
import KIF
@testable import SpotHero_iOS_Partner_SDK_Example
@testable import SpotHero_iOS_Partner_SDK

class DateUITests: BaseUITests {
    func testUpdateEndDate() {
        tester().tapViewWithAccessibilityLabel(AccessibilityStrings.StartsTimeSelectionView)
        guard let timeSelectionView = tester().waitForViewWithAccessibilityLabel(AccessibilityStrings.TimeSelectionView) as? TimeSelectionView else {
            XCTFail("Cannot get time selection view")
            return
        }
        
        // Jan 29, 3:00pm Central Time
        let startDateSeconds: NSTimeInterval = 1580331600
        
        // Jan 29, 9:00pm Central Time
        let endDateSeconds: NSTimeInterval = startDateSeconds + (60 * 60 * 6)
        let startDate = NSDate(timeIntervalSince1970: startDateSeconds)
        let endDate = NSDate(timeIntervalSince1970: endDateSeconds)
        
        timeSelectionView.setStartEndDateTimeLabelWithDate(startDate)
        
        XCTAssertEqual(timeSelectionView.startDate, startDate)
        XCTAssertEqual(timeSelectionView.endDate, endDate)
    }
}
