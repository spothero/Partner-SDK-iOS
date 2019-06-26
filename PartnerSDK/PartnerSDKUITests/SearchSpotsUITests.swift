//
//  SearchSpotsUITests.swift
//  SpotHero_iOS_Partner_SDK
//
//  Created by Husein Kareem on 8/10/16.
//  Copyright © 2016 SpotHero, Inc. All rights reserved.
//

import KIF
@testable import PartnerSDKDemo
@testable import SpotHero_iOS_Partner_SDK
import XCTest

class SearchSpotsUITests: BaseUITests {
    
    // MARK: Tests
    
    func testViewingSearchPage() {
        //GIVEN: I start the SDK
        //WHEN: I view the search page
        //THEN: I should see the default content
        self.tester().waitForView(withAccessibilityLabel: LocalizedStrings.ParkSmarter)
        self.tester().waitForView(withAccessibilityLabel: LocalizedStrings.SearchDetail)
        self.tester().waitForView(withAccessibilityLabel: LocalizedStrings.WhereAreYouGoing)
        
        //THEN: I should see the search input
        self.tester().waitForView(withAccessibilityLabel: AccessibilityStrings.SearchBar)
    }
    
    func skip_testSearchBarBecomesActive() {
        //GIVEN: I am on the search page
        //WHEN: I tapped the search bar
        self.tester().tapView(withAccessibilityLabel: AccessibilityStrings.SearchBar)
        //THEN: I should no longer see the default content
        self.tester().waitForAbsenceOfView(withAccessibilityLabel: LocalizedStrings.ParkSmarter)
        self.tester().waitForAbsenceOfView(withAccessibilityLabel: LocalizedStrings.SearchDetail)
        self.tester().waitForAbsenceOfView(withAccessibilityLabel: LocalizedStrings.WhereAreYouGoing)
        
        //THEN: I should not see the nav bar
        self.tester().waitForAbsenceOfView(withAccessibilityLabel: LocalizedStrings.BookParking)
    }
}
