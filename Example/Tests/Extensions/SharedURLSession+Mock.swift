//
//  HTTPSessionManager+Mock.swift
//  SpotHero_iOS_Partner_SDK
//
//  Created by Matthew Reed on 7/21/16.
//  Copyright © 2016 SpotHero, Inc. All rights reserved.
//

import Foundation
@testable import SpotHero_iOS_Partner_SDK
import VOKMockUrlProtocol

extension SharedURLSession {
    /**
     Starts rerouting all HTTP requests made through the Swift API to disk.
     - parameter bundle: Bundle to use
     */
    func sph_startUsingMockData(bundle: Bundle) {
        let mockConfig = URLSessionConfiguration.default
        let mockURLProtocolClass = VOKMockUrlProtocol.self
        
        var urlProtocolsToUse: [AnyClass]
        if let currentURLProtocols = mockConfig.protocolClasses {
            urlProtocolsToUse = currentURLProtocols
        } else {
            urlProtocolsToUse = [AnyClass]()
        }
        
        urlProtocolsToUse.insert(mockURLProtocolClass, at: 0)
        mockConfig.protocolClasses = urlProtocolsToUse
        
        //Need to pass in the test bundle since HTTPSessionManager is in the main bundle,
        //and VOKMockUrlProtocol needs to look in the test bundle.
        VOKMockUrlProtocol.setTest(bundle)
        
        self.updateManagerWithConfiguration(configuration: mockConfig)
    }
    
    /**
     Stops rerouting all HTTP requests made through the Swift API to disk.
     */
    func sph_stopUsingMockData() {
        let defaultConfig = URLSessionConfiguration.default
        self.updateManagerWithConfiguration(configuration: defaultConfig)
    }
}
