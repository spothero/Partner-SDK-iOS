//
//  HTTPSessionManager+Mock.swift
//  SpotHero_iOS_Partner_SDK
//
//  Created by Matthew Reed on 7/21/16.
//  Copyright © 2016 SpotHero, Inc. All rights reserved.
//

import Foundation
import VOKMockUrlProtocol

@testable import SpotHero_iOS_Partner_SDK

extension SpotHeroPartnerAPIController {
    /**
     Starts rerouting all HTTP requests made through the Swift API to disk.
     - parameter bundle: Bundle to use
     */
    static func sph_startUsingMockData(bundle: NSBundle) {
        let mockConfig = NSURLSessionConfiguration.defaultSessionConfiguration()
        let mockURLProtocolClass = VOKMockUrlProtocol.self
        
        var urlProtocolsToUse: [AnyClass]
        if let currentURLProtocols = mockConfig.protocolClasses {
            urlProtocolsToUse = currentURLProtocols
        } else {
            urlProtocolsToUse = [AnyClass]()
        }
        
        urlProtocolsToUse.insert(mockURLProtocolClass, atIndex: 0)
        mockConfig.protocolClasses = urlProtocolsToUse
        
        //Need to pass in the test bundle since HTTPSessionManager is in the main bundle,
        //and VOKMockUrlProtocol needs to look in the test bundle.
        
        VOKMockUrlProtocol.setTestBundle(bundle)
        
        self.updateManagerWithConfiguration(mockConfig)
    }
    
    /**
     Stops rerouting all HTTP requests made through the Swift API to disk.
     */
    static func sph_stopUsingMockData() {
        let defaultConfig = NSURLSessionConfiguration.defaultSessionConfiguration()
        self.updateManagerWithConfiguration(defaultConfig)
    }
}
