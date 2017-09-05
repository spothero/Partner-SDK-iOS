//
//  JSONDictionary.swift
//  SpotHero_iOS_Partner_SDK
//
//  Created by Ellen Shapiro (Work) on 6/29/16.
//
//

import Foundation

// Let's make this a hair more readable, shall we?
public typealias JSONDictionary = [String : Any]

enum JSONParsingError: Error {
    /// The `index` is out of bounds for a JSON array
    case indexOutOfBounds(index: Int)
    
    /// The `key` was not found in the JSON dictionary
    case keyNotFound(key: String)
    
    /// Unexpected JSON `value` was found that is not convertible `to` type
    case valueNotConvertible(value: Any, to: Any.Type)
    
    /// The `key` was found but there were no results
    case noResults
}

protocol JSONParseable {
    
    init(json: JSONDictionary) throws
}

extension Dictionary where Key: ExpressibleByStringLiteral, Value: Any {
    
    private func shp_throwingValueForKey(_ key: Key) throws -> Any {
        guard let value = self[key] else {
            //Since Key is a StringLiteral convertible, force-cast always succeeds.
            // swiftlint:disable force_cast
            throw JSONParsingError.keyNotFound(key: key as! String)
            // swiftlint:enable force_cast
        }
        
        return value
    }
    
    private func shp_generic<T>(_ key: Key) throws -> T {
        let value = try self.shp_throwingValueForKey(key)
        guard let typedValue = value as? T else {
            throw JSONParsingError.valueNotConvertible(value: value, to: T.self)
        }
        
        return typedValue
    }
    
    private func shp_genericWithDefault<T>(_ key: Key, defaultValue: T) throws -> T {
        let value = try self.shp_throwingValueForKey(key)
        guard let typedValue = value as? T else {
            return defaultValue
        }
        
        return typedValue
    }
    
    func shp_bool(_ key: Key) throws -> Bool {
        return try self.shp_generic(key)
    }
    
    func shp_bool(_ key: Key, or defaultValue: Bool) throws -> Bool {
        return try self.shp_genericWithDefault(key, defaultValue: defaultValue)
    }
    
    func shp_int(_ key: Key) throws -> Int {
        return try self.shp_generic(key)
    }
    
    func shp_int(_ key: Key, or defaultValue: Int) throws -> Int {
        return try self.shp_genericWithDefault(key, defaultValue: defaultValue)
    }
    
    func shp_string(_ key: Key) throws -> String {
        return try self.shp_generic(key)
    }
    
    func shp_double(_ key: Key) throws -> Double {
        return try self.shp_generic(key)
    }
    
    func shp_array<T>(_ key: Key) throws -> [T] {
        return try self.shp_generic(key)
    }
    
    func shp_dictionary<K, V>(_ key: Key) throws -> [K : V] {
        return try self.shp_generic(key)
    }
    
    func shp_parsedArray<T: JSONParseable>(_ key: Key) throws -> [T] {
        let value = try self.shp_throwingValueForKey(key)
        
        guard let dictionaries = value as? [JSONDictionary] else {
            throw JSONParsingError.valueNotConvertible(value: value, to: JSONDictionary.self)
        }
        
        let parsedObjects: [T] = try dictionaries.map {
            dictionary in
            return try T.init(json: dictionary)
        }
        
        return parsedObjects
    }
}
