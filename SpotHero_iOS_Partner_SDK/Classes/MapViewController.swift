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
    private var datePickerDate: NSDate?
    
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
    
    @IBAction private func closeButtonPressed(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func collapsedSearchBarTapped(sender: AnyObject) {
        self.collapsedSearchBar.hide()
        self.showTimeSelectionView()
    }
    
    private func showCollapsedSearchBar() {
        if (self.startDate != nil && self.endDate != nil && self.searchBar.text?.characters.count > 0) {
            self.collapsedSearchBar.show()
            self.hideTimeSelectionView()
            //TODO: Set time label
        }
    }
    
    //MARK: Time Selection View - setup like collapsed search bar view?
    
    private func setupTimeSelectionView() {
        let startDate = self.dateByRoundingMinutesDownBy30()
        let endDate = self.dateByRoundingMinutesUpBy30(startDate)
        self.startDate = startDate
        self.endDate = endDate
        self.startTimeLabel.text = DateFormatter.TimeOnly.stringFromDate(startDate)
        self.startDateLabel.text = DateFormatter.PrettyMonthDayDate.stringFromDate(startDate)
        self.endTimeLabel.text = DateFormatter.TimeOnly.stringFromDate(endDate)
        self.endDateLabel.text = DateFormatter.PrettyMonthDayDate.stringFromDate(endDate)
        
    }
    
    private func showTimeSelectionView() {
        self.timeSelectionView.hidden = false
        UIView.animateWithDuration(0.3) {
            self.reservationContainerViewHeightConstraint.constant = self.reservationContainerViewHeight
            self.view.layoutIfNeeded()
        }
    }
    
    private func hideTimeSelectionView() {
        self.hideDatePickerView()
        self.timeSelectionView.hidden = true
        UIView.animateWithDuration(0.3) {
            self.reservationContainerViewHeightConstraint.constant = self.searchBarHeight
            self.view.layoutIfNeeded()
        }
    }
    
    @IBAction func startViewTapped(sender: AnyObject) {
        self.isStartView = true
        self.setStartEndViewSelected()
        self.showDatePickerView()
        self.datePicker.minimumDate = self.startDate
        //FIXME: use datebyroundingdown enddate
        self.datePicker.maximumDate = self.endDate
        //pass in so no guard let everywhere?
        guard let startDate = self.startDate else {
            return
        }
        self.datePicker.date = startDate
        //TODO: Localize
        self.toolbarTitleLabel.text = "Set Start Time"
    }
    
    @IBAction func endViewTapped(sender: AnyObject) {
        self.isStartView = false
        self.setStartEndViewSelected()
        self.showDatePickerView()
        
        guard let
            startDate = self.startDate,
            endDate = self.endDate else {
                return
        }
        self.datePicker.minimumDate = self.dateByRoundingMinutesUpBy30(startDate)
        self.datePicker.maximumDate = nil
        self.datePicker.date = endDate
        //TODO: Localize
        self.toolbarTitleLabel.text = "Set End Time"
    }
    
    private func setStartEndViewSelected() {
        if (self.isStartView) {
            //TODO: UIColor extension ,SpotHero blue
            self.startDateLabel.textColor = UIColor(red: 0/255.0,
                                                    green: 122/255.0,
                                                    blue: 255/255.0,
                                                    alpha: 1.0)
            self.startTimeLabel.textColor = UIColor(red: 0/255.0,
                                                    green: 122/255.0,
                                                    blue: 255/255.0,
                                                    alpha: 1.0)
            self.endDateLabel.textColor = UIColor.blackColor()
            self.endTimeLabel.textColor = UIColor.blackColor()
        } else {
            //TODO: UIColor extension ,SpotHero blue
            self.endDateLabel.textColor = UIColor(red: 0/255.0,
                                                  green: 122/255.0,
                                                  blue: 255/255.0,
                                                  alpha: 1.0)
            self.endTimeLabel.textColor = UIColor(red: 0/255.0,
                                                  green: 122/255.0,
                                                  blue: 255/255.0,
                                                  alpha: 1.0)
            self.startDateLabel.textColor = UIColor.blackColor()
            self.startTimeLabel.textColor = UIColor.blackColor()
        }
    }
    
    private func setStartEndViewUnselected() {
        self.startDateLabel.textColor = UIColor.blackColor()
        self.startTimeLabel.textColor = UIColor.blackColor()
        self.endDateLabel.textColor = UIColor.blackColor()
        self.endTimeLabel.textColor = UIColor.blackColor()
    }
    
    
    //MARK: Date Picker View - setup like collapsed search bar view?
    
    private func setupDatePickerView() {
        //TODO: Constant? -200
        self.datePickerViewBottomConstraint.constant = -200
        self.view.layoutIfNeeded()
        self.datePicker.minimumDate = self.dateByRoundingMinutesDownBy30()
        self.datePicker.date = self.dateByRoundingMinutesDownBy30()
    }
    
    @IBAction func doneButtonPressed(sender: AnyObject) {
        self.hideDatePickerView()
        self.setStartEndViewUnselected()
        self.showCollapsedSearchBar()
    }
    
    @IBAction func datePickerValueDidChange(datePicker: UIDatePicker) {
        self.datePickerDate = datePicker.date
        guard let date = self.datePickerDate else {
            return
        }
        self.setStartEndDateTimeLabelWithDate(date)
    }
    
    private func setStartEndDateTimeLabelWithDate(date: NSDate) {
        if (self.isStartView) {
            self.startDate = date
            if (self.endDate?.timeIntervalSinceDate(date) < 1800) {
                self.endDate = self.dateByRoundingMinutesUpBy30(date)
            }
        } else {
            self.endDate = date
        }
        
        guard let
            startDate = self.startDate,
            endDate = self.endDate else {
                return
        }
        self.startDateLabel.text = DateFormatter.PrettyMonthDayDate.stringFromDate(startDate)
        self.startTimeLabel.text = DateFormatter.TimeOnly.stringFromDate(startDate)
        self.endDateLabel.text = DateFormatter.PrettyMonthDayDate.stringFromDate(endDate)
        self.endTimeLabel.text = DateFormatter.TimeOnly.stringFromDate(endDate)
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
    
    //TODO: Move to DateFormatter.swift, rename?
    private func dateByRoundingMinutesDownBy30() -> NSDate {
        let today = NSDate()
        let unitFlags: NSCalendarUnit = [.Minute, .Second]
        let timeComponents = NSCalendar.currentCalendar().components(unitFlags, fromDate: today)
        let remain = timeComponents.minute % 30
        let interval: NSTimeInterval = Double(-((60 * remain) + timeComponents.second))
        return today.dateByAddingTimeInterval(interval)
    }
    
    //TODO: Move to DateFormatter.swift, rename?
    private func dateByRoundingMinutesUpBy30(date: NSDate) -> NSDate {
        let date = date
        let unitFlags: NSCalendarUnit = [.Minute, .Second]
        let timeComponents = NSCalendar.currentCalendar().components(unitFlags, fromDate: date)
        let remain = timeComponents.minute % 30
        let interval: NSTimeInterval = Double((60 * (30 - remain) - timeComponents.second))
        return date.dateByAddingTimeInterval(interval)
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
                self.searchContainerViewHeightConstraint.constant = self.searchBarHeight
            }
            self.view.layoutIfNeeded()
            }, completion: nil)
    }
    
    func didSelectPrediction(prediction: GooglePlacesPrediction) {
        self.searchBar.text = prediction.description
        self.showTimeSelectionView()
        self.showCollapsedSearchBar()
    }
    
    func didTapXButton() {
        self.showTimeSelectionView()
    }
}
