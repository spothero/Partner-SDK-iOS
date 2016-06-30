//
//  JSONDictionary.swift
//  SpotHero_iOS_Partner_SDK
//
//  Created by Ellen Shapiro (Work) on 6/29/16.
//
//

import Foundation

// Let's make this a hair more readable, shall we?
public typealias JSONDictionary = [String : AnyObject]

enum JSONParsingError: ErrorType {
    /// The `index` is out of bounds for a JSON array
    case IndexOutOfBounds(index: Int)
    
    /// The `key` was not found in the JSON dictionary
    case KeyNotFound(key: String)
    
    /// Unexpected JSON `value` was found that is not convertible `to` type
    case ValueNotConvertible(value: AnyObject, to: Any.Type)
}

protocol JSONParseable {
    
    init(json: JSONDictionary) throws
}

extension Dictionary where Key: StringLiteralConvertible, Value: AnyObject {
    
    private func shp_throwingValueForKey(key: Key) throws -> AnyObject {
        guard let value = self[key] else {
            //Since Key is a StringLiteral convertible, force-cast always succeeds.
            throw JSONParsingError.KeyNotFound(key: key as! String)
        }
        
        return value
    }
    
    private func shp_generic<T>(key: Key) throws -> T {
        let value = try self.shp_throwingValueForKey(key)
        guard let typedValue = value as? T else {
            throw JSONParsingError.ValueNotConvertible(value: value, to: T.self)
        }
        
        return typedValue
    }
    
    private func shp_genericWithDefault<T>(key: Key, defaultValue: T) throws -> T {
        let value = try self.shp_throwingValueForKey(key)
        guard let typedValue = value as? T else {
            return defaultValue
        }
        
        return typedValue
    }
    
    func shp_bool(key: Key) throws -> Bool {
        return try self.shp_generic(key)
    }
    
    func shp_bool(key: Key, or defaultValue: Bool) throws -> Bool {
        return try self.shp_genericWithDefault(key, defaultValue: defaultValue)
    }
    
    func shp_int(key: Key) throws -> Int {
        return try self.shp_generic(key)
    }
    
    func shp_int(key: Key, or defaultValue: Int) throws -> Int {
        return try self.shp_genericWithDefault(key, defaultValue: defaultValue)
    }
    
    func shp_string(key: Key) throws -> String {
        return try self.shp_generic(key)
    }
    
    func shp_double(key: Key) throws -> Double {
        return try self.shp_generic(key)
    }
    
    func shp_array<T>(key: Key) throws -> [T] {
        return try self.shp_generic(key)
    }
    
    func shp_dictionary<K, V>(key: Key) throws -> [K : V] {
        return try self.shp_generic(key)
    }
    
    func shp_parsedArray<T: JSONParseable>(key: Key) throws -> [T] {
        let value = try self.shp_throwingValueForKey(key)
        
        guard let dictionaries = value as? [JSONDictionary] else {
            throw JSONParsingError.ValueNotConvertible(value: value, to: JSONDictionary.self)
        }
        
        let parsedObjects: [T] = try dictionaries.map {
            dictionary in
            return try T.init(json: dictionary)
        }
        
        return parsedObjects
    }
}
