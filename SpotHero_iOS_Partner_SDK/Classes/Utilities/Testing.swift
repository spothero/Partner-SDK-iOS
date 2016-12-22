//
//  Testing.swift
//  Pods
//
//  Created by SpotHeroMatt on 12/22/16.
//
//

import Foundation

struct Testing {
    static func isTesting() -> Bool {
        return NSClassFromString("XCTest") != nil
    }
    
    static func isUITesting() -> Bool {
        return NSClassFromString("KIFTestCase") != nil
    }
}
