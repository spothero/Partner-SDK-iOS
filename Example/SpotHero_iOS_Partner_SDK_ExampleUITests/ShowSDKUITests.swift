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

class ShowSDKUITests: BaseUITests {
    
    func testLaunchSDKShowsMapView() {
        tester().waitForViewWithAccessibilityLabel(LocalizedStrings.FindParking)
        tester().waitForViewWithAccessibilityLabel(LocalizedStrings.Close)
        tester().waitForViewWithAccessibilityLabel(AccessibilityStrings.MapView)
    }
    
}
