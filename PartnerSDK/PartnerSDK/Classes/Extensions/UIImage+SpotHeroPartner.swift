//
//  UIImage+SpotHeroPartner.swift
//  SpotHero_iOS_Partner_SDK
//
//  Created by Matthew Reed on 12/7/17.
//

import UIKit

extension UIImage {
    convenience init?(shp_named name: String) {
        self.init(named: name,
                  in: Bundle.shp_resourceBundle(),
                  compatibleWith: nil)
    }
}
