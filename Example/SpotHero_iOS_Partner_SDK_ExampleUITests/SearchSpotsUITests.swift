//
//  SearchSpotsUITests.swift
//  SpotHero_iOS_Partner_SDK
//
//  Created by Husein Kareem on 8/10/16.
//  Copyright © 2016 SpotHero, Inc. All rights reserved.
//

import KIF
@testable import SpotHero_iOS_Partner_SDK
@testable import SpotHero_iOS_Partner_SDK_Example
import XCTest

class SearchSpotsUITests: BaseUITests {
    
    fileprivate let spotHeroAddress = "SpotHero, West Huron Street, Chicago, IL"
    
    //MARK: Helpers
    
    fileprivate func validateStartEndViewSelectedState() {
        let timeSelectionView = tester().waitForView(withAccessibilityLabel: AccessibilityStrings.TimeSelectionView) as? TimeSelectionView
        XCTAssertNotEqual(timeSelectionView?.endViewSelected, timeSelectionView?.startViewSelected)
    }
    
    fileprivate func dismissStartView() {
        let timeSelectionView = tester().waitForView(withAccessibilityLabel: AccessibilityStrings.TimeSelectionView) as? TimeSelectionView
        tester().tapView(withAccessibilityLabel: LocalizedStrings.Done)
        XCTAssertEqual(false, timeSelectionView?.startViewSelected)
        tester().tapView(withAccessibilityLabel: LocalizedStrings.Done)
        XCTAssertEqual(false, timeSelectionView?.endViewSelected)
    }
    
    fileprivate func dismissEndView() {
        let timeSelectionView = tester().waitForView(withAccessibilityLabel: AccessibilityStrings.TimeSelectionView) as? TimeSelectionView
        tester().tapView(withAccessibilityLabel: LocalizedStrings.Done)
        XCTAssertEqual(false, timeSelectionView?.startViewSelected)
        XCTAssertEqual(false, timeSelectionView?.endViewSelected)
    }
    
    //MARK: Tests
    
    func testTypingAddressHidesTimeSelectionView() {
        //GIVEN: I see the map view
        //WHEN: I tap on the search bar and type an address
        self.enterTextIntoSearchBar(AccessibilityStrings.SpotHero)
        
        //THEN: The time selection view is hidden
        tester().waitForAbsenceOfView(withAccessibilityLabel: AccessibilityStrings.TimeSelectionView)
        
        tester().tapView(withAccessibilityLabel: AccessibilityStrings.ClearText)
    }
    
    func testTappingStartsViewShowsStartDatePickerView() {
        //GIVEN: I see the map view
        //WHEN: I tap on the starts view
        tester().tapView(withAccessibilityLabel: AccessibilityStrings.StartsTimeSelectionView)
        
        //THEN: I see the start date picker view
        tester().waitForView(withAccessibilityLabel: LocalizedStrings.SetStartTime)
        tester().waitForView(withAccessibilityLabel: LocalizedStrings.Done)
        self.validateStartEndViewSelectedState()
        
        self.dismissStartView()
    }
    
    func testTappingEndsViewShowsEndDatePickerView() {
        //GIVEN: I see the map view
        //WHEN: I tap on the ends view
        tester().tapView(withAccessibilityLabel: AccessibilityStrings.EndsTimeSelectionView)
        
        //THEN: I see the end date picker view
        tester().waitForView(withAccessibilityLabel: LocalizedStrings.SetEndTime)
        tester().waitForView(withAccessibilityLabel: LocalizedStrings.Done)
        self.validateStartEndViewSelectedState()
        
        self.dismissEndView()
    }
    
    func testSelectingAddressShowsSearchSpotsButton() {
        //GIVEN: I see the map view
        //WHEN: I search for an address
        self.enterTextIntoSearchBar(AccessibilityStrings.SpotHero)
        tester().tapView(withAccessibilityLabel: self.spotHeroAddress)
        
        //THEN: I see the search spots button
        tester().waitForView(withAccessibilityLabel: LocalizedStrings.SearchSpots)
        
        tester().tapView(withAccessibilityLabel: AccessibilityStrings.ClearText)
    }
    
