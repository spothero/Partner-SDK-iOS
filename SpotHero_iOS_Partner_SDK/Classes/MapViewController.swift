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
    @IBOutlet weak private var timeSelectionView: TimeSelectionView!
    @IBOutlet weak private var reservationContainerView: UIView!
    @IBOutlet weak private var reservationContainerViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak private var datePickerView: DatePickerView!
    @IBOutlet weak private var searchSpotsButton: UIButton!
    
    private let predictionController = PredictionController()
    private let searchBarHeight: CGFloat = 44
    private let reservationContainerViewHeight: CGFloat = 134
    private var startEndDateDifferenceInSeconds: NSTimeInterval = Constants.ThirtyMinutesInSeconds
    let checkoutSegueIdentifier = "showCheckout"
    
    var facilities = [Facility]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setMapViewRegion()
        self.setupViews()
        
        self.datePickerView.delegate = self.timeSelectionView
        self.timeSelectionView.delegate = self.datePickerView
        self.timeSelectionView.showTimeSelectionViewDelegate = self
        self.datePickerView.doneButtonDelegate = self
        self.timeSelectionView.startEndDateDelegate = self
    }
    
    private func setMapViewRegion() {
        let region = MKCoordinateRegion(center: Constants.ChicagoLocation.coordinate,
                                        span: MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1))
        self.mapView.setRegion(region, animated: true)
        self.mapView.accessibilityLabel = AccessibilityStrings.MapView
    }
    
    private func setupViews() {
        self.reservationContainerView.layer.cornerRadius = HeightsAndLengths.standardCornerRadius
        self.reservationContainerView.layer.masksToBounds = true
        
        self.searchSpotsButton.hidden = true
        self.searchSpotsButton.layer.cornerRadius = HeightsAndLengths.standardCornerRadius
        self.searchSpotsButton.layer.masksToBounds = true
        self.searchSpotsButton.backgroundColor = .shp_spotHeroBlue()
        
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
    
    func showCollapsedSearchBar() {
        guard let isEmpty = self.searchBar.text?.isEmpty else {
            return
        }
        self.searchSpotsButton.hidden = isEmpty
    }
    
    //MARK: Actions
    
    @IBAction private func closeButtonPressed(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func collapsedSearchBarTapped(sender: AnyObject) {
        self.collapsedSearchBar.hide()
        self.timeSelectionView.showTimeSelectionView(true)
        self.searchSpotsButton.hidden = false
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
    
    @IBAction func searchSpotsButtonPressed(sender: AnyObject) {
        self.searchSpotsButton.hidden = true
        self.collapsedSearchBar.show()
        self.timeSelectionView.showTimeSelectionView(false)
        let hoursBetweenDates = self.startEndDateDifferenceInSeconds / 3600
        self.collapsedSearchBar.text = String(format: LocalizedStrings.HoursBetweenDatesFormat, hoursBetweenDates)
    }
    
    //TODO: Remove when facility UI is done
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let vc = segue.destinationViewController as? CheckoutTableViewController {
            vc.facility = self.facilities.first
            vc.rate = self.facilities.first?.rates.first
        }
    }
}

//MARK: PredictionControllerDelegateHoursBetweenDates

extension MapViewController: PredictionControllerDelegate {
    func didUpdatePredictions(predictions: [GooglePlacesPrediction]) {
        self.predictionTableView.reloadData()
        self.view.layoutIfNeeded()
        UIView.animateWithDuration(Constants.ViewAnimationDuration, animations: {
            let headerFooterHeight: CGFloat = 28
            let rowHeight: CGFloat = 60
            
            if predictions.count > 0 {
                self.searchSpotsButton.hidden = true
                self.timeSelectionView.showTimeSelectionView(false)
                self.searchContainerViewHeightConstraint.constant = self.searchBarHeight + CGFloat(predictions.count) * rowHeight + headerFooterHeight * 2
                self.reservationContainerViewHeightConstraint.constant = self.searchBarHeight + CGFloat(predictions.count) * rowHeight + headerFooterHeight * 2
            } else {
                self.searchContainerViewHeightConstraint.constant = self.searchBarHeight
            }
            self.view.layoutIfNeeded()
            }, completion: nil)
    }
    
    func didSelectPrediction(prediction: GooglePlacesPrediction) {
        self.searchBar.text = prediction.description
        self.timeSelectionView.showTimeSelectionView(true)
        self.showCollapsedSearchBar()
    }
    
    func didTapXButton() {
        self.timeSelectionView.showTimeSelectionView(true)
        self.searchSpotsButton.hidden = true
    }
}

//MARK: ShowTimeSelectionViewDelegate

extension MapViewController: ShowTimeSelectionViewDelegate {
    func timeSelectionViewShouldShow(show: Bool) {
        UIView.animateWithDuration(Constants.ViewAnimationDuration) {
            self.reservationContainerViewHeightConstraint.constant = show ? self.reservationContainerViewHeight : self.searchBarHeight
            self.view.layoutIfNeeded()
        }
    }
}

//MARK: DatePickerDoneButtonDelegate

extension MapViewController: DatePickerDoneButtonDelegate {
    func didPressDoneButton() {
        self.showCollapsedSearchBar()
    }
}

//MARK: StartEndDateDelegate

extension MapViewController: StartEndDateDelegate {
    func didChangeStartEndDate(startDate startDate: NSDate, endDate: NSDate) {
        self.startEndDateDifferenceInSeconds = endDate.timeIntervalSinceDate(startDate)
    }
}
