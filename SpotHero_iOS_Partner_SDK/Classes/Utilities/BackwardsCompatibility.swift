//
//  BackwardsCompatibility.swift
//  SpotHero
//
//  Created by Carl Hill-Popper on 4/25/18.
//

import Foundation

//To support compiling with Xcodes < 9.3, define compactMap for earlier versions of Swift
#if !swift(>=4.1)
extension Sequence {
    @inline(__always)
    public func compactMap<T>(_ transform: (Element) throws -> T?) rethrows -> [T] {
        return try self.flatMap(transform)
    }
}
#endif
