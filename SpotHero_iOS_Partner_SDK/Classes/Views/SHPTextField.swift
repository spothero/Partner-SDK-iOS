//
//  SHPTextField.swift
//  SpotHero_iOS_Partner_SDK
//
//  Created by Matthew Reed on 2/2/18.
//

import UIKit

class SHPTextField: UITextField {
    override func awakeFromNib() {
        super.awakeFromNib()
        self.font = .shp_subhead
    }
    
    func setAttributedPlaceholder(text: String) {
        let placeholderAttribues = [NSAttributedStringKey.foregroundColor: UIColor.shp_pavement]
        self.attributedPlaceholder = NSAttributedString(string: text,
                                                        attributes: placeholderAttribues)
    }
}
