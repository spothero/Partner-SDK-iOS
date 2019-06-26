//  swiftlint:disable:this file_name
//  NSURLQueryItem+QueryParams.swift
//  Pods
//
//  Created by Ellen Shapiro (Work) on 6/29/16.
//
//

import Foundation

extension URLQueryItem {
    
    /**
     Takes a dictionary of strings and turns them into an array of NSURLQueryItems.
     
     - parameter dictionary: A dictionary of strings
     
     - returns: An array of query items.
     */
    static func shp_queryItemsFromDictionary(_ dictionary: [String: String]) -> [URLQueryItem] {
        var queryItems = [URLQueryItem]()
        
        for (key, value) in dictionary {
            let queryItem = URLQueryItem(name: key, value: value)
            queryItems.append(queryItem)
        }
        
        return queryItems.sorted { item1, item2 in
            return item1.name < item2.name
        }
    }
}
