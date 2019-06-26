//
//  ProgressHUD.swift
//  Pods
//
//  Created by Husein Kareem on 9/1/16.
//
//

import Foundation
import UIKit

class ProgressHUD: UIView {
    
    @IBOutlet private weak var activityIndicator: UIActivityIndicatorView!
    
    /**
     Creates a new SHProgressHUD view, adds it to the provided view, starts animating the activity indicator and shows it.
     
     - parameter view: The view that the SHProgressHUD will be added to.
     - parameter text: The text that will be displayed under the activity indicator.
     */
    static func showHUDAddedTo(_ view: UIView, withText text: String = "") {
        guard let progressView = Bundle.shp_resourceBundle().loadNibNamed(String(describing: ProgressHUD.self),
                                                                          owner: self,
                                                                          options: nil)?.first as? ProgressHUD else {
                                                                            return
        }
        
        // Don't show if it is already being shown
        for subView in view.subviews where subView is ProgressHUD {
            return
        }
        
        progressView.frame = view.frame
        progressView.center = CGPoint(x: view.bounds.width / 2, y: view.bounds.height / 2)
        progressView.layer.cornerRadius = HeightsAndWidths.standardCornerRadius
        progressView.activityIndicator.startAnimating()
        
        view.addSubview(progressView)
        view.bringSubviewToFront(progressView)
        view.isUserInteractionEnabled = false
    }
    
    /**
     Finds SHProgressHUD views and removes them from the superview
     
     - parameter view: The view that is going to be searched for a SHProgressHUD subview.
     */
    static func hideHUDForView(_ view: UIView?) {
        guard let view = view else {
            return
        }
        
        view.isUserInteractionEnabled = true
        
        for subView in view.subviews where subView is ProgressHUD {
            subView.removeFromSuperview()
            return
        }
    }
}
