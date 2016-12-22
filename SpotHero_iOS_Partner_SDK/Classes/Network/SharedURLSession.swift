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
    
    var session: NSURLSession = {
        let defaultConfiguration = NSURLSessionConfiguration.defaultSessionConfiguration()
        let session = NSURLSession(configuration: defaultConfiguration)
        return session
    }()
    
    func updateManagerWithConfiguration(configuration: NSURLSessionConfiguration) {
        self.session = NSURLSession(configuration: configuration)
    }
    
    func useURLProtocols(protocols: [AnyClass]?) {
        self.session.configuration.protocolClasses = protocols
    }
}
