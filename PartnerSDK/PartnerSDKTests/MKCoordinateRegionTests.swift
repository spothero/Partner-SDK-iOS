//
//  MKCoordinateRegionTests.swift
//  PartnerSDKTests
//
//  Created by Reed.Hogan on 6/10/19.
//  Copyright © 2019 SpotHero, Inc. All rights reserved.
//

import CoreLocation
import MapKit
@testable import SpotHero_iOS_Partner_SDK
import XCTest

class MKCoordinateRegionTests: XCTestCase {
    
    func testConcentricRegions() {
        let center = CLLocationCoordinate2D(latitude: 0, longitude: 0)
        let outerRegion = MKCoordinateRegion(center: center, radius: 100)
        let innerRegion = MKCoordinateRegion(center: center, radius: 90)
        XCTAssertTrue(outerRegion.contains(region: innerRegion))
        XCTAssertFalse(innerRegion.contains(region: outerRegion))
    }
    
    func testSameRegionContainsItself() {
        let center = CLLocationCoordinate2D(latitude: 0, longitude: 0)
        let region = MKCoordinateRegion(center: center, radius: 100)
        XCTAssertTrue(region.contains(region: region))
    }
    
    func testPartiallyOverlappingRegionsDoNotContainEachOther() {
        let center1 = CLLocationCoordinate2D(latitude: 0, longitude: 0)
        let center2 = CLLocationCoordinate2D(latitude: 0, longitude: 2)
        
        // if the centers have the same latitude and a 2 degree difference in longitude
        // any span of more than 1 degree longitude is guaranteed to overlap
        let span = MKCoordinateSpan(latitudeDelta: 1.5, longitudeDelta: 1.5)
        
        let region1 = MKCoordinateRegion(center: center1, span: span)
        let region2 = MKCoordinateRegion(center: center2, span: span)
        
        // if the regions are partially overlapping, neither region should contain the other
        XCTAssertFalse(region1.contains(region: region2))
        XCTAssertFalse(region2.contains(region: region1))
    }
    
    func testNonOverlappingRegions() {
        let center1 = CLLocationCoordinate2D(latitude: 0, longitude: 0)
        let center2 = CLLocationCoordinate2D(latitude: 0, longitude: 2)
        
        // if the centers have the same latitude and a 2 degree difference in longitude
        // any span of less than 1 degree longitude is guaranteed to not overlap
        let span = MKCoordinateSpan(latitudeDelta: 0.5, longitudeDelta: 0.5)
        let region1 = MKCoordinateRegion(center: center1, span: span)
        let region2 = MKCoordinateRegion(center: center2, span: span)
        
        // regions that don't intersect should not contain each other
        XCTAssertFalse(region1.contains(region: region2))
        XCTAssertFalse(region2.contains(region: region1))
    }
    
    func testContainingRegionsWithDifferentCenters() {
        let center1 = CLLocationCoordinate2D(latitude: 0, longitude: 0)
        let center2 = CLLocationCoordinate2D(latitude: 0, longitude: 1)
        
        let smallSpan = MKCoordinateSpan(latitudeDelta: 1, longitudeDelta: 1)
        let largeSpan = MKCoordinateSpan(latitudeDelta: 5, longitudeDelta: 5)
        
        let region1 = MKCoordinateRegion(center: center1, span: largeSpan)
        let region2 = MKCoordinateRegion(center: center2, span: smallSpan)
        
        XCTAssertTrue(region1.contains(region: region2))
        XCTAssertFalse(region2.contains(region: region1))
    }
}
