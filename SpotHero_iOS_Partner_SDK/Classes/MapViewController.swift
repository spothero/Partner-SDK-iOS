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
    @IBOutlet weak private var timeSelectionView: UIView!
    @IBOutlet weak var reservationContainerView: UIView!
    @IBOutlet weak var reservationContainerViewHeightConstraint: NSLayoutConstraint!
    
    let predictionController = PredictionController()
    private let searchBarHeight: CGFloat = 44
    private let reservationContainerViewHeight: CGFloat = 134
    
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
        self.reservationContainerView.layer.cornerRadius = 5
        self.reservationContainerView.layer.masksToBounds = true
        
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
    
    private func hideTimeSelectionView() {
        self.timeSelectionView.hidden = true
        self.reservationContainerViewHeightConstraint.constant = self.searchBarHeight
    }
    
    private func showTimeSelectionView() {
        self.timeSelectionView.hidden = false
        self.reservationContainerViewHeightConstraint.constant = self.reservationContainerViewHeight
    }
    
    @IBAction private func closeButtonPressed(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func collapsedSearchBarTapped(sender: AnyObject) {
        self.collapsedSearchBar.hide()
        self.timeSelectionView.hidden = true
    }
    
    @IBAction func startViewTapped(sender: AnyObject) {
        //TODO: Show date picker
    }
    
    @IBAction func endViewTapped(sender: AnyObject) {
        //TODO: Show date picker
    }
}

//MARK: PredictionControllerDelegate

extension MapViewController: PredictionControllerDelegate {
    func didUpdatePredictions(predictions: [GooglePlacesPrediction]) {
        self.predictionTableView.reloadData()
        self.view.layoutIfNeeded()
        UIView.animateWithDuration(0.3, animations: {
            let headerFooterHeight: CGFloat = 28
            let rowHeight: CGFloat = 60
            
            if predictions.count > 0 {
                self.hideTimeSelectionView()
                self.searchContainerViewHeightConstraint.constant = self.searchBarHeight + CGFloat(predictions.count) * rowHeight + headerFooterHeight * 2
                self.reservationContainerViewHeightConstraint.constant = self.searchBarHeight + CGFloat(predictions.count) * rowHeight + headerFooterHeight * 2
            } else {
                self.reservationContainerViewHeightConstraint.constant = self.reservationContainerViewHeight
                self.searchContainerViewHeightConstraint.constant = self.searchBarHeight
            }
            self.view.layoutIfNeeded()
            }, completion: nil)
    }
    
    func didSelectPrediction(prediction: GooglePlacesPrediction) {
        self.searchBar.text = prediction.description
        self.showTimeSelectionView()
    }
    
    func didTapXButton() {
        self.showTimeSelectionView()
    }
}
