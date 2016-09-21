//
//  NSDate+DateFormatter.swift
//  Pods
//
//  Created by Husein Kareem on 8/3/16.
//
//

import Foundation

public extension NSDate {
    /**
     Round date time up/down by x mins
     
     - parameter roundDown: pass in true to round down by x mins, false to round up
     - parameter minutes: pass in x mins, by default it is set to 30 mins
     */
    func shp_dateByRoundingMinutes(roundDown roundDown: Bool, minutes: Int = 30) -> NSDate {
        let unitFlags: NSCalendarUnit = [.Minute, .Second]
        let timeComponents = NSCalendar.currentCalendar().components(unitFlags, fromDate: self)
        let remain = timeComponents.minute % minutes
        let interval: NSTimeInterval
        if roundDown {
            interval = Double(-((60 * remain) + timeComponents.second))
        } else {
            interval = Double((60 * (minutes - remain) - timeComponents.second))
        }
        return self.dateByAddingTimeInterval(interval)
    }
}
