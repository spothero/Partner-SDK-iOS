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

    private(set) var facility: Facility

    var title: String? {
        return facility.title
    }
    
    var coordinate: CLLocationCoordinate2D {
        return facility.location.coordinate
    }
    
    init(facility: Facility) {
        self.facility = facility
        super.init()
    }
    
    func update(with facility: Facility) {
        self.facility = facility
    }
}
