//
//  NSURLQueryItem+QueryParams.swift
//  Pods
//
//  Created by Ellen Shapiro (Work) on 6/29/16.
//
//

import Foundation

extension NSURLQueryItem {
    
    /**
     Takes a dictionary of strings and turns them into an array of NSURLQueryItems.
     
     - parameter dictionary: A dictionary of strings
     
     - returns: An array of query items.
     */
    static func shp_queryItemsFromDictionary(dictionary: [String : String]) -> [NSURLQueryItem] {
        var queryItems = [NSURLQueryItem]()
        
        for (key, value) in dictionary {
            let queryItem = NSURLQueryItem(name: key, value: value)
            queryItems.append(queryItem)
        }
        
        return queryItems
    }
}
