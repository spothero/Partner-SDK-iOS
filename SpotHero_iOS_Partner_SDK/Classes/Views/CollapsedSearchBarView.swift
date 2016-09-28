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
    
    static let dateComponentsFormatter: NSDateComponentsFormatter = {
        let _dateComponentsFormatter = NSDateComponentsFormatter()
        _dateComponentsFormatter.unitsStyle = .Full
        return _dateComponentsFormatter
    }()
    
    var time: NSDateComponents? {
        didSet {
            guard let time = self.time else {
                return
            }
            
            self.timeLabel.text = CollapsedSearchBarView.dateComponentsFormatter.stringFromDateComponents(time)
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.accessibilityLabel = AccessibilityStrings.CollapsedSearchBarView
    }
    
    /**
     Show or hide collapsed search bar
     
     - parameter show: pass in true to show, false to hide
     */
    func showCollapsedSearchBar(show: Bool) {
        UIView.animateWithDuration(Constants.ViewAnimationDuration,
                                   delay: 0,
                                   options: .CurveEaseOut,
                                   animations: {
                                    self.alpha = show ? 1 : 0
        }) {
            finished in
            self.hidden = !show
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
