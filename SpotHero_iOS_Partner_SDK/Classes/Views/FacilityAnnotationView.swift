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
  case let (lhs?, rhs?):
    return lhs < rhs
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
  case let (lhs?, rhs?):
    return lhs > rhs
  default:
    return rhs < lhs
  }
}

class FacilityAnnotationView: MKAnnotationView {
    
    static let Identifier = "FacilityAnnotationViewIdentifier"
    static let GrowScale: CGFloat = 1.5
    
    private let facilityPinImageDefault = UIImage(shp_named: "spot-marker-default")
    private let facilityPinImageActive = UIImage(shp_named: "spot-marker-active")
    private let priceLabel = UILabel()
    private let backgroundImageView = UIImageView()
    
    override var annotation: MKAnnotation? {
        didSet {
            guard let facilityAnnotation = self.annotation as? FacilityAnnotation else {
                return
            }
            guard let displayPrice = facilityAnnotation.facility?.displayPrice() else {
                self.priceLabel.text = ""
                return
            }
            
            self.priceLabel.font = .shp_button
            self.priceLabel.textColor = .shp_shift
            self.priceLabel.text = "$\(displayPrice)"
        }
    }
    override var isSelected: Bool {
        didSet {
            self.animate(isSelected)
        }
    }
    
    override init(annotation: MKAnnotation?, reuseIdentifier: String?) {
        super.init(annotation: annotation, reuseIdentifier: reuseIdentifier)
        self.backgroundColor = .clear
        self.canShowCallout = false
        self.frame.size = HeightsAndWidths.AnnotationSize
        
        self.backgroundImageView.image = nil
        self.backgroundImageView.image = self.facilityPinImageDefault
        
        self.addSubview(self.backgroundImageView)

        self.annotation = annotation

        self.addSubview(self.priceLabel)
        self.priceLabel.textAlignment = .center
        self.priceLabel.adjustsFontSizeToFitWidth = true
        self.priceLabel.minimumScaleFactor = 0.5
        self.setupConstraints()
    }
    
    func setupConstraints() {
        self.backgroundImageView.translatesAutoresizingMaskIntoConstraints = false
        self.priceLabel.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            self.backgroundImageView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            self.backgroundImageView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            self.backgroundImageView.topAnchor.constraint(equalTo: self.topAnchor),
            self.backgroundImageView.bottomAnchor.constraint(equalTo: self.bottomAnchor),
            
            self.priceLabel.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: HeightsAndWidths.Margins.Standard),
            self.trailingAnchor.constraint(equalTo: self.priceLabel.trailingAnchor, constant: HeightsAndWidths.Margins.Standard),
            self.priceLabel.topAnchor.constraint(equalTo: self.topAnchor),
            // Eyeballed from design
            self.priceLabel.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -14),
            ])
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    private func animate(_ selected: Bool) {
        UIView.animate(withDuration: Animation.Duration.Standard) {
            self.backgroundImageView.image = selected ? self.facilityPinImageActive : self.facilityPinImageDefault
            self.priceLabel.textColor = selected ? .white : .shp_shift
            
            if selected {
                self.transform = CGAffineTransform(scaleX: FacilityAnnotationView.GrowScale, y: FacilityAnnotationView.GrowScale)
                self.centerOffset = CGPoint(x: 0, y: -((self.frame.height - (self.frame.height / FacilityAnnotationView.GrowScale)) / 2))
            } else {
                self.transform = CGAffineTransform.identity
                self.centerOffset = CGPoint.zero
            }
        }
    }
}
