//
//  ShowSDKUITests.swift
//  SpotHero_iOS_Partner_SDK_ExampleUITests
//
//  Created by Ellen Shapiro (Work) on 6/29/16.
//  Copyright © 2016 SpotHero, Inc. All rights reserved.
//

import XCTest
import KIF
@testable import SpotHero_iOS_Partner_SDK_Example
@testable import SpotHero_iOS_Partner_SDK

class ShowSDKUITests: KIFTestCase {
    
    override func beforeEach() {
        super.beforeEach()
        tester().tapViewWithAccessibilityLabel(LocalizedStrings.launchSDK)
    }
    
    override func afterEach() {
        super.afterEach()
        tester().tapViewWithAccessibilityLabel(LocalizedStrings.close)
    }
    
    func testLaunchSDKShowsMapView() {
        tester().waitForViewWithAccessibilityLabel(LocalizedStrings.findParking)
        tester().waitForViewWithAccessibilityLabel(LocalizedStrings.close)
        tester().waitForViewWithAccessibilityLabel(AccessibilityStrings.mapView)
    }
    
}
