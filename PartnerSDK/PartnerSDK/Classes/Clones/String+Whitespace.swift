//
//  String+Whitespace.swift
//  SpotHero_iOS_Partner_SDK
//
//  Created by Reed.Hogan on 5/28/19.
//  Copyright © 2019 SpotHero, Inc. All rights reserved.
//

import Foundation

//swiftlint:disable identifier_name
extension String {
    
    /**
     - returns: The caller, trimmed of whitespace and newlines at the start and finish of the string.
     */
    func sph_trimmedOfAllWhitespace() -> String {
        return self.trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
    /// - returns: True if string only contains whitespaces and/or newlines
    var sph_containsOnlyWhitespace: Bool {
        return !self.isEmpty && self.sph_trimmedOfAllWhitespace().isEmpty
    }
    
}
