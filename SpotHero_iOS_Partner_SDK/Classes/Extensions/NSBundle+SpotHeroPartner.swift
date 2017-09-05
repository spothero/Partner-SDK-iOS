//
//  NSBundle+SpotHeroPartner.swift
//  Pods
//
//  Created by SpotHeroMatt on 8/26/16.
//
//

import Foundation

extension Bundle {
    static func shp_resourceBundle() -> Bundle {
        let frameworkBundle = Bundle(for: SpotHeroPartnerSDK.self)
        let resourceUrl = frameworkBundle.resourceURL?.appendingPathComponent("SpotHero_iOS_Partner_SDK.bundle")
        if
            let resourceUrl = resourceUrl,
            let resourceBundle = Bundle(url: resourceUrl) {
                return resourceBundle
        } else {
            assertionFailure("Cannot get resource bundle!")
            return frameworkBundle
        }
    }
}
