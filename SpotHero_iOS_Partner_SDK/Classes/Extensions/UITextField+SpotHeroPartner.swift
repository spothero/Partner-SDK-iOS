//
//  UITextField+SpotHeroPartner.swift
//  Pods
//
//  Created by SpotHeroMatt on 10/5/16.
//
//

import UIKit

extension UITextField {
    func shp_getCursorPosition(range: NSRange, string: String) -> UITextPosition? {
        let beginning = self.beginningOfDocument
        return self.positionFromPosition(beginning, offset: (range.location + string.characters.count))
    }
    
    func shp_setCursorPosition(cursorLocation: UITextPosition?) {
        guard let cursorLocation = cursorLocation else {
            return
        }
        
        self.selectedTextRange = self.textRangeFromPosition(cursorLocation, toPosition: cursorLocation)
    }
}
