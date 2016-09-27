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
    
    //MARK: Helpers
    
    private func validateStartEndViewSelectedState() {
        let timeSelectionView = tester().waitForViewWithAccessibilityLabel(AccessibilityStrings.TimeSelectionView) as? TimeSelectionView
        XCTAssertNotEqual(timeSelectionView?.endViewSelected, timeSelectionView?.startViewSelected)
    }
    
    private func dismissStartView() {
        let timeSelectionView = tester().waitForViewWithAccessibilityLabel(AccessibilityStrings.TimeSelectionView) as? TimeSelectionView
        tester().tapViewWithAccessibilityLabel(LocalizedStrings.Done)
        XCTAssertEqual(false, timeSelectionView?.startViewSelected)
        tester().tapViewWithAccessibilityLabel(LocalizedStrings.Done)
        XCTAssertEqual(false, timeSelectionView?.endViewSelected)
    }
    
    private func dismissEndView() {
        let timeSelectionView = tester().waitForViewWithAccessibilityLabel(AccessibilityStrings.TimeSelectionView) as? TimeSelectionView
        tester().tapViewWithAccessibilityLabel(LocalizedStrings.Done)
        XCTAssertEqual(false, timeSelectionView?.startViewSelected)
        XCTAssertEqual(false, timeSelectionView?.endViewSelected)
    }
    
    //MARK: Tests
    
    func testTypingAddressHidesTimeSelectionView() {
        //GIVEN: I see the map view
        //WHEN: I tap on the search bar and type an address
        self.enterTextIntoSearchBar(AccessibilityStrings.SpotHero)
        
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
        self.validateStartEndViewSelectedState()
        
        self.dismissStartView()
    }
    
    func testTappingEndsViewShowsEndDatePickerView() {
        //GIVEN: I see the map view
        //WHEN: I tap on the ends view
        tester().tapViewWithAccessibilityLabel(AccessibilityStrings.EndsTimeSelectionView)
        
        //THEN: I see the end date picker view
        tester().waitForViewWithAccessibilityLabel(LocalizedStrings.SetEndTime)
        tester().waitForViewWithAccessibilityLabel(LocalizedStrings.Done)
        self.validateStartEndViewSelectedState()
        
        self.dismissEndView()
    }
    
    func testSelectingAddressShowsSearchSpotsButton() {
        //GIVEN: I see the map view
        //WHEN: I search for an address
        self.enterTextIntoSearchBar(AccessibilityStrings.SpotHero)
        tester().tapViewWithAccessibilityLabel(self.spotHeroAddress)
        
        //THEN: I see the search spots button
        tester().waitForViewWithAccessibilityLabel(LocalizedStrings.SearchSpots)
        
        tester().tapViewWithAccessibilityLabel(AccessibilityStrings.ClearText)
    }
    
    func testClearingTextHidesSearchSpotsButton() {
        //GIVEN: I see the map view
        //WHEN: I search for an address
        self.enterTextIntoSearchBar(AccessibilityStrings.SpotHero)
        tester().tapViewWithAccessibilityLabel(self.spotHeroAddress)
        tester().waitForViewWithAccessibilityLabel(LocalizedStrings.SearchSpots)
        
        //WHEN: I tap clear text
        tester().tapViewWithAccessibilityLabel(AccessibilityStrings.ClearText)
        
        //THEN: The search spots button is hidden
        tester().waitForAbsenceOfViewWithAccessibilityLabel(LocalizedStrings.SearchSpots)
    }
    
    func testTappingSearchSpotsShowsCollapsedSearchBar() {
        //GIVEN: I see the map view
        //WHEN: I search for an address
        self.enterTextIntoSearchBar(AccessibilityStrings.SpotHero)
        tester().tapViewWithAccessibilityLabel(self.spotHeroAddress)
        
        //WHEN: I tap the search spots button
        tester().tapViewWithAccessibilityLabel(LocalizedStrings.SearchSpots)
        
        //THEN: I see the collapsed search bar
        tester().waitForViewWithAccessibilityLabel(AccessibilityStrings.CollapsedSearchBarView)
        tester().waitForAbsenceOfViewWithAccessibilityLabel(AccessibilityStrings.TimeSelectionView)
        tester().waitForAbsenceOfViewWithAccessibilityLabel(LocalizedStrings.SearchSpots)
        
        //reset state
        tester().tapViewWithAccessibilityLabel(AccessibilityStrings.CollapsedSearchBarView)
        tester().tapViewWithAccessibilityLabel(AccessibilityStrings.ClearText)
        tester().waitForAbsenceOfViewWithAccessibilityLabel(LocalizedStrings.SearchSpots)
    }
    
    func testTappingCollapsedSearchBarShowsTimeSelectionView() {
        //GIVEN: I see the collapsed search bar view
        self.enterTextIntoSearchBar(AccessibilityStrings.SpotHero)
        tester().tapViewWithAccessibilityLabel(self.spotHeroAddress)
        tester().tapViewWithAccessibilityLabel(LocalizedStrings.SearchSpots)
        tester().waitForViewWithAccessibilityLabel(AccessibilityStrings.CollapsedSearchBarView)
        
        //WHEN: I tap the collapsed search bar view
        tester().tapViewWithAccessibilityLabel(AccessibilityStrings.CollapsedSearchBarView)
        
        //THEN: I see the time selection view
        tester().waitForAbsenceOfViewWithAccessibilityLabel(AccessibilityStrings.CollapsedSearchBarView)
        tester().waitForViewWithAccessibilityLabel(AccessibilityStrings.TimeSelectionView)
        
        //reset state
        tester().tapViewWithAccessibilityLabel(AccessibilityStrings.ClearText)
        tester().waitForAbsenceOfViewWithAccessibilityLabel(LocalizedStrings.SearchSpots)
    }
}
