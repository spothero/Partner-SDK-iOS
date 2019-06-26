//
//  MKMapView+SpotHeroPartner.swift
//  SpotHero_iOS_Partner_SDK
//
//  Created by Matthew Reed on 2/14/18.
//

import CoreLocation
import Foundation
import MapKit

extension MKMapView {
    func shp_distanceFromCoordinate(coordinate: CLLocationCoordinate2D) -> CLLocationDistance {
        let centerLocation = CLLocation(latitude: self.centerCoordinate.latitude, longitude: self.centerCoordinate.longitude)
        let coordinateLocation = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
        return centerLocation.distance(from: coordinateLocation)
    }
}
