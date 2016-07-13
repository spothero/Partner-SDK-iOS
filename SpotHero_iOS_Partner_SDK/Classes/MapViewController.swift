//
//  MapViewController.swift
//  Pods
//
//  Created by Husein Kareem on 7/13/16.
//
//

import UIKit
import MapKit

class MapViewController: UIViewController {
    
    @IBOutlet weak private var mapView: MKMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setMapViewRegion()
    }
    
    private func setMapViewRegion() {
        let region = MKCoordinateRegionMake(CLLocationCoordinate2DMake(Constants.ChicagoLocation.coordinate.latitude, Constants.ChicagoLocation.coordinate.longitude),
                                            MKCoordinateSpanMake(0.1, 0.1))
        self.mapView.setRegion(region, animated: true)
        self.mapView.accessibilityLabel = AccessibilityStrings.MapView
    }
    
    @IBAction private func closeButtonPressed(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
}
