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
    static func formatPhoneNumber(_ phone: String) -> Formatted {
        let unformatted = phone.replacingOccurrences(of: "-", with: "")
        
        if unformatted.count > 3 {
            let startIndex = unformatted.startIndex
            let endIndex = unformatted.endIndex
            let firstSection = unformatted[startIndex..<unformatted.index(startIndex, offsetBy: 3)]
            
            switch unformatted.count {
            case 4..<7:
                let secondSection = unformatted[unformatted.index(startIndex, offsetBy: 3)..<endIndex]
                return ("\(firstSection)-\(secondSection)", unformatted)
            default:
                let thirdSectionStart = unformatted.index(startIndex, offsetBy: 6)
                let secondSection = unformatted[unformatted.index(startIndex, offsetBy: 3)..<thirdSectionStart]
                let thirdSection = unformatted[thirdSectionStart..<endIndex]
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
    static func formatCreditCard(_ number: String) -> Formatted {
        let unformatted = number.replacingOccurrences(of: " ", with: "")
        
        if unformatted.count > 4 {
            let startIndex = unformatted.startIndex
            let endIndex = unformatted.endIndex
            let firstSection = unformatted[startIndex..<unformatted.index(startIndex, offsetBy: 4)]
            
            switch unformatted.count {
            case 5..<9:
                let secondSection = unformatted[unformatted.index(startIndex, offsetBy: 4)..<endIndex]
                return ("\(firstSection) \(secondSection)", unformatted)
            case 9..<13:
                let thirdSectionStart = unformatted.index(startIndex, offsetBy: 8)
                let secondSection = unformatted[unformatted.index(startIndex, offsetBy: 4)..<thirdSectionStart]
                let thirdSection = unformatted[thirdSectionStart..<endIndex]
                return ("\(firstSection) \(secondSection) \(thirdSection)", unformatted)
            default:
                let thirdSectionStart = unformatted.index(startIndex, offsetBy: 8)
                let fourthSectionStart = unformatted.index(startIndex, offsetBy: 12)
                let secondSection = unformatted[unformatted.index(startIndex, offsetBy: 4)..<thirdSectionStart]
                let thirdSection = unformatted[thirdSectionStart..<fourthSectionStart]
                let fourthSection = unformatted[fourthSectionStart..<endIndex]
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
    static func formatCreditCardAmex(_ number: String) -> Formatted {
        let unformatted = number.replacingOccurrences(of: " ", with: "")
        
        if unformatted.count > 4 {
            let startIndex = unformatted.startIndex
            let endIndex = unformatted.endIndex
            let firstSection = unformatted[startIndex..<unformatted.index(startIndex, offsetBy: 4)]
            
            switch unformatted.count {
            case 5..<11:
                let secondSection = unformatted[unformatted.index(startIndex, offsetBy: 4)..<endIndex]
                return ("\(firstSection) \(secondSection)", unformatted)
            default:
                let thirdSectionStart = unformatted.index(startIndex, offsetBy: 10)
                let secondSection = unformatted[unformatted.index(startIndex, offsetBy: 4)..<thirdSectionStart]
                let thirdSection = unformatted[thirdSectionStart..<endIndex]
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
    static func formatExpirationDate(_ date: String) -> Formatted {
        let unformatted = date.replacingOccurrences(of: "/", with: "")
        if unformatted.count > 2 {
            let startIndex = unformatted.startIndex
            let endIndex = unformatted.endIndex
            let firstPart = unformatted[startIndex..<unformatted.index(startIndex, offsetBy: 2)]
            let secondPart = unformatted[unformatted.index(startIndex, offsetBy: 2)..<endIndex]
            return ("\(firstPart)/\(secondPart)", unformatted)
        }
        return (unformatted, unformatted)
    }
}
