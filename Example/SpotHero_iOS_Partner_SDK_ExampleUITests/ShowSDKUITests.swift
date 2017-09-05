//
//  ShowSDKUITests.swift
//  SpotHero_iOS_Partner_SDK_ExampleUITests
//
//  Created by Ellen Shapiro (Work) on 6/29/16.
//  Copyright © 2016 SpotHero, Inc. All rights reserved.
//

import KIF
@testable import SpotHero_iOS_Partner_SDK
@testable import SpotHero_iOS_Partner_SDK_Example
import XCTest

class ShowSDKUITests: BaseUITests {
    
    func testLaunchSDKShowsMapView() {
        tester().waitForView(withAccessibilityLabel: LocalizedStrings.FindParking)
        tester().waitForView(withAccessibilityLabel: LocalizedStrings.Close)
        tester().waitForView(withAccessibilityLabel: AccessibilityStrings.MapView)
    }
    
}
