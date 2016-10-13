//
//  CLLocationCoordinate2D+SpotHeroPartner.swift
//  Pods
//
//  Created by SpotHeroMatt on 10/13/16.
//
//

import CoreLocation

extension CLLocationCoordinate2D: Equatable {}

public func ==(lhs: CLLocationCoordinate2D, rhs: CLLocationCoordinate2D) -> Bool {
    return lhs.latitude == rhs.latitude && lhs.longitude == rhs.longitude
}
