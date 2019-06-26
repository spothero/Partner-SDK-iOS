//
//  LinkBarButtonItem.swift
//  SpotHero_iOS_Partner_SDK
//
//  Created by Matthew Reed on 12/19/17.
//

import UIKit

class LinkBarButtonItem: UIBarButtonItem {
    override init() {
        super.init()
        self.setTextStyle()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.setTextStyle()
    }
    
    func setTextStyle() {
        let barButtonItemTitleTextAttributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.shp_link,
            .foregroundColor: UIColor.shp_link,
        ]
        
        let barButtonItemDisabledTitleTextAttributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.shp_link,
            .foregroundColor: UIColor.shp_disabled,
        ]
        
        self.setTitleTextAttributes(barButtonItemTitleTextAttributes, for: .normal)
        self.setTitleTextAttributes(barButtonItemTitleTextAttributes, for: .highlighted)
        self.setTitleTextAttributes(barButtonItemTitleTextAttributes, for: .selected)
        self.setTitleTextAttributes(barButtonItemDisabledTitleTextAttributes, for: .disabled)
    }
}
