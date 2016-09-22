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
     Round date time up/down to the nearest half hour
     
     - parameter roundDown: pass in true to round down, false to round up
     */
    func shp_roundDateToNearestHalfHour(roundDown roundDown: Bool) -> NSDate {
        let unitFlags: NSCalendarUnit = [.Minute, .Second]
        let timeComponents = NSCalendar.currentCalendar().components(unitFlags, fromDate: self)
        let remain = timeComponents.minute % 30
        let interval: NSTimeInterval
        if roundDown {
            interval = Double(-((60 * remain) + timeComponents.second))
        } else {
            interval = Double((60 * (30 - remain) - timeComponents.second))
        }
        return self.dateByAddingTimeInterval(interval)
    }
}
