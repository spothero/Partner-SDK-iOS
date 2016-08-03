//
//  BaseUITests.swift
//  SpotHero_iOS_Partner_SDK
//
//  Created by Matthew Reed on 7/15/16.
//  Copyright © 2016 SpotHero, Inc. All rights reserved.
//

import XCTest
import KIF
@testable import SpotHero_iOS_Partner_SDK_Example
@testable import SpotHero_iOS_Partner_SDK

class BaseUITests: KIFTestCase {
        
    override func beforeEach() {
        super.beforeEach()
        tester().tapViewWithAccessibilityLabel(LocalizedStrings.LaunchSDK)
    }
    
    override func afterEach() {
        super.afterEach()
        tester().tapViewWithAccessibilityLabel(LocalizedStrings.Close)
    }
    
}
