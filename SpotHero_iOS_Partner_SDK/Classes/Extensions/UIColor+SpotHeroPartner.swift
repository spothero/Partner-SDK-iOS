//
//  UIColor+SpotHeroPartner.swift
//  Pods
//
//  Created by Ellen Shapiro (Work) on 6/29/16.
//
//

import UIKit

/// Convenience color generation. 
public extension UIColor {
    
    private static func shp_colorWithRed(red: CGFloat,
                                  green: CGFloat,
                                  blue: CGFloat,
                                  alpha: CGFloat = 1) -> UIColor {
    
        return UIColor(red: red / 255.0,
                       green: green / 255.0,
                       blue: blue / 255.0,
                       alpha: alpha)
    }
    
    /**
     - returns: SpotHero-Branded blue.
     */
    public static func shp_spotHeroBlue() -> UIColor {
        return .shp_colorWithRed(20,
                                 green: 89,
                                 blue: 255)
    }
    
    static func shp_green() -> UIColor {
        return .shp_colorWithRed(38,
                                 green: 153,
                                 blue: 3)
    }
    
    static func shp_mutedGreen() -> UIColor {
        return .shp_colorWithRed(146,
                                 green: 204,
                                 blue: 128)
    }
    
    static func shp_lightGray() -> UIColor {
        return UIColor(white: 0.9, alpha: 1)
    }

}
