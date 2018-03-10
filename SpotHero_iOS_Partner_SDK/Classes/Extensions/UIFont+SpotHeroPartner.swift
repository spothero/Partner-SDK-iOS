//
//  UIFont+SpotHeroPartner.swift
//  SpotHero_iOS_Partner_SDK
//
//  Created by Matthew Reed on 12/5/17.
//

import Foundation

enum FontName: String {
    case
    sfProDisplayLight = "SFProDisplay-Light",
    sfProDisplayRegular = "SFProDisplay-Regular",
    sfProTextSemibold = "SFProText-Semibold",
    sfProTextRegular = "SFProText-Regular",
    sfProTextMedium = "SFProText-Medium"
}

extension UIFont {
    static var FontsLoaded = false
    
    static func loadAllFontsIfNeeded() {
        guard !self.FontsLoaded else {
            return
        }
        
        let bundle = Bundle.shp_resourceBundle()
        //NOTE: Only OTF fonts are loaded here. Adjust as necessary if other font types are added
        if let fontURLs = bundle.urls(forResourcesWithExtension: "otf", subdirectory: nil) {
            let cfFontURLs: CFArray = fontURLs as CFArray
            //load them up so they can be used by UIFont(name:,size:)
            if !CTFontManagerRegisterFontsForURLs(cfFontURLs, .process, nil) {
                #if TARGET_INTERFACE_BUILDER
                    //IB doesn't seem to support loading fonts this way for IBDesignables, so no-op here instead of crashing
                #else
                    assertionFailure("Could not load fonts from UI bundle!")
                #endif
            }
            self.FontsLoaded = true
        }
    }
    
    // swiftlint:disable variable_name
    
    private static func shp_font(_ fontName: FontName, ofSize size: CGFloat) -> UIFont {
        guard let font = UIFont(name: fontName.rawValue, size: size) else {
            assertionFailure("Couldn't get font")
            return UIFont.systemFont(ofSize: size)
        }

        return font
    }
    
    static var shp_headline: UIFont {
        return .shp_font(.sfProDisplayLight, ofSize: 32)
    }
    
    static var shp_title: UIFont {
        return .shp_font(.sfProDisplayRegular, ofSize: 20)
    }
    
    static var shp_titleTwo: UIFont {
        return .shp_font(.sfProTextSemibold, ofSize: 18)
    }
    
    static var shp_subhead: UIFont {
        return .shp_font(.sfProTextRegular, ofSize: 16)
    }
    
    static var shp_subheadTwo: UIFont {
        return .shp_font(.sfProTextMedium, ofSize: 16)
    }
    
    static var shp_body: UIFont {
        return .shp_font(.sfProTextRegular, ofSize: 14)
    }
    
    static var shp_captionInput: UIFont {
        return .shp_font(.sfProTextRegular, ofSize: 12)
    }
    
    static var shp_error: UIFont {
        return .shp_font(.sfProTextRegular, ofSize: 14)
    }
    
    static var shp_button: UIFont {
        return .shp_font(.sfProTextSemibold, ofSize: 14)
    }
    
    static var shp_link: UIFont {
        return .shp_font(.sfProTextMedium, ofSize: 14)
    }
        
    // swiftlint:enable variable_name
    
    ///Estimate size for the string based on the font (Constrained to height)
    ///
    /// - parameter string: string to estimae size
    /// - parameter height:  max height
    ///
    /// - returns: CGsize for the string
    func shp_sizeOfString(_ string: String, constrainedToHeight height: CGFloat) -> CGSize {
        return NSString(string: string).boundingRect(with: CGSize(width: CGFloat.greatestFiniteMagnitude, height: height),
                                                     options: .usesLineFragmentOrigin,
                                                     attributes: [NSFontAttributeName: self],
                                                     context: nil).size
    }
}
