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
    
    //MARK: Helpers
    
    
    //MARK: Tests
    
    func testViewingSearchPage() {
        //GIVEN: I start the SDK
        //WHEN: I view the search page
        //THEN: I should see the default content
        tester().waitForView(withAccessibilityLabel: LocalizedStrings.ParkSmarter)
        tester().waitForView(withAccessibilityLabel: LocalizedStrings.SearchDetail)
        tester().waitForView(withAccessibilityLabel: LocalizedStrings.WhereAreYouGoing)
        
        //THEN: I should see the search input
        tester().waitForView(withAccessibilityLabel: AccessibilityStrings.SearchBar)
    }
    
    func skip_testSearchBarBecomesActive() {
        //GIVEN: I am on the search page
        //WHEN: I tapped the search bar
        tester().tapView(withAccessibilityLabel: AccessibilityStrings.SearchBar)
        //THEN: I should no longer see the default content
        tester().waitForAbsenceOfView(withAccessibilityLabel: LocalizedStrings.ParkSmarter)
        tester().waitForAbsenceOfView(withAccessibilityLabel: LocalizedStrings.SearchDetail)
        tester().waitForAbsenceOfView(withAccessibilityLabel: LocalizedStrings.WhereAreYouGoing)
        
        //THEN: I should not see the nav bar
        tester().waitForAbsenceOfView(withAccessibilityLabel: LocalizedStrings.BookParking)
    }
    
    
}
