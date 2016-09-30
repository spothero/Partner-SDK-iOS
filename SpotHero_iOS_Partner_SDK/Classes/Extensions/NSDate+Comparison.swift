//
//  NSDate+Comparison.swift
//  Pods
//
//  Created by Ellen Shapiro (Work) on 9/29/16.
//
//

import Foundation

extension NSDate {

    func shp_isBeforeDate(date: NSDate) -> Bool {
        return (self.compare(date) == .OrderedAscending)
    }
    
    func shp_isAfterDate(date: NSDate) -> Bool {
        return (self.compare(date) == .OrderedDescending)
    }
}
