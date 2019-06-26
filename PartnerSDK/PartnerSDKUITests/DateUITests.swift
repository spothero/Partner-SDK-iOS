//
//  DateUITests.swift
//  SpotHero_iOS_Partner_SDK
//
//  Created by SpotHeroMatt on 12/29/16.
//  Copyright © 2016 SpotHero, Inc. All rights reserved.
//

import KIF
@testable import PartnerSDKDemo
@testable import SpotHero_iOS_Partner_SDK
import XCTest

class DateUITests: BaseUITests {
    func skip_testUpdateEndDate() {
        tester().tapView(withAccessibilityLabel: AccessibilityStrings.StartsTimeSelectionView)
        guard
            let timeSelectionView = tester().waitForView(withAccessibilityLabel: AccessibilityStrings.TimeSelectionView) as? TimeSelectionView else {
                XCTFail("Cannot get time selection view")
                return
        }
        
        // Jan 29, 3:00pm Central Time
        let startDateSeconds: TimeInterval = 1_580_331_600
        
        // Jan 29, 9:00pm Central Time
        let endDateSeconds: TimeInterval = startDateSeconds + (60 * 60 * 6)
        let startDate = Date(timeIntervalSince1970: startDateSeconds)
        let endDate = Date(timeIntervalSince1970: endDateSeconds)
        
        timeSelectionView.setStartEndDateTimeLabelWithDate(startDate)
        
        XCTAssertEqual(timeSelectionView.startDate, startDate)
        XCTAssertEqual(timeSelectionView.endDate, endDate)
    }
}
