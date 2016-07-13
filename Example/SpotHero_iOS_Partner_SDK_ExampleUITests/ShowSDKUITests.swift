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
        tester().tapViewWithAccessibilityLabel(LocalizedStrings.LaunchSDK)
    }
    
    override func afterEach() {
        super.afterEach()
        tester().tapViewWithAccessibilityLabel(LocalizedStrings.Close)
    }
    
    func testLaunchSDKShowsMapView() {
        tester().waitForViewWithAccessibilityLabel(LocalizedStrings.FindParking)
        tester().waitForViewWithAccessibilityLabel(LocalizedStrings.Close)
        tester().waitForViewWithAccessibilityLabel(AccessibilityStrings.MapView)
    }
    
}
