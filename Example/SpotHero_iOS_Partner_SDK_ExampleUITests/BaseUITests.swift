//
//  BaseUITests.swift
//  SpotHero_iOS_Partner_SDK
//
//  Created by Matthew Reed on 7/15/16.
//  Copyright © 2016 SpotHero, Inc. All rights reserved.
//

import KIF
@testable import SpotHero_iOS_Partner_SDK
@testable import SpotHero_iOS_Partner_SDK_Example
import VOKMockUrlProtocol
import XCTest

class BaseUITests: KIFTestCase {
    let waitTime: TimeInterval = 2
    
    override func beforeAll() {
        super.beforeAll()
        
        //Test Go Fast Now!
        UIApplication.shared.keyWindow?.layer.speed = 50
    }
    
    override func beforeEach() {
        super.beforeEach()
        tester().tapView(withAccessibilityLabel: LocalizedStrings.PresentSDK)
        tester().waitForView(withAccessibilityLabel: LocalizedStrings.BookParking)
    }
    
    override func afterEach() {
        super.afterEach()
        tester().tapView(withAccessibilityLabel: LocalizedStrings.Close)
        tester().waitForView(withAccessibilityLabel: LocalizedStrings.PresentSDK)
    }
    
    override func setUp() {
        super.setUp()
        let testBundle = Bundle(for: BaseUITests.self)
        SharedURLSession.sharedInstance.sph_startUsingMockData(bundle: testBundle)
    }
    
    override func tearDown() {
        SharedURLSession.sharedInstance.sph_stopUsingMockData()
        super.tearDown()
    }
    
    func enterTextIntoSearchBar(_ text: String, expectedText: String? = nil) {
        tester().clearText(fromAndThenEnterText: text,
                           intoViewWithAccessibilityLabel: AccessibilityStrings.SearchBar,
                           traits: .none,
                           expectedResult: expectedText ?? text)
    }
}
