//  swiftlint:disable:this file_name
//  NSBundle+SpotHeroPartner.swift
//  Pods
//
//  Created by SpotHeroMatt on 8/26/16.
//
//

import Foundation

extension Bundle {
    static func shp_resourceBundle() -> Bundle {
        return Bundle(for: SpotHeroPartnerSDK.self)
    }
}
