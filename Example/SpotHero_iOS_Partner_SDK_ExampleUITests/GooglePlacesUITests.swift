//
//  GooglePlacesUITests.swift
//  SpotHero_iOS_Partner_SDK
//
//  Created by Matthew Reed on 7/15/16.
//  Copyright © 2016 SpotHero, Inc. All rights reserved.
//

import XCTest
import KIF
@testable import SpotHero_iOS_Partner_SDK_Example
@testable import SpotHero_iOS_Partner_SDK

class GooglePlacesUITests: BaseUITests {
    let indexPath = NSIndexPath(forRow: 0, inSection: 0)
    
    func testGetPredictions() {
        //GIVEN: I see the search bar and type in an address
        self.enterTextIntoSearchBar(AccessibilityStrings.SpotHero)

        //THEN: I see a table with predictions
        guard let tableView = tester().waitForViewWithAccessibilityLabel(AccessibilityStrings.PredictionTableView) as? UITableView else {
            XCTFail("No Prediction table view")
            return
        }
        
        guard let cell = tester().waitForCellAtIndexPath(indexPath, inTableView: tableView) as? PredictionTableViewCell else {
            XCTFail("No Cells in table view")
            return
        }
        
        //THEN: The cell has an address in it
        XCTAssertNotNil(cell.addressLabel.text)
        XCTAssertNotNil(cell.cityLabel.text)
    }
    
    func testTapAPlace() {
        //GIVEN: I see the search bar and type in an address
        self.enterTextIntoSearchBar(AccessibilityStrings.SpotHero)

        //WHEN: I see a table with predictions and tap a row
        guard let tableView = tester().waitForViewWithAccessibilityLabel(AccessibilityStrings.PredictionTableView) as? UITableView else {
            XCTFail("No Prediction table view")
            return
        }
        
        tester().tapRowAtIndexPath(indexPath, inTableView: tableView)
        
        //THEN: The tableview collapses so it is no longer visible
        XCTAssertEqual(tableView.frame.height, 0)
        
        //THEN: The search bar has the address in it
        guard let searchBar = tester().waitForViewWithAccessibilityLabel(AccessibilityStrings.SearchBar) as? UISearchBar else {
            XCTFail("Search bar is not visible")
            return
        }
        
        XCTAssertNotNil(searchBar.text)
    }
    
    func testNoPredictions() {
        //GIVEN: I see the search bar and type in gibberish
        self.enterTextIntoSearchBar("Fjndahdaosdahffsvoafifjnansfjwvauis")

        //When: I see a table with no predictions
        guard let tableView = tester().waitForViewWithAccessibilityLabel(AccessibilityStrings.PredictionTableView) as? UITableView else {
            XCTFail("No Prediction table view")
            return
        }
        
        tester().waitForTimeInterval(self.waitTime)
        
        //THEN: The table view should collapse
        XCTAssertEqual(tableView.frame.height, 0)
    }
    
    func testDeleteText() {
        //GIVEN: I see the search bar and begin typing
        self.enterTextIntoSearchBar("Chicago")
        
        //WHEN: I see a table view
        guard let tableView = tester().waitForViewWithAccessibilityLabel(AccessibilityStrings.PredictionTableView) as? UITableView else {
            XCTFail("No Prediction table view")
            return
        }
        
        tester().waitForTimeInterval(self.waitTime)
        
        //THEN: The table should be expanded
        XCTAssertNotEqual(tableView.frame.height, 0)
        
        //WHEN: I delete the text
        tester().clearTextFromFirstResponder()
        tester().waitForTimeInterval(self.waitTime)
        
        //THEN: The table view should collapse
        XCTAssertEqual(tableView.frame.height, 0)
    }
}
