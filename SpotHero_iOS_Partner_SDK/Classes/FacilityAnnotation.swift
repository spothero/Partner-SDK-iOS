//
//  FacilityAnnotation.swift
//  Pods
//
//  Created by Husein Kareem on 8/8/16.
//  Copyright © 2016 SpotHero. All rights reserved.
//

import Foundation
import MapKit

class FacilityAnnotation: NSObject, MKAnnotation {
    let title: String?
    let coordinate: CLLocationCoordinate2D
    
    init(title: String, coordinate: CLLocationCoordinate2D) {
        self.title = title
        self.coordinate = coordinate
        
        super.init()
    }
}
