//
//  ProgressHUD.swift
//  Pods
//
//  Created by Husein Kareem on 9/1/16.
//
//

import Foundation

class ProgressHUD: UIView {
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var progressLabel: UILabel!
    
    /**
     Creates a new SHProgressHUD view, adds it to the provided view, starts animating the activity indicator and shows it.
     
     - parameter view: The view that the SHProgressHUD will be added to.
     - parameter text: The text that will be displayed under the activity indicator.
     */
    static func showHUDAddedTo(view: UIView, withText text: String = "") {
        guard let progressView = NSBundle.shp_resourceBundle().loadNibNamed(String(ProgressHUD),
                                                                                   owner: self,
                                                                                   options: nil).first as? ProgressHUD else {
                                                                                    return
        }
        
        progressView.frame = CGRect(x: 0, y: 0, width: 100, height: 100)
        progressView.center = CGPoint(x: view.bounds.width / 2, y: view.bounds.height / 2)
        progressView.layer.cornerRadius = HeightsAndLengths.standardCornerRadius
        progressView.activityIndicator.startAnimating()
        progressView.progressLabel.text = text
        
        view.addSubview(progressView)
        view.bringSubviewToFront(progressView)
    }
    
    /**
     Finds SHProgressHUD views and removes them from the superview
     
     - parameter view: The view that is going to be searched for a SHProgressHUD subview.
     */
    static func hideHUDForView(view: UIView?) {
        guard let view = view else {
            return
        }
        for subView in view.subviews {
            if subView.isKindOfClass(ProgressHUD) {
                subView.removeFromSuperview()
                return
            }
        }
    }
}
