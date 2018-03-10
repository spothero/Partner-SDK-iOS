//
//  DestinationAnnotationView.swift
//  SpotHero_iOS_Partner_SDK
//
//  Created by Matthew Reed on 12/19/17.
//

import MapKit
import UIKit

enum AnnotationType {
    case
    map,
    spotDetailsSpot,
    spotDetailsDestination
    
    var image: UIImage? {
        switch self {
        case .map:
            return UIImage(shp_named: "ic_destination")
        case .spotDetailsDestination:
            return UIImage(shp_named: "ic_destination_green")
        case .spotDetailsSpot:
            return UIImage(shp_named: "ic_parking_location")
        }
    }
}

class DestinationAnnotation: NSObject, MKAnnotation {
    var coordinate: CLLocationCoordinate2D
    let type: AnnotationType
    
    init(type: AnnotationType, coordinate: CLLocationCoordinate2D) {
        self.type = type
        self.coordinate = coordinate
    }
}

class DestinationAnnotationView: MKAnnotationView {
    static let Identifier = "DestinationAnnotationViewIdentifier"
    
    private let backgroundImageView = UIImageView()
    private let calloutLabel = UILabel()
    
    var text: String? {
        get {
            return self.calloutLabel.text
        }
        set {
            self.calloutLabel.text = newValue
        }
    }

    init(annotation: MKAnnotation?, reuseIdentifier: String?, type: AnnotationType) {
        super.init(annotation: annotation, reuseIdentifier: reuseIdentifier)
        
        self.backgroundColor = .clear
        // Size from design
        self.frame.size = HeightsAndWidths.AnnotationSize
        
        self.backgroundImageView.image = nil
        self.backgroundImageView.image = type.image
        self.addSubview(self.backgroundImageView)
        self.calloutLabel.numberOfLines = 0
        self.calloutLabel.textAlignment = .center
        self.calloutLabel.font = .shp_subhead
        self.calloutLabel.textColor = .shp_primary
        self.detailCalloutAccessoryView = self.calloutLabel
        self.setupConstraints()
    }
    
    func setupConstraints() {
        self.backgroundImageView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            self.backgroundImageView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            self.backgroundImageView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            self.backgroundImageView.topAnchor.constraint(equalTo: self.topAnchor),
            self.backgroundImageView.bottomAnchor.constraint(equalTo: self.bottomAnchor),
            ])
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}
