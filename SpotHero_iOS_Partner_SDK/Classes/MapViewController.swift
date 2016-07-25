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
    
    
    @IBOutlet weak var toolbarTitleLabel: UILabel!
    @IBOutlet weak var endTimeLabel: UILabel!
    @IBOutlet weak var endDateLabel: UILabel!
    @IBOutlet weak var startTimeLabel: UILabel!
    @IBOutlet weak var startDateLabel: UILabel!
    @IBOutlet weak var datePickerViewBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var datePickerView: UIView!
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var toolbar: UIToolbar!
    
    let predictionController = PredictionController()
    private let searchBarHeight: CGFloat = 44
    private let reservationContainerViewHeight: CGFloat = 134
    private var isStartView = false
    private var startDate: NSDate?
    private var endDate: NSDate?
    
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
        
        self.setupTimeSelectionView()
        self.setupDatePickerView()

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
        self.datePickerView.hidden = true
        self.timeSelectionView.hidden = true
        self.reservationContainerViewHeightConstraint.constant = self.searchBarHeight
    }
    
    private func setupTimeSelectionView() {
        //TODO: Localize
        //TODO: refactor to use UIColor extension
        self.endDateLabel.text = "Select Time"
        self.endTimeLabel.text = ""
        self.endDateLabel.textColor = UIColor(red: 41.0/255.0,
                                              green: 91.0/255.0,
                                              blue: 106.0/255.0,
                                              alpha: 1.0)
        self.startDateLabel.textColor = UIColor(red: 0/255.0,
                                                green: 122/255.0,
                                                blue: 255/255.0,
                                                alpha: 1.0)
        self.startTimeLabel.textColor = UIColor(red: 0/255.0,
                                                green: 122/255.0,
                                                blue: 255/255.0,
                                                alpha: 1.0)
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
        self.isStartView = true
        self.showDatePickerView()
        //TODO: Localize
        self.toolbarTitleLabel.text = "Set Start Time"
    }
    
    @IBAction func endViewTapped(sender: AnyObject) {
        self.isStartView = false
        self.showDatePickerView()
        //TODO: Localize
        self.toolbarTitleLabel.text = "Set End Time"
    }
    
    private func setupDatePickerView() {
        self.hideDatePickerView()
        self.datePicker.minimumDate = self.dateByRoundingMinutesDownBy30()
        self.datePicker.date = self.dateByRoundingMinutesDownBy30()
    }
    
    private func showDatePickerView() {
        UIView.animateWithDuration(0.3) { 
            self.datePickerViewBottomConstraint.constant = 0
            self.view.layoutIfNeeded()
        }
    }
    
    private func hideDatePickerView() {
        UIView.animateWithDuration(0.3) { 
            self.datePickerViewBottomConstraint.constant = -200
            self.view.layoutIfNeeded()
        }
    }
    
    @IBAction func doneButtonPressed(sender: AnyObject) {
        self.hideDatePickerView()
    }
    
    @IBAction func datePickerValueDidChange(datePicker: UIDatePicker) {
        let date = datePicker.date
        if (self.isStartView) {
            
        } else {
            
        }
    }
    
    private func dateByRoundingMinutesDownBy30() -> NSDate {
        let today = NSDate()
        let unitFlags: NSCalendarUnit = [.Minute, .Second]
        let timeComponents = NSCalendar.currentCalendar().components(unitFlags, fromDate: today)
        let remain = timeComponents.minute % 30
        let interval: NSTimeInterval = Double(-((60 * remain) + timeComponents.second))
        return today.dateByAddingTimeInterval(interval)
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
