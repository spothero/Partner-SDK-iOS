//
//  SearchCoordinator.swift
//  SpotHero_iOS_Partner_SDK
//
//  Created by Reed.Hogan on 5/20/19.
//  Copyright © 2019 SpotHero, Inc. All rights reserved.
//

import CoreLocation
import Foundation
import MapKit

protocol IdealSearchDistanceDelegate: AnyObject {
    func idealSearchDistanceUpdated(distance: Double, center: CLLocationCoordinate2D)
}

class SearchCoordinator {
    
    private var currentSearchTask: URLSessionTask?
    
    private let defaultSearchRadius = UnitsOfMeasurement.metersPerMile.rawValue / 2
    private let defaultMaxSearchRadius = UnitsOfMeasurement.metersPerMile.rawValue * 2
    
    private var idealSearchDistance: Double?
    private var lastSearchRegion: MKCoordinateRegion?
    private weak var delegate: IdealSearchDistanceDelegate?
    
    private(set) var hasStartedFirstSearch = false
    var hasIdealSearchDistance: Bool {
        return self.idealSearchDistance != nil
    }
    
    init(delegate: IdealSearchDistanceDelegate) {
        self.delegate = delegate
    }
    
    func fetchIdealSearchDistance(for coordinate: CLLocationCoordinate2D) {
        self.currentSearchTask = FacilityAPI.fetchIdealSearchDistanceForCoordinate(coordinate) { idealSearchDistance in
            // if fetching the ideal distance fails for some reason, just use a default value
            let radius = idealSearchDistance ?? self.defaultSearchRadius
            self.idealSearchDistance = radius
            self.delegate?.idealSearchDistanceUpdated(distance: radius, center: coordinate)
        }
    }
    
    func fetchFacilities(coordinate: CLLocationCoordinate2D,
                         starts: Date,
                         ends: Date,
                         visibleSearchRadius: Double,
                         completion: @escaping FacilityCompletion) {
        // use the visible map bounds as the search radius unless they exceed the default max search radius
        let maxRadius = min(visibleSearchRadius, self.defaultMaxSearchRadius)
        
        let newSearchRegion = MKCoordinateRegion(center: coordinate, radius: maxRadius)
        defer {
            self.lastSearchRegion = newSearchRegion
        }
        if
            let lastSearchRegion = self.lastSearchRegion,
            lastSearchRegion.contains(region: newSearchRegion) {
                // just return, we have already searched this area
                completion([], nil)
                return
        }
        self.hasStartedFirstSearch = true
        self.cancelCurrentSearch()
        self.currentSearchTask = FacilityAPI.fetchFacilities(coordinate,
                                                             starts: starts,
                                                             ends: ends,
                                                             maxSearchRadius: maxRadius,
                                                             completion: completion)
    }
    
    private func cancelCurrentSearch() {
        self.currentSearchTask?.cancel()
        self.currentSearchTask = nil
    }
    
}
