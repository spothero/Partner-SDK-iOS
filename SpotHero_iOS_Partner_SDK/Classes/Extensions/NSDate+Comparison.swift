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
}
