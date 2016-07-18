//
//  CollapsedSearchBarView.swift
//  Pods
//
//  Created by SpotHeroMatt on 7/18/16.
//
//

import UIKit

class CollapsedSearchBarView: UIView {
    @IBOutlet weak private var timeLabel: UILabel!
    @IBOutlet weak private var chevron: UIImageView!
    
    var text: String? {
        didSet {
            self.timeLabel.text = self.text
        }
    }
    
    func showCollapsedSearchBar(show: Bool) {
        UIView.animateWithDuration(0.3,
                                   delay: 0,
                                   options: .CurveEaseOut,
                                   animations: {
            self.alpha = show ? 1 : 0
        }) { (finished) in
            self.hidden = show ? false : true
        }
    }
    
    func show() {
        self.showCollapsedSearchBar(true)
    }
    
    func hide() {
        self.showCollapsedSearchBar(false)
    }
}
