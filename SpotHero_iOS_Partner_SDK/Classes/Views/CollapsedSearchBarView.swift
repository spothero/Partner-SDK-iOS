//
//  CollapsedSearchBarView.swift
//  Pods
//
//  Created by Matthew Reed on 7/18/16.
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
    
    /**
     Show or hide collapsed search bar
     
     - parameter show: pass in true to show, false to hide
     */
    func showCollapsedSearchBar(show: Bool) {
        UIView.animateWithDuration(0.3,
                                   delay: 0,
                                   options: .CurveEaseOut,
                                   animations: {
            self.alpha = show ? 1 : 0
        }) {
            finished in
            self.hidden = show ? false : true
        }
    }
    
    /**
     Show collapsed search bar
     */
    func show() {
        self.showCollapsedSearchBar(true)
    }
    
    /**
     Hide collapsed search bar
     */
    func hide() {
        self.showCollapsedSearchBar(false)
    }
}
