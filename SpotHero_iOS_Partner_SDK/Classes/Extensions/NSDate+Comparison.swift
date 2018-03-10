//
//  NSDate+Comparison.swift
//  Pods
//
//  Created by Ellen Shapiro (Work) on 9/29/16.
//
//

import Foundation

extension Date {

    func shp_isBeforeDate(_ date: Date) -> Bool {
        return (self.compare(date) == .orderedAscending)
    }
    
    func shp_isAfterDate(_ date: Date) -> Bool {
        return (self.compare(date) == .orderedDescending)
    }
    
    func shp_inSameDayAs(otherDate date: Date) -> Bool {
        let calendar = Calendar(identifier: .gregorian)
        return calendar.isDate(self, inSameDayAs: date)
    }
    
    func shp_isWithinAHalfHourOfDate(_ date: Date) -> Bool {
        return self.shp_roundDateToNearestHalfHour(roundDown: false).shp_isAfterDate(date)
    }
    
    func shp_isEqual(_ otherDate: Date, component: Calendar.Component = .second) -> Bool {
        let calendar = Calendar(identifier: .gregorian)
        return calendar.compare(self, to: otherDate, toGranularity: component) == .orderedSame
    }
    
    func shp_onTheHour() -> Bool {
        let calendar = Calendar(identifier: .gregorian)
        let components = calendar.dateComponents([.minute], from: self)
        return components.minute == 0
    }
}
