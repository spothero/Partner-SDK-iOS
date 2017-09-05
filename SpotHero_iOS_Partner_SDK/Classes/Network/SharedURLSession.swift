//
//  SHURLSession.swift
//  Pods
//
//  Created by Matthew Reed on 12/22/16.
//
//

import Foundation

class SharedURLSession {
    static let sharedInstance = SharedURLSession()
    
    var session: URLSession = {
        let defaultConfiguration = URLSessionConfiguration.default
        let session = URLSession(configuration: defaultConfiguration)
        return session
    }()
    
    func updateManagerWithConfiguration(configuration: URLSessionConfiguration) {
        self.session = URLSession(configuration: configuration)
    }
    
    func useURLProtocols(protocols: [AnyClass]?) {
        self.session.configuration.protocolClasses = protocols
    }
}
