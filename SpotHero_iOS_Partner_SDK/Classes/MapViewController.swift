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
    @IBOutlet weak private var predictionTableView: UITableView!
    @IBOutlet weak private var mapView: MKMapView!
    @IBOutlet weak private var searchContainerView: UIView!
    @IBOutlet weak private var searchContainerViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak private var searchBar: UISearchBar!
    @IBOutlet weak private var collapsedSearchBar: CollapsedSearchBarView!
    
    let checkoutSegueIdentifier = "showCheckout"
    let predictionController = PredictionController()
    
    var facilities = [Facility]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setMapViewRegion()
        self.setupViews()
    }
    
    private func setMapViewRegion() {
        let region = MKCoordinateRegion(center: Constants.ChicagoLocation.coordinate,
                                        span: MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1))
        self.mapView.setRegion(region, animated: true)
        self.mapView.accessibilityLabel = AccessibilityStrings.MapView
    }
    
    private func setupViews() {
        self.searchContainerView.layer.cornerRadius = HeightsAndLengths.standardCornerRadius
        self.searchContainerView.layer.masksToBounds = true
        
        self.predictionController.delegate = self
        
        self.predictionTableView.dataSource = self.predictionController
        self.predictionTableView.delegate = self.predictionController
        self.searchBar.delegate = self.predictionController
        
        let bundle = NSBundle(forClass: MapViewController.self)
        
        self.predictionTableView.registerNib(UINib(nibName: String(GooglePredictionTableHeader), bundle: bundle),
            forHeaderFooterViewReuseIdentifier: GooglePredictionTableHeader.reuseIdentifier)
        self.predictionTableView.registerNib(UINib(nibName: String(GooglePredictionTableFooter), bundle: bundle),
            forHeaderFooterViewReuseIdentifier: GooglePredictionTableFooter.reuseIdentifier)
        
        self.searchBar.accessibilityLabel = AccessibilityStrings.SearchBar
        self.predictionTableView.accessibilityLabel = AccessibilityStrings.PredictionTableView
    }
    
    @IBAction private func closeButtonPressed(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func searchBarTapped(sender: AnyObject) {
        self.collapsedSearchBar.hide()
    }
    
    //TEMP! Only for testing
    
    //TODO: Remove when facility UI is done
    @IBAction func tempCheckoutButtonPressed(sender: AnyObject) {
        FacilityAPI.fetchFacilities(Constants.ChicagoLocation,
                                    starts: NSDate().dateByAddingTimeInterval(60 * 60 * 2),
                                    ends: NSDate().dateByAddingTimeInterval(60 * 60 * 5)) {
                                        facilities, error -> (Void) in
                                        self.facilities = facilities
                                        NSOperationQueue.mainQueue().addOperationWithBlock() {
                                            self.performSegueWithIdentifier(self.checkoutSegueIdentifier, sender: nil)
                                        }
        }
    }
    
    //TODO: Remove when facility UI is done
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let vc = segue.destinationViewController as? CheckoutTableViewController {
            vc.facility = facilities.first
            vc.rate = facilities.first?.rates.first
        }
    }
}

//MARK: PredictionControllerDelegate

extension MapViewController: PredictionControllerDelegate {
    func didUpdatePredictions(predictions: [GooglePlacesPrediction]) {
        self.predictionTableView.reloadData()
        self.view.layoutIfNeeded()
        UIView.animateWithDuration(0.3, animations: {
            let searchBarHeight: CGFloat = 44
            let headerFooterHeight: CGFloat = 28
            let rowHeight: CGFloat = 60
            
            if predictions.count > 0 {
                self.searchContainerViewHeightConstraint.constant = searchBarHeight + CGFloat(predictions.count) * rowHeight + headerFooterHeight * 2
            } else {
                self.searchContainerViewHeightConstraint.constant = searchBarHeight
            }
            self.view.layoutIfNeeded()
            }, completion: nil)
    }
    
    func didSelectPrediction(prediction: GooglePlacesPrediction) {
        self.searchBar.text = prediction.description
    }
}
