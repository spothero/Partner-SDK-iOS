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
        let unitFlags: NSCalendarUnit = [.Minute, .Era, .Day, .Month, .Year, .Hour]
        let timeComponents = NSCalendar.currentCalendar().components(unitFlags, fromDate: self)
        timeComponents.second = 0
        var minute = timeComponents.minute
        
        if roundDown {
            if minute < 30 {
                minute = 0
            } else if minute > 30 {
                minute = 30
            }
        } else {
            if minute < 30 {
                minute = 30
            } else if minute >= 30 {
                minute = 0
                timeComponents.hour += 1
            }
        }
        
        timeComponents.minute = minute
        return  NSCalendar.currentCalendar().dateFromComponents(timeComponents) ?? NSDate()
    }
}
