//
//  CountableIntEnum.swift
//  Pods
//
//  Created by Matthew Reed on 8/1/16.
//  Copyright © 2016 SpotHero. All rights reserved.
//

import Foundation

/**
 A swift protocol to make any Int enum able to count its cases.
 
 Super-useful for making enums to help you deal with sections in tableviews without having to maintain a case for the count of the enum.
 
 Developed by Logan Wright here:
 https://gist.github.com/LoganWright/c8a26b1faf538e40f747
 
 Based on this and the subsequent 3 slides from my talk about
 Laziness-Driven Development at CocoaConf Boston 2015:
 https://speakerdeck.com/designatednerd/laziness-driven-development-in-ios-cocoaconf-boston-september-2015?slide=28
 */
protocol CountableIntEnum {
    init?(rawValue: Int)
}

//MARK: Default Implementation

extension CountableIntEnum {
    
    /**
     - returns: A generated array of all the cases in this enum. Mostly useful for calling with
     .count so you can get the number of items in this enum.
     */
    static var AllCases: [Self] {
        var caseIndex = 0
        let generator = anyGenerator { Self(rawValue: caseIndex++) }
        return Array(generator)
    }
    
    /**
     Method to consolidate fatal erroring out if something ain't there.
     
     - parameter index: The index (indexPath.row or indexPath.section, usually) of the thing you want to grab.
     
     - returns: The retrieved enum case. Fatal errors if it can't find it.
     */
    static func forIndex(index: Int) -> Self {
        guard let rowOrSection = Self(rawValue: index) else {
            fatalError("Issue unwrapping row.")
        }
        return rowOrSection
    }
}