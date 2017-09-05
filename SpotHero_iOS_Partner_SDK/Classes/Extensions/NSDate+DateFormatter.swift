//
//  NSDate+DateFormatter.swift
//  Pods
//
//  Created by Husein Kareem on 8/3/16.
//
//

import Foundation

public extension Date {
    /**
     Round date time up/down to the nearest half hour
     
     - parameter roundDown: pass in true to round down, false to round up
     */
    func shp_roundDateToNearestHalfHour(roundDown: Bool) -> Date {
        var timeComponents = Calendar.current.dateComponents([.era, .year, .month, .day, .hour, .minute], from: self)
        guard var minute = timeComponents.minute else {
            assertionFailure("Couldn't get the minute off this date")
            return self
        }
        
        if roundDown {
            if minute < 30 {
                minute = 0
            } else if minute > 30 {
                minute = 30
            }
        } else {
            if minute < 30 {
                minute = 30
            } else {
                minute = 60
            }
        }
        
        timeComponents.minute = minute
        
        guard let date = Calendar.current.date(from: timeComponents) else {
            assertionFailure("Unable to create a date from timeComponents: \(timeComponents)")
            return self
        }
        
        return date
    }
}
