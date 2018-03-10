//
//  SpotCardsUITests.swift
//  SpotHero_iOS_Partner_SDK
//
//  Created by SpotHeroMatt on 1/11/17.
//  Copyright © 2017 SpotHero, Inc. All rights reserved.
//

import KIF
@testable import SpotHero_iOS_Partner_SDK
@testable import SpotHero_iOS_Partner_SDK_Example
import XCTest

class SpotCardsUITests: BaseUITests {
    
    private func showSpotCards() {
        self.enterTextIntoSearchBar("Chicago", expectedText: "Chicago")
        
        guard let predictionTableView = tester().waitForView(withAccessibilityLabel: AccessibilityStrings.PredictionTableView) as? UITableView else {
            XCTFail("Cannot get predictions")
            return
        }
        
        tester().tapRow(at: IndexPath(row: 0, section: 0), in: predictionTableView)
        tester().tapView(withAccessibilityLabel: LocalizedStrings.SearchSpots)
    }
    
    func skip_testShowSpotCards() {
        //GIVEN: I enter a place into the search bar and select a place
        //WHEN: I search for spots
        self.showSpotCards()
        
        //THEN: I see the spot cards
        tester().waitForView(withAccessibilityLabel: AccessibilityStrings.SpotCards)
    }
    
    func skip_testSwipingThroughSpotCards() {
        //GIVEN: I enter a place into the search bar and select a place
        self.showSpotCards()
        
        //WHEN: I swipe the spot cards collection view left
        guard let spotCardsCollectionView = tester().waitForView(withAccessibilityLabel: AccessibilityStrings.SpotCards) as? UICollectionView else {
            XCTFail("Cannot get spot cards")
            return
        }
        
        //TODO: Find out why we have to wait to swipe the cell
        tester().wait(forTimeInterval: 5)
        tester().swipeView(withAccessibilityLabel: AccessibilityStrings.SpotCards, in: .left)
        
        //THEN: The first cell should be inactive
        let indexPathForFirstCell = IndexPath(row: 0, section: 0)
        guard let firstCell = spotCardsCollectionView.cellForItem(at: indexPathForFirstCell) as? SpotCardCollectionViewCell else {
            XCTFail("Cannot get active spot card cell")
            return
        }
        
        //Commented for now since buy button is private
//        XCTAssertFalse(firstCell.buyButton.isEnabled)
        
        //THEN: The second cell should be active
        let indexPathForSecondCell = IndexPath(row: 1, section: 0)
        guard let secondCell = spotCardsCollectionView.cellForItem(at: indexPathForSecondCell) as? SpotCardCollectionViewCell else {
            XCTFail("Cannot get active spot card cell")
            return
        }
        
        //Commented for now since buy button is private
//        XCTAssert(secondCell.buyButton.isEnabled)
    }
    
    func skip_testBookItButton() {
        //GIVEN: I enter a place into the search bar and select a place
        self.showSpotCards()
        
        //WHEN: I see the spot cards and tap the book it button
        tester().waitForView(withAccessibilityLabel: AccessibilityStrings.SpotCards)
        tester().tapView(withAccessibilityLabel: LocalizedStrings.BookSpot)
        
        //THEN: I see the checkout screen
        tester().waitForView(withAccessibilityLabel: AccessibilityStrings.CheckoutScreen)
    }
}
