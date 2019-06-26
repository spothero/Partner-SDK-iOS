//
//  UITextField+SpotHeroPartner.swift
//  Pods
//
//  Created by SpotHeroMatt on 10/5/16.
//
//

import UIKit

extension UITextField {
    
    /// Returns the position of the cursor. In an extension for easy reuse
    ///
    /// - parameter range:  Range of string
    /// - parameter string: Replacement string for textfield
    ///
    /// - returns: Position of cursor
    func shp_getCursorPosition(_ range: NSRange, string: String) -> UITextPosition? {
        let beginning = self.beginningOfDocument
        return self.position(from: beginning, offset: (range.location + string.count))
    }
    
    /// Moves the cursor to the position passed in. In an extension for easy reuse
    ///
    /// - parameter cursorLocation: position to place cursor
    func shp_setCursorPosition(_ cursorLocation: UITextPosition?) {
        guard let cursorLocation = cursorLocation else {
            return
        }
        
        self.selectedTextRange = self.textRange(from: cursorLocation, to: cursorLocation)
    }
}
