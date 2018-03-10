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
    
    private static func shp_colorWith(red: CGFloat,
                                      green: CGFloat,
                                      blue: CGFloat,
                                      alpha: CGFloat = 1) -> UIColor {
    
        return UIColor(red: red / 255.0,
                       green: green / 255.0,
                       blue: blue / 255.0,
                       alpha: alpha)
    }
    
    private static func shp_colorWith(white: CGFloat, alpha: CGFloat = 1) -> UIColor {
        return .shp_colorWith(red: white,
                              green: white,
                              blue: white,
                              alpha: alpha)
    }
    
    // swiftlint:disable variable_name
    
    // MARK: Brand Colors
    static var shp_shift: UIColor {
        return .shp_colorWith(red: 1,
                              green: 130,
                              blue: 255)
    }
    
    static var shp_tire: UIColor {
        return .shp_colorWith(white: 33)
    }
    
    static var shp_go: UIColor {
        return .shp_colorWith(red: 29,
                              green: 189,
                              blue: 113)
    }
    
    static var shp_cement: UIColor {
        return .shp_colorWith(red: 92,
                              green: 121,
                              blue: 150)
    }
    
    static var shp_pavement: UIColor {
        return .shp_colorWith(red: 203,
                              green: 212,
                              blue: 222)
    }
    
    static var shp_gravel: UIColor {
        return .shp_colorWith(red: 243,
                              green: 245,
                              blue: 247)
    }
    
    // MARK: Error Colors
    static var shp_stop: UIColor {
        return .shp_colorWith(red: 237,
                              green: 51,
                              blue: 84)
    }
    
    static var shp_reflector: UIColor {
        return UIColor
            .shp_stop
            .withAlphaComponent(0.24)
    }
    
    // MARK: Typography Colors
    static var shp_primary: UIColor {
        return .shp_tire
    }
    
    static var shp_secondary: UIColor {
        return .shp_cement
    }
    
    static var shp_disabled: UIColor {
        return .shp_pavement
    }
    
    static var shp_link: UIColor {
        return .shp_shift
    }
    
    // MARK: Input Colors
    
    static var shp_input: UIColor {
        return shp_pavement
    }
    
    static var shp_inputActive: UIColor {
        return .shp_shift
    }
    
    static var shp_inputError: UIColor {
        return .shp_stop
    }
    
    // MARK: Button Colors
    
    static var shp_primaryButtonBackground: UIColor {
        return .shp_shift
    }
    
    static var shp_primaryButtonDisabledBackground: UIColor {
        return .shp_pavement
    }
    
    static var shp_secondaryButtonText: UIColor {
        return .shp_shift
    }
    
    static var shp_secondaryButtonDisabledText: UIColor {
        return .shp_pavement
    }
    
    static var shp_secondaryButtonBorder: UIColor {
        return .shp_pavement
    }
    
    // swiftlint:enable variable_name
}
