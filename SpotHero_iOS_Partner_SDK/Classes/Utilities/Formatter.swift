//
//  Formatter.swift
//  Pods
//
//  Created by Matthew Reed on 8/8/16.
//  Copyright © 2016 SpotHero. All rights reserved.
//

import Foundation

typealias Formatted = (formatted: String, unformatted: String)

enum Formatter {
    /**
     Formats a phone number like so: xxx-xxx-xxxx
     
     - parameter phone: Phone Number to format
     
     - returns: Tuple with formatted phone number and unformatted phone number
     */
    static func formatPhoneNumber(phone: String) -> Formatted {
        let unformatted = phone.stringByReplacingOccurrencesOfString("-", withString: "")
        
        if unformatted.characters.count > 3 {
            let startIndex = unformatted.startIndex
            let endIndex = unformatted.endIndex
            let firstSection = unformatted.substringWithRange(startIndex..<startIndex.advancedBy(3))
            
            switch unformatted.characters.count {
            case 4..<7:
                let secondSection = unformatted.substringWithRange(startIndex.advancedBy(3)..<endIndex)
                return ("\(firstSection)-\(secondSection)", unformatted)
            default:
                let secondSection = unformatted.substringWithRange(startIndex.advancedBy(3)..<startIndex.advancedBy(6))
                let thirdSection = unformatted.substringWithRange(startIndex.advancedBy(6)..<endIndex)
                return ("\(firstSection)-\(secondSection)-\(thirdSection)", unformatted)
            }
        }
        
        return (unformatted, unformatted)
    }
    
    /**
     Formats a credit card number like so: xxxx xxxx xxxx xxxx
     
     - parameter number: Credit card number to format
     
     - returns: Tuple with formatted credit card number and unformatted credit card number
     */
    static func formatCreditCard(number: String) -> Formatted {
        let unformatted = number.stringByReplacingOccurrencesOfString(" ", withString: "")
        
        if unformatted.characters.count > 4 {
            let startIndex = unformatted.startIndex
            let endIndex = unformatted.endIndex
            let firstSection = unformatted.substringWithRange(startIndex..<startIndex.advancedBy(4))
            
            switch unformatted.characters.count {
            case 5..<9:
                let secondSection = unformatted.substringWithRange(startIndex.advancedBy(4)..<endIndex)
                return ("\(firstSection) \(secondSection)", unformatted)
            case 9..<13:
                let secondSection = unformatted.substringWithRange(startIndex.advancedBy(4)..<startIndex.advancedBy(8))
                let thirdSection = unformatted.substringWithRange(startIndex.advancedBy(8)..<endIndex)
                return ("\(firstSection) \(secondSection) \(thirdSection)", unformatted)
            default:
                let secondSection = unformatted.substringWithRange(startIndex.advancedBy(4)..<startIndex.advancedBy(8))
                let thirdSection = unformatted.substringWithRange(startIndex.advancedBy(8)..<startIndex.advancedBy(12))
                let fourthSection = unformatted.substringWithRange(startIndex.advancedBy(12)..<endIndex)
                return ("\(firstSection) \(secondSection) \(thirdSection) \(fourthSection)", unformatted)
            }
        }
        
        return (unformatted, unformatted)
    }
    
    /**
     Formats an american express credit card number like so: xxxx xxxxxx xxxxx
     
     - parameter number: Credit card number to format
     
     - returns: Tuple with formatted credit card number and unformatted credit card number
     */
    static func formatCreditCardAmex(number: String) -> Formatted {
        let unformatted = number.stringByReplacingOccurrencesOfString(" ", withString: "")
        
        if unformatted.characters.count > 4 {
            let startIndex = unformatted.startIndex
            let endIndex = unformatted.endIndex
            let firstSection = unformatted.substringWithRange(startIndex..<startIndex.advancedBy(4))
            
            switch unformatted.characters.count {
            case 5..<11:
                let secondSection = unformatted.substringWithRange(startIndex.advancedBy(4)..<endIndex)
                return ("\(firstSection) \(secondSection)", unformatted)
            default:
                let secondSection = unformatted.substringWithRange(startIndex.advancedBy(4)..<startIndex.advancedBy(10))
                let thirdSection = unformatted.substringWithRange(startIndex.advancedBy(10)..<endIndex)
                return ("\(firstSection) \(secondSection) \(thirdSection)", unformatted)
            }
        }
        
        return (unformatted, unformatted)
    }
    
    /**
     Formats an expiration date like so : MM/YY
     
     - parameter date: Date string to format
     
     - returns: Formatted date string
     */
    static func formatExpirationDate(date: String) -> Formatted {
        let unformatted = date.stringByReplacingOccurrencesOfString("/", withString: "")
        if unformatted.characters.count > 2 {
            let startIndex = unformatted.startIndex
            let endIndex = unformatted.endIndex
            let firstPart = unformatted.substringWithRange(startIndex..<startIndex.advancedBy(2))
            let secondPart = unformatted.substringWithRange(startIndex.advancedBy(2)..<endIndex)
            return ("\(firstPart)/\(secondPart)", unformatted)
        }
        return (unformatted, unformatted)
    }
}
