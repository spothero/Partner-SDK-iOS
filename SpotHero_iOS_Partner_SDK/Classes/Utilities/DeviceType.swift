//
//  DeviceType.swift
//  SpotHero_iOS_Partner_SDK
//
//  Created by Matt on 2/26/18.
//

import Foundation

struct DeviceType {
    static var Screen = UIScreen.main
    
    /// Small phone height in points (iPhone 5, SE, or iPhone 7 in "zoomed" mode)
    private static let SmallHeight: CGFloat = 568
    
    /// Medium phone height in points (iPhone 7, or plus-sized phone in "zoomed" mode)
    private static let NormalHeight: CGFloat = 667
    
    /// Plus-sized phone height in points (iPhone 7+)
    private static let LargeHeight: CGFloat = 736
    
    /// iPhone X height in points
    private static let iPhoneXHeight: CGFloat = 812
    
    /// - Returns: true if the device's screen size looks like an iphone 5, false for anything else
    public static func isEqualOrLessThanIphone5() -> Bool {
        return self.Screen.bounds.height <= self.SmallHeight
    }
    
    /// - Returns: true if the device's screen looks like a plus sized (large screen) phone
    public static func isPlusSized() -> Bool {
        let height = self.Screen.bounds.height
        //add a max height so we don't get iPads by mistake
        return height > self.NormalHeight && height <= self.LargeHeight
    }
    
    /// - Returns: true if the device's screen looks like the iPhone X
    public static func isIPhoneX() -> Bool {
        let height = self.Screen.bounds.height
        //add a max height so we don't get iPads by mistake
        return height > self.LargeHeight && height <= self.iPhoneXHeight
    }
}