    func testClearingTextHidesSearchSpotsButton() {
        //GIVEN: I see the map view
        //WHEN: I search for an address
        self.enterTextIntoSearchBar(AccessibilityStrings.SpotHero)
        tester().tapView(withAccessibilityLabel: self.spotHeroAddress)
        tester().waitForView(withAccessibilityLabel: LocalizedStrings.SearchSpots)
        
        //WHEN: I tap clear text
        tester().tapView(withAccessibilityLabel: AccessibilityStrings.ClearText)
        
        //THEN: The search spots button is hidden
        tester().waitForAbsenceOfView(withAccessibilityLabel: LocalizedStrings.SearchSpots)
    }
    
    func testTappingSearchSpotsShowsCollapsedSearchBar() {
        //GIVEN: I see the map view
        //WHEN: I search for an address
        self.enterTextIntoSearchBar(AccessibilityStrings.SpotHero)
        tester().tapView(withAccessibilityLabel: self.spotHeroAddress)
        
        //WHEN: I tap the search spots button
        tester().tapView(withAccessibilityLabel: LocalizedStrings.SearchSpots)
        
        //THEN: I see the collapsed search bar
        tester().waitForView(withAccessibilityLabel: AccessibilityStrings.CollapsedSearchBarView)
        tester().waitForAbsenceOfView(withAccessibilityLabel: AccessibilityStrings.TimeSelectionView)
        tester().waitForAbsenceOfView(withAccessibilityLabel: LocalizedStrings.SearchSpots)
        
        //reset state
        tester().tapView(withAccessibilityLabel: AccessibilityStrings.CollapsedSearchBarView)
        tester().tapView(withAccessibilityLabel: AccessibilityStrings.ClearText)
        tester().waitForAbsenceOfView(withAccessibilityLabel: LocalizedStrings.SearchSpots)
    }
    
    func testTappingCollapsedSearchBarShowsTimeSelectionView() {
        //GIVEN: I see the collapsed search bar view
        self.enterTextIntoSearchBar(AccessibilityStrings.SpotHero)
        tester().tapView(withAccessibilityLabel: self.spotHeroAddress)
        tester().tapView(withAccessibilityLabel: LocalizedStrings.SearchSpots)
        tester().waitForView(withAccessibilityLabel: AccessibilityStrings.CollapsedSearchBarView)
        
        //WHEN: I tap the collapsed search bar view
        tester().tapView(withAccessibilityLabel: AccessibilityStrings.CollapsedSearchBarView)
        
        //THEN: I see the time selection view
        tester().waitForAbsenceOfView(withAccessibilityLabel: AccessibilityStrings.CollapsedSearchBarView)
        tester().waitForView(withAccessibilityLabel: AccessibilityStrings.TimeSelectionView)
        
        //reset state
        tester().tapView(withAccessibilityLabel: AccessibilityStrings.ClearText)
        tester().waitForAbsenceOfView(withAccessibilityLabel: LocalizedStrings.SearchSpots)
    }
    
    func testCollapseSearchBarOnMapTap() {
        //GIVEN: I see the collapsed search bar view
        self.enterTextIntoSearchBar(AccessibilityStrings.SpotHero)
        tester().tapView(withAccessibilityLabel: self.spotHeroAddress)
        tester().tapView(withAccessibilityLabel: LocalizedStrings.SearchSpots)
        tester().waitForView(withAccessibilityLabel: AccessibilityStrings.CollapsedSearchBarView)
        
        //WHEN: I tap the collapsed search bar view
        tester().tapView(withAccessibilityLabel: AccessibilityStrings.CollapsedSearchBarView)
        
        //WHEN: I tap the map
        tester().wait(forTimeInterval: self.waitTime)
        tester().tapView(withAccessibilityLabel: AccessibilityStrings.MapView)
        
        //THEN: I see the collapsed search bar view
        tester().waitForView(withAccessibilityLabel: AccessibilityStrings.CollapsedSearchBarView)
        
        //reset state
        tester().tapView(withAccessibilityLabel: AccessibilityStrings.CollapsedSearchBarView)
        tester().tapView(withAccessibilityLabel: AccessibilityStrings.ClearText)
        tester().waitForAbsenceOfView(withAccessibilityLabel: LocalizedStrings.SearchSpots)
    }
}
