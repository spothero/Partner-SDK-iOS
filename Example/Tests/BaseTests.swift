//
//  BaseTests.swift
//  SpotHero_iOS_Partner_SDK
//
//  Created by SpotHeroMatt on 8/1/16.
//  Copyright © 2016 SpotHero, Inc. All rights reserved.
//

import XCTest

class BaseTests: XCTestCase {
    let testEmail = "matt@gmail.com"
    
    var testEmailRandom: String {
        let rand = arc4random_uniform(100000)
        return "matt\(rand)@test.com"
    }
}
