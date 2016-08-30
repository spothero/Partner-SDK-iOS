//
//  NSBundle+SpotHeroPartner.swift
//  Pods
//
//  Created by SpotHeroMatt on 8/26/16.
//
//

import Foundation

extension NSBundle {
    static func shp_resourceBundle() -> NSBundle {
        let frameworkBundle = NSBundle(forClass: SpotHeroPartnerSDK.self)
        let resourceUrl = frameworkBundle.resourceURL?.URLByAppendingPathComponent("SpotHero_iOS_Partner_SDK.bundle")
        if let resourceUrl = resourceUrl, resourceBundle = NSBundle(URL: resourceUrl) {
            return resourceBundle
        } else {
            assertionFailure("Cannot get resource bundle!")
            return frameworkBundle
        }
    }
}
