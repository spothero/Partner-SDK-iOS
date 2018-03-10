//
//  GooglePlacesUITests.swift
//  SpotHero_iOS_Partner_SDK
//
//  Created by Matthew Reed on 7/15/16.
//  Copyright © 2016 SpotHero, Inc. All rights reserved.
//

import KIF
@testable import SpotHero_iOS_Partner_SDK
@testable import SpotHero_iOS_Partner_SDK_Example
import XCTest

class GooglePlacesUITests: BaseUITests {
    let indexPath = IndexPath(row: 0, section: 0)
    
    func skip_testGetPredictions() {
        //GIVEN: I see the search bar and type in an address
        self.enterTextIntoSearchBar(AccessibilityStrings.SpotHero)

        //THEN: I see a table with predictions
        guard let tableView = tester().waitForView(withAccessibilityLabel: AccessibilityStrings.PredictionTableView) as? UITableView else {
            XCTFail("No Prediction table view")
            return
        }
        
        guard let cell = tester().waitForCell(at: indexPath, in: tableView) as? PredictionTableViewCell else {
            XCTFail("No Cells in table view")
            return
        }
        
        //THEN: The cell has an address in it
        XCTAssertNotNil(cell.addressLabel.text)
        XCTAssertNotNil(cell.cityLabel.text)
    }
    
    func skip_testTapAPlace() {
        //GIVEN: I see the search bar and type in an address
        self.enterTextIntoSearchBar(AccessibilityStrings.SpotHero)

        //WHEN: I see a table with predictions and tap a row
        guard let tableView = tester().waitForView(withAccessibilityLabel: AccessibilityStrings.PredictionTableView) as? UITableView else {
            XCTFail("No Prediction table view")
            return
        }
        
        tester().tapRow(at: indexPath, in: tableView)
        
        //THEN: The tableview collapses so it is no longer visible
        XCTAssertEqual(tableView.frame.height, 0)
        
        //THEN: The search bar has the address in it
        guard let searchBar = tester().waitForView(withAccessibilityLabel: AccessibilityStrings.SearchBar) as? UISearchBar else {
            XCTFail("Search bar is not visible")
            return
        }
        
        XCTAssertNotNil(searchBar.text)
    }
    
    func skip_testNoPredictions() {
        //GIVEN: I see the search bar and type in gibberish
        self.enterTextIntoSearchBar("Fjndahdaosdahffsvoafifjnansfjwvauis")

        //When: I see a table with no predictions
        guard let tableView = tester().waitForView(withAccessibilityLabel: AccessibilityStrings.PredictionTableView) as? UITableView else {
            XCTFail("No Prediction table view")
            return
        }
        
        tester().wait(forTimeInterval: self.waitTime)
        
        //THEN: The table view should collapse
        XCTAssertEqual(tableView.frame.height, 0)
    }
    
    func skip_testDeleteText() {
        //GIVEN: I see the search bar and begin typing
        self.enterTextIntoSearchBar("Chicago")
        
        //WHEN: I see a table view
        guard let tableView = tester().waitForView(withAccessibilityLabel: AccessibilityStrings.PredictionTableView) as? UITableView else {
            XCTFail("No Prediction table view")
            return
        }
        
        tester().wait(forTimeInterval: self.waitTime)
        
        //THEN: The table should be expanded
        XCTAssertNotEqual(tableView.frame.height, 0)
        
        //WHEN: I delete the text
        tester().clearTextFromFirstResponder()
        tester().wait(forTimeInterval: self.waitTime)
        
        //THEN: The table view should collapse
        XCTAssertEqual(tableView.frame.height, 0)
    }
}
