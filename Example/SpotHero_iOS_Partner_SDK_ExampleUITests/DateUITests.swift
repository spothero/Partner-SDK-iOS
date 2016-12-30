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
        
        let startDate = NSDate(timeIntervalSince1970: 1580331600)
        
        timeSelectionView.setStartEndDateTimeLabelWithDate(startDate)
        
        tester().waitForTimeInterval(10)
        
        guard
            let startTimeTextField = tester().waitForViewWithAccessibilityLabel(AccessibilityStrings.StartTimeTextField) as? UITextField,
            let startDateLabel = tester().waitForViewWithAccessibilityLabel(AccessibilityStrings.StartDateLabel) as? UILabel,
            let endTimetextField = tester().waitForViewWithAccessibilityLabel(AccessibilityStrings.EndTimeTextField) as? UITextField,
            let endDateLabel = tester().waitForViewWithAccessibilityLabel(AccessibilityStrings.EndDateLabel) as? UILabel else {
            XCTFail("Cannot get start time label")
            return
        }
        
        XCTAssertEqual("3:00pm", startTimeTextField.text)
        XCTAssertEqual("Jan 29, 2020", startDateLabel.text)
        XCTAssertEqual("9:00pm", endTimetextField.text)
        XCTAssertEqual("Jan 29, 2020", endDateLabel.text)
    }
}
