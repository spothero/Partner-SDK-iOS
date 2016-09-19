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
    let facility: Facility?
    let index: Int
    
    init(title: String,
         coordinate: CLLocationCoordinate2D,
         facility: Facility,
         index: Int) {
        self.title = title
        self.coordinate = coordinate
        self.facility = facility
        self.index = index
        
        super.init()
    }
}
