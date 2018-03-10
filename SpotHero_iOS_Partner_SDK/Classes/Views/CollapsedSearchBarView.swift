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
    
    static let SHPDateComponentsFormatter: DateComponentsFormatter = {
        let _dateComponentsFormatter = DateComponentsFormatter()
        _dateComponentsFormatter.unitsStyle = .full
        return _dateComponentsFormatter
    }()
    
    var time: DateComponents? {
        didSet {
            guard let time = self.time else {
                return
            }
            
            self.timeLabel.text = CollapsedSearchBarView.SHPDateComponentsFormatter.string(from: time)
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
    func showCollapsedSearchBar(_ show: Bool) {
        UIView.animate(withDuration: Constants.ViewAnimationDuration,
                       delay: 0,
                       options: .curveEaseOut,
                       animations: {
                        self.alpha = show ? 1 : 0
                       },
                       completion: {
                        _ in
                        self.isHidden = !show
                       })
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
