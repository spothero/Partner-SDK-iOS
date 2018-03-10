//
//  MKMapRect+SpotHeroPartner.swift
//  SpotHero_iOS_Partner_SDK
//
//  Created by Matthew Reed on 2/15/18.
//

import Foundation
import MapKit

extension MKMapRect {
    func shp_contains(coordinate: CLLocationCoordinate2D) -> Bool {
        return MKMapRectContainsPoint(self, MKMapPointForCoordinate(coordinate))
    }
}
