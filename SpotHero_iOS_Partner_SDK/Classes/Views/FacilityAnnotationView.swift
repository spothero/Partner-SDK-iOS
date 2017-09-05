//
//  FacilityAnnotationView.swift
//  Pods
//
//  Created by Husein Kareem on 8/15/16.
//  Copyright © 2016 SpotHero. All rights reserved.
//

import Foundation
import MapKit
// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
private func < <T: Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}

// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
private func > <T: Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l > r
  default:
    return rhs < lhs
  }
}

class FacilityAnnotationView: MKAnnotationView {
    
    static let Identifier = "FacilityAnnotationViewIdentifier"
    
    private let growDuration: TimeInterval = 0.4
    private let facilityGrowScale: CGFloat = 1.5
    private let priceTextColorActive = UIColor.shp_green()
    private let priceTextColorDefault = UIColor.shp_spotHeroBlue()
    private let facilityPinImageDefault = UIImage(named: "spot-marker-default",
                                                  in: Bundle.shp_resourceBundle(),
                                                  compatibleWith: nil)
    private let facilityPinImageActive = UIImage(named: "spot-marker-active",
                                                 in: Bundle.shp_resourceBundle(),
                                                 compatibleWith: nil)
    private var priceLabel: AnnotationLabel?
    private var backgroundImageView: UIImageView?
    private let unscaledHeight: CGFloat = 38
    
    override var annotation: MKAnnotation? {
        didSet {
            guard let facilityAnnotation = self.annotation as? FacilityAnnotation else {
                return
            }
            guard let displayPrice = facilityAnnotation.facility?.displayPrice() else {
                self.priceLabel?.text = ""
                return
            }
            
            var fontSize = AnnotationLabel.maxLabelFontSize
            if self.priceLabel?.text?.characters.count > 3 {
                fontSize = AnnotationLabel.minLabelFontSize
            }
            
            self.priceLabel?.font = UIFont.systemFont(ofSize: fontSize)
            self.priceLabel?.text = "$\(displayPrice)"
        }
    }
    override var isSelected: Bool {
        didSet {
            self.animate(isSelected)
        }
    }
    
    override init(annotation: MKAnnotation?, reuseIdentifier: String?) {
        super.init(annotation: annotation, reuseIdentifier: reuseIdentifier)
        
        guard let imageSize = self.facilityPinImageDefault?.size else {
            assertionFailure("cannot get image size")
            return
        }
        self.frame.size = imageSize
        self.backgroundColor = .clear
        self.centerOffset = CGPoint(x: 0, y: -imageSize.height / 2)
        self.canShowCallout = false
        
        self.backgroundImageView = UIImageView(frame: self.bounds)
        self.backgroundImageView?.image = nil
        self.backgroundImageView?.image = self.facilityPinImageDefault
        self.backgroundImageView?.autoresizingMask = [
            .flexibleTopMargin,
            .flexibleLeftMargin,
            .flexibleRightMargin,
        ]
        guard let imageView = self.backgroundImageView else {
            return
        }
        self.addSubview(imageView)

        self.priceLabel = AnnotationLabel(frame: self.labelBoundsWithScale(1))
        self.annotation = annotation
        self.priceLabel?.textColor = .shp_spotHeroBlue()
        self.priceLabel?.contentMode = .center
        self.priceLabel?.autoresizingMask = [
            .flexibleTopMargin,
            .flexibleLeftMargin,
            .flexibleRightMargin,
        ]
        guard let priceLabel = self.priceLabel else {
            return
        }
        self.addSubview(priceLabel)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    private func labelBoundsWithScale(_ scale: CGFloat) -> CGRect {
        var labelBounds = self.bounds
        labelBounds.size.height -= (10 * scale)
        labelBounds.size.width -= (8 * scale)
        labelBounds.origin.x += (4 * scale)
        return labelBounds
    }
    
    private func animate(_ selected: Bool) {
        UIView.animate(withDuration: self.growDuration) {
            self.backgroundImageView?.image = selected ? self.facilityPinImageActive : self.facilityPinImageDefault
            self.priceLabel?.textColor = selected ? self.priceTextColorActive : self.priceTextColorDefault
            let scale = selected ? self.facilityGrowScale : 1
            self.centerOffset = CGPoint(x: 0, y: (-self.unscaledHeight * scale) / 2)
            self.transform = selected ? CGAffineTransform(scaleX: self.facilityGrowScale, y: self.facilityGrowScale) : CGAffineTransform.identity
        } 
    }
}

class AnnotationLabel: UILabel {
    static let maxLabelFontSize: CGFloat = 10
    static let minLabelFontSize: CGFloat = 7
    
    override var text: String? {
        didSet {
            self.updateFontSize()
        }
    }
    
    private var initialWidth: CGFloat = 1 // Do not divide by zero.
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        if self.frame.width != 0 {
            self.initialWidth = self.frame.width
        } //else don't update initial width or you'll get divide by zero errors.
        
        self.backgroundColor = .clear
        self.textAlignment = .center
        
        guard let fontName = self.font?.fontName else {
            assertionFailure("No font name for you!")
            return
        }
        self.font = UIFont(name: fontName, size: AnnotationLabel.minLabelFontSize)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func updateFontSize() {
        let fontSize: CGFloat
        if self.text?.characters.count > 3 {
            fontSize = AnnotationLabel.minLabelFontSize
        } else {
            fontSize = AnnotationLabel.maxLabelFontSize
        }
        
        let scale: CGFloat = self.frame.width / self.initialWidth
        self.font = UIFont.systemFont(ofSize: fontSize * scale)
    }
}
