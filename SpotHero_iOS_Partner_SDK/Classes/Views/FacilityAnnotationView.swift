//
//  FacilityAnnotationView.swift
//  Pods
//
//  Created by Husein Kareem on 8/15/16.
//  Copyright © 2016 SpotHero. All rights reserved.
//

import Foundation
import MapKit

class FacilityAnnotationView: MKAnnotationView {
    
    static let Identifier = "FacilityAnnotationViewIdentifier"
    
    private let growDuration: NSTimeInterval = 0.4
    private let facilityGrowScale: CGFloat = 1.5
    private let priceTextColorActive = UIColor.shp_green()
    private let priceTextColorDefault = UIColor.shp_spotHeroBlue()
    private let facilityPinImageDefault = UIImage(named: "spot-marker-default",
                                                  inBundle: NSBundle.shp_resourceBundle(),
                                                  compatibleWithTraitCollection: nil)
    private let facilityPinImageActive = UIImage(named: "spot-marker-active",
                                                 inBundle: NSBundle.shp_resourceBundle(),
                                                 compatibleWithTraitCollection: nil)
    private var priceLabel: AnnotationLabel?
    private var backgroundImageView: UIImageView?
    private let unscaledHeight:CGFloat = 38
    
    override var annotation: MKAnnotation? {
        didSet {
            guard let facilityAnnotation = self.annotation as? FacilityAnnotation else {
                return
            }
            guard let displayPrice = facilityAnnotation.facility?.displayPrice() else {
                self.priceLabel?.text = ""
                return
            }
            self.priceLabel?.font = UIFont.systemFontOfSize(self.priceLabel?.text?.characters.count > 3 ? AnnotationLabel.minLabelFontSize : AnnotationLabel.maxLabelFontSize)
            self.priceLabel?.text = "$\(displayPrice)"
        }
    }
    override var selected: Bool {
        didSet {
            self.animate(selected)
        }
    }
    
    override init(annotation: MKAnnotation?, reuseIdentifier: String?) {
        super.init(annotation: annotation, reuseIdentifier: reuseIdentifier)
        
        guard let imageSize = self.facilityPinImageDefault?.size else {
            assertionFailure("cannot get image size")
            return
        }
        self.frame.size = imageSize
        self.backgroundColor = .clearColor()
        self.centerOffset = CGPoint(x: 0, y: -imageSize.height / 2)
        self.canShowCallout = false
        
        self.backgroundImageView = UIImageView(frame: self.bounds)
        self.backgroundImageView?.image = nil
        self.backgroundImageView?.image = self.facilityPinImageDefault
        self.backgroundImageView?.autoresizingMask = [
            .FlexibleTopMargin,
            .FlexibleLeftMargin,
            .FlexibleRightMargin,
        ]
        guard let imageView = self.backgroundImageView else {
            return
        }
        self.addSubview(imageView)

        self.priceLabel = AnnotationLabel(frame: self.labelBoundsWithScale(1))
        self.annotation = annotation
        self.priceLabel?.textColor = .shp_spotHeroBlue()
        self.priceLabel?.contentMode = .Center
        self.priceLabel?.autoresizingMask = [
            .FlexibleTopMargin,
            .FlexibleLeftMargin,
            .FlexibleRightMargin
        ]
        guard let priceLabel = self.priceLabel else {
            return
        }
        self.addSubview(priceLabel)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    #if swift(>=2.3)
    #else
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    #endif
    
    private func labelBoundsWithScale(scale: CGFloat) -> CGRect {
        var labelBounds = self.bounds
        labelBounds.size.height = labelBounds.size.height - 10 * scale
        labelBounds.size.width = labelBounds.size.width - 8 * scale
        labelBounds.origin.x = labelBounds.origin.x + 4 * scale
        return labelBounds
    }
    
    private func animate(selected: Bool) {
        UIView.animateWithDuration(self.growDuration) {
            self.backgroundImageView?.image = selected ? self.facilityPinImageActive : self.facilityPinImageDefault
            self.priceLabel?.textColor = selected ? self.priceTextColorActive : self.priceTextColorDefault
            let scale = selected ? self.facilityGrowScale : 1
            self.centerOffset = CGPoint(x: 0, y: (-self.unscaledHeight * scale) / 2)
            self.transform = selected ? CGAffineTransformMakeScale(self.facilityGrowScale, self.facilityGrowScale) : CGAffineTransformIdentity
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
        
        self.backgroundColor = .clearColor()
        self.textAlignment = .Center
        self.font = UIFont(name: self.font!.fontName, size: AnnotationLabel.minLabelFontSize)
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
        self.font = UIFont.systemFontOfSize(fontSize * scale)
    }
}
