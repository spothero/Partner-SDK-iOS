//
//  TestingHelper.swift
//  Pods
//
//  Created by SpotHeroMatt on 12/22/16.
//
//

import Foundation

struct TestingHelper {
    
    /// Returns true if app is testing
    ///
    /// - Returns: Whether app is testing or not
    static func isTesting() -> Bool {
        return NSClassFromString("XCTest") != nil
    }
    
    
    /// Returns true if app is UITesting
    ///
    /// - Returns: Whether app is UITesting or not
    static func isUITesting() -> Bool {
        return NSClassFromString("KIFTestCase") != nil
    }
}
