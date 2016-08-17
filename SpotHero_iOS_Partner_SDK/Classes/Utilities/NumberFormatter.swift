//
//  NumberFormatter.swift
//  SpotHero
//
//  Created by Husein Kareem on 5/12/16.
//
//

import Foundation

class NumberFormatter: NSObject {
    
    static let PaddingFormatter: NSNumberFormatter = {
        let formatter = NSNumberFormatter()
        formatter.paddingPosition = NSNumberFormatterPadPosition.BeforePrefix
        formatter.paddingCharacter = "0"
        formatter.minimumIntegerDigits = 2
        return formatter
    }()
    
    static let USDNoCentsCurrencyFormatter: NSNumberFormatter = {
        let formatter = NSNumberFormatter()
        formatter.numberStyle = .CurrencyStyle
        formatter.currencySymbol = "$"
        formatter.currencyCode = "USD"
        formatter.maximumFractionDigits = 0
        return formatter
    }()
    
    /**
     Turns a number of cents into number of dollars, rounded to the lowest dollar and
     without any cents showing. For example, passing in 299 would return $2, but 300
     would return $3
     
     - parameter cents: The number of cents to convert.
     
     - returns: The rounded dollar string with no decimals
     */
    static func dollarNoCentsStringFromCents(cents: Int) -> String? {
        let dollars = floorf(Float(cents) / Float(100))
        return USDNoCentsCurrencyFormatter.stringFromNumber(NSNumber(float: dollars))
    }
    
    static let USDCurrencyFormatter: NSNumberFormatter = {
        let formatter = NSNumberFormatter()
        formatter.numberStyle = .CurrencyStyle
        formatter.currencySymbol = "$"
        formatter.currencyCode = "USD"
        formatter.minimumFractionDigits = 0
        return formatter
    }()
    
    static let USDCurrencyFormatterAlwaysCents: NSNumberFormatter = {
        let formatter = NSNumberFormatter()
        formatter.numberStyle = .CurrencyStyle
        formatter.currencySymbol = "$"
        formatter.currencyCode = "USD"
        formatter.minimumFractionDigits = 2
        return formatter
    }()
    
    /**
     Turns a number of cents into number of dollars. For example, passing in
     300 would return $3, and 350 would return $3.50
     
     - parameter cents: The number of cents to convert.
     
     - returns: The dollar string, including decimals and a $ sign
     */
    static func dollarStringFromCents(cents: Int) -> String? {
        let dollars = NSNumber(float: (Float(cents) / Float(100)))
        
        if (cents % 100) == 0 {
            //Use a formatter that will truncate to 0 decimal places.
            return USDCurrencyFormatter.stringFromNumber(dollars)
        } else {
            //Use a formatter that forces 2 decimal places
            return USDCurrencyFormatterAlwaysCents.stringFromNumber(dollars)
        }
    }
    
    static let PercentageFormatter: NSNumberFormatter = {
        let formatter = NSNumberFormatter()
        formatter.numberStyle = NSNumberFormatterStyle.PercentStyle
        formatter.maximumFractionDigits = 1
        return formatter
    }()
    
    
    /**
     Takes a number and displays it as a percentage, for example 3 as 3%.
     
     - parameter number: The number to display as a percentage.
     
     - returns: The number as a string with the percent symbol.
     */
    static func numberAsPercentage(number: Float) -> String? {
        let percent = number / Float(100)
        return PercentageFormatter.stringFromNumber(NSNumber(float: percent))
    }
    
}
