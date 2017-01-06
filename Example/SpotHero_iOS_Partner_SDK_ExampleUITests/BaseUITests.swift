//
//  BaseUITests.swift
//  SpotHero_iOS_Partner_SDK
//
//  Created by Matthew Reed on 7/15/16.
//  Copyright © 2016 SpotHero, Inc. All rights reserved.
//

import XCTest
import VOKMockUrlProtocol
import KIF

@testable import SpotHero_iOS_Partner_SDK_Example
@testable import SpotHero_iOS_Partner_SDK

class BaseUITests: KIFTestCase {
    let waitTime: NSTimeInterval = 2
    
    override func beforeAll() {
        super.beforeAll()
        
        //Test Go Fast Now!
        UIApplication.sharedApplication().keyWindow?.layer.speed = 50
        
        tester().tapViewWithAccessibilityLabel(LocalizedStrings.LaunchSDK)
        tester().waitForViewWithAccessibilityLabel(LocalizedStrings.FindParking)
    }
    
    override func afterAll() {
        super.afterAll()
        tester().tapViewWithAccessibilityLabel(LocalizedStrings.Close)
        tester().waitForViewWithAccessibilityLabel(LocalizedStrings.LaunchSDK)
    }
    
    override func setUp() {
        super.setUp()
        let testBundle = NSBundle(forClass: BaseUITests.self)
        SharedURLSession.sharedInstance.sph_startUsingMockData(testBundle)
    }
    
    override func tearDown() {
        SharedURLSession.sharedInstance.sph_stopUsingMockData()
        super.tearDown()
    }
    
    func enterTextIntoSearchBar(text: String, expectedText: String? = nil) {
        tester().clearTextFromAndThenEnterText(text,
                                               intoViewWithAccessibilityLabel: AccessibilityStrings.SearchBar,
                                               traits: UIAccessibilityTraitNone,
                                               expectedResult: expectedText ?? text)
    }
    
}
