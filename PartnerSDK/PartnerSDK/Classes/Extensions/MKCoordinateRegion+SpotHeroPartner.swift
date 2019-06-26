//
//  MKCoordinateRegion+SpotHeroPartner.swift
//  SpotHero_iOS_Partner_SDK
//
//  Created by Reed.Hogan on 6/7/19.
//  Copyright © 2019 SpotHero, Inc. All rights reserved.
//

import MapKit

extension MKCoordinateRegion {
    
    init(center: CLLocationCoordinate2D, radius: Double) {
        let span = radius * 2
        self.init(center: center,
                  latitudinalMeters: span,
                  longitudinalMeters: span)
    }
    
    private var asMapRect: MKMapRect {
        let latDelta = self.span.latitudeDelta / 2
        let longDelta = self.span.longitudeDelta / 2
        
        let leftLongitude = self.center.longitude - longDelta
        let rightLongitude = self.center.longitude + longDelta
        
        let topLatitude = self.center.latitude + latDelta
        let bottomLatitude = self.center.latitude - latDelta
        
        let topLeftCoordinate = CLLocationCoordinate2D(latitude: topLatitude, longitude: leftLongitude)
        let bottomRightCoordinate = CLLocationCoordinate2D(latitude: bottomLatitude, longitude: rightLongitude)
        
        let topLeftPoint = MKMapPoint(topLeftCoordinate)
        let bottomRightPoint = MKMapPoint(bottomRightCoordinate)
        
        return MKMapRect(x: topLeftPoint.x,
                         y: topLeftPoint.y,
                         width: abs(topLeftPoint.x - bottomRightPoint.x),
                         height: abs(topLeftPoint.y - bottomRightPoint.y))
    }
    
    func contains(region: MKCoordinateRegion) -> Bool {
        return self.asMapRect.contains(region.asMapRect)
    }
}
