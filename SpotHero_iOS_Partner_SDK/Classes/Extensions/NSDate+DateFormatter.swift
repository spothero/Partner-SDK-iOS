//
//  NSDate+DateFormatter.swift
//  Pods
//
//  Created by Husein Kareem on 8/3/16.
//
//

import Foundation

public extension NSDate {
    static func dateByRoundingMinutesDownBy30(date: NSDate) -> NSDate {
        let unitFlags: NSCalendarUnit = [.Minute, .Second]
        let timeComponents = NSCalendar.currentCalendar().components(unitFlags, fromDate: date)
        let remain = timeComponents.minute % 30
        let interval: NSTimeInterval = Double(-((60 * remain) + timeComponents.second))
        return date.dateByAddingTimeInterval(interval)
    }
    
    static func dateByRoundingMinutesUpBy30(date: NSDate) -> NSDate {
        let date = date
        let unitFlags: NSCalendarUnit = [.Minute, .Second]
        let timeComponents = NSCalendar.currentCalendar().components(unitFlags, fromDate: date)
        let remain = timeComponents.minute % 30
        let interval: NSTimeInterval = Double((60 * (30 - remain) - timeComponents.second))
        return date.dateByAddingTimeInterval(interval)
    }
}
