//
//  SearchSpotsUITests.swift
//  SpotHero_iOS_Partner_SDK
//
//  Created by Husein Kareem on 8/10/16.
//  Copyright © 2016 SpotHero, Inc. All rights reserved.
//

import XCTest
import KIF
@testable import SpotHero_iOS_Partner_SDK_Example
@testable import SpotHero_iOS_Partner_SDK

class SearchSpotsUITests: BaseUITests {
    
    private let spotHeroAddress = "SpotHero, West Huron Street, Chicago, IL"
    
    //MARK: Test Lifecycle
    
    override func beforeEach() {
        super.beforeEach()
        ShowSDKUITests().testLaunchSDKShowsMapView()
    }
    
    override func afterAll() {
        tester().tapViewWithAccessibilityLabel(LocalizedStrings.Close)
        super.afterAll()
    }
    
    //MARK: Tests
    
    func testTypingAddressHidesTimeSelectionView() {
        //GIVEN: I see the map view
        //WHEN: I tap on the search bar and type an address
        tester().enterText(AccessibilityStrings.SpotHero,
                           intoViewWithAccessibilityLabel: AccessibilityStrings.SearchBar,
                           traits: UIAccessibilityTraitNone,
                           expectedResult: AccessibilityStrings.SpotHero)
        
        //THEN: The time selection view is hidden
        tester().waitForAbsenceOfViewWithAccessibilityLabel(AccessibilityStrings.TimeSelectionView)
        
        tester().tapViewWithAccessibilityLabel(AccessibilityStrings.ClearText)
    }
    
    func testTappingStartsViewShowsStartDatePickerView() {
        //GIVEN: I see the map view
        //WHEN: I tap on the starts view
        tester().tapViewWithAccessibilityLabel(AccessibilityStrings.StartsTimeSelectionView)
        
        //THEN: I see the start date picker view
        tester().waitForViewWithAccessibilityLabel(LocalizedStrings.SetStartTime)
        tester().waitForViewWithAccessibilityLabel(LocalizedStrings.Done)
        
        let startDateLabel = tester().waitForViewWithAccessibilityLabel(AccessibilityStrings.StartDateLabel) as? UILabel
        let startTimeLabel = tester().waitForViewWithAccessibilityLabel(AccessibilityStrings.StartTimeLabel) as? UILabel
        let endDateLabel = tester().waitForViewWithAccessibilityLabel(AccessibilityStrings.EndDateLabel) as? UILabel
        let endTimeLabel = tester().waitForViewWithAccessibilityLabel(AccessibilityStrings.EndTimeLabel) as? UILabel
        
        XCTAssertEqual(startDateLabel?.textColor, .shp_spotHeroBlue())
        XCTAssertEqual(startTimeLabel?.textColor, .shp_spotHeroBlue())
        XCTAssertEqual(endDateLabel?.textColor, .blackColor())
        XCTAssertEqual(endTimeLabel?.textColor, .blackColor())
        
        tester().tapViewWithAccessibilityLabel(LocalizedStrings.Done)
    }
    
    func testTappingEndsViewShowsEndDatePickerView() {
        //GIVEN: I see the map view
        //WHEN: I tap on the ends view
        tester().tapViewWithAccessibilityLabel(AccessibilityStrings.EndsTimeSelectionView)
        
        //THEN: I see the end date picker view
        tester().waitForViewWithAccessibilityLabel(LocalizedStrings.SetEndTime)
        tester().waitForViewWithAccessibilityLabel(LocalizedStrings.Done)
        
        let startDateLabel = tester().waitForViewWithAccessibilityLabel(AccessibilityStrings.StartDateLabel) as? UILabel
        let startTimeLabel = tester().waitForViewWithAccessibilityLabel(AccessibilityStrings.StartTimeLabel) as? UILabel
        let endDateLabel = tester().waitForViewWithAccessibilityLabel(AccessibilityStrings.EndDateLabel) as? UILabel
        let endTimeLabel = tester().waitForViewWithAccessibilityLabel(AccessibilityStrings.EndTimeLabel) as? UILabel
        
        XCTAssertEqual(startDateLabel?.textColor, .blackColor())
        XCTAssertEqual(startTimeLabel?.textColor, .blackColor())
        XCTAssertEqual(endDateLabel?.textColor, .shp_spotHeroBlue())
        XCTAssertEqual(endTimeLabel?.textColor, .shp_spotHeroBlue())
        
        tester().tapViewWithAccessibilityLabel(LocalizedStrings.Done)
    }
    
    func testSelectingAddressShowsSearchSpotsButton() {
        //GIVEN: I see the map view
        //WHEN: I search for an address
        tester().enterText(AccessibilityStrings.SpotHero,
                           intoViewWithAccessibilityLabel: AccessibilityStrings.SearchBar,
                           traits: UIAccessibilityTraitNone,
                           expectedResult: AccessibilityStrings.SpotHero)
        tester().tapViewWithAccessibilityLabel(self.spotHeroAddress)
        
        //THEN: I see the search spots button
        tester().waitForViewWithAccessibilityLabel(LocalizedStrings.SearchSpots)
        
        tester().tapViewWithAccessibilityLabel(AccessibilityStrings.ClearText)
    }
    
    func testClearingTextHidesSearchSpotsButton() {
        //GIVEN: I see the map view
        //WHEN: I search for an address
        tester().enterText(AccessibilityStrings.SpotHero,
                           intoViewWithAccessibilityLabel: AccessibilityStrings.SearchBar,
                           traits: UIAccessibilityTraitNone,
                           expectedResult: AccessibilityStrings.SpotHero)
        tester().tapViewWithAccessibilityLabel(self.spotHeroAddress)
        tester().waitForViewWithAccessibilityLabel(LocalizedStrings.SearchSpots)
        
        //WHEN: I tap clear text
        tester().tapViewWithAccessibilityLabel(AccessibilityStrings.ClearText)
        
        //THEN: The search spots button is hidden
        tester().waitForAbsenceOfViewWithAccessibilityLabel(LocalizedStrings.SearchSpots)
    }
}
