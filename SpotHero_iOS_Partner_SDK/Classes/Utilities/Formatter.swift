//
//  Formatter.swift
//  Pods
//
//  Created by Matthew Reed on 8/8/16.
//  Copyright © 2016 SpotHero. All rights reserved.
//

import Foundation

enum Formatter {
    static func formatPhoneNumber(phone: String) -> String {
        let unformatted = phone.stringByReplacingOccurrencesOfString("-", withString: "")
        
        if unformatted.characters.count > 3 {
            let startIndex = unformatted.startIndex
            let endIndex = unformatted.endIndex
            let firstSection = unformatted.substringWithRange(startIndex..<startIndex.advancedBy(3))
            
            switch unformatted.characters.count {
            case 4..<7:
                let secondSection = unformatted.substringWithRange(startIndex.advancedBy(3)..<endIndex)
                return "\(firstSection)-\(secondSection)"
            default:
                let secondSection = unformatted.substringWithRange(startIndex.advancedBy(3)..<startIndex.advancedBy(6))
                let thirdSection = unformatted.substringWithRange(startIndex.advancedBy(6)..<endIndex)
                return "\(firstSection)-\(secondSection)-\(thirdSection)"
            }
        }
        
        return unformatted
    }
    
    static func formatCreditCard(number: String) -> String {
        let unformatted = number.stringByReplacingOccurrencesOfString(" ", withString: "")
        
        if unformatted.characters.count > 4 {
            let startIndex = unformatted.startIndex
            let endIndex = unformatted.endIndex
            let firstSection = unformatted.substringWithRange(startIndex..<startIndex.advancedBy(4))
            
            switch unformatted.characters.count {
            case 5..<9:
                let secondSection = unformatted.substringWithRange(startIndex.advancedBy(4)..<endIndex)
                return "\(firstSection) \(secondSection)"
            case 9..<13:
                let secondSection = unformatted.substringWithRange(startIndex.advancedBy(4)..<startIndex.advancedBy(8))
                let thirdSection = unformatted.substringWithRange(startIndex.advancedBy(8)..<endIndex)
                return "\(firstSection) \(secondSection) \(thirdSection)"
            default:
                let secondSection = unformatted.substringWithRange(startIndex.advancedBy(4)..<startIndex.advancedBy(8))
                let thirdSection = unformatted.substringWithRange(startIndex.advancedBy(8)..<startIndex.advancedBy(12))
                let fourthSection = unformatted.substringWithRange(startIndex.advancedBy(12)..<endIndex)
                return "\(firstSection) \(secondSection) \(thirdSection) \(fourthSection)"
            }
        }
        
        return unformatted
    }
    
    static func formatCreditCardAmex(number: String) -> String {
        let unformatted = number.stringByReplacingOccurrencesOfString(" ", withString: "")
        
        if unformatted.characters.count > 4 {
            let startIndex = unformatted.startIndex
            let endIndex = unformatted.endIndex
            let firstSection = unformatted.substringWithRange(startIndex..<startIndex.advancedBy(4))
            
            switch unformatted.characters.count {
            case 5..<11:
                let secondSection = unformatted.substringWithRange(startIndex.advancedBy(4)..<endIndex)
                return "\(firstSection) \(secondSection)"
            default:
                let secondSection = unformatted.substringWithRange(startIndex.advancedBy(4)..<startIndex.advancedBy(10))
                let thirdSection = unformatted.substringWithRange(startIndex.advancedBy(10)..<endIndex)
                return "\(firstSection) \(secondSection) \(thirdSection)"
            }
        }
        
        return unformatted
    }
}
