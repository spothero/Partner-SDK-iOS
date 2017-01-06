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
    @IBOutlet weak private var searchSpotsButton: UIButton!
    @IBOutlet weak private var spotCardCollectionView: UICollectionView!
    @IBOutlet weak private var closeButton: UIBarButtonItem!
    @IBOutlet weak private var loadingView: UIView!
    @IBOutlet weak private var redoSearchButton: UIButton!
    @IBOutlet weak private var redoSearchButtonBottomConstraint: NSLayoutConstraint!
    
    private var prediction: GooglePlacesPrediction?
    private let predictionController = PredictionController()
    private var defaultSearchRadius: Double = UnitsOfMeasurement.MetersPerMile.rawValue
    private var predictionPlaceDetails: GooglePlaceDetails? {
        didSet {
            guard let details = self.predictionPlaceDetails else {
                return
            }
            
            self.clearExistingFacilities()
            
            // Add some padding around default region to account for screen being a rectangle
            let padding = 1.5
            
            if details.isAirport() {
                //have a wider search radius around airports.
                self.defaultSearchRadius = UnitsOfMeasurement.MetersPerMile.rawValue * 5 * padding
            } else {
                self.defaultSearchRadius = UnitsOfMeasurement.MetersPerMile.rawValue * padding
            }
            
            self.fetchFacilitiesIfPlaceDetailsExists()
        }
    }
    private var startDate: NSDate = NSDate().shp_roundDateToNearestHalfHour(roundDown: true)
    private var endDate: NSDate = NSDate().dateByAddingTimeInterval(Constants.SixHoursInSeconds).shp_roundDateToNearestHalfHour(roundDown: true)
    private let searchBarHeight: CGFloat = 44
    private let reservationContainerViewHeight: CGFloat = 134
    private var startEndDateDifferenceInSeconds: NSTimeInterval = Constants.SixHoursInSeconds
    private var centerCell: SpotCardCollectionViewCell? {
        willSet {
            self.centerCell?.buyButton.enabled = false
            self.centerCell?.buyButton.backgroundColor = .shp_spotHeroBlue()
        }
        didSet {
            self.centerCell?.buyButton.enabled = true
            self.centerCell?.buyButton.backgroundColor = .shp_green()
        }
    }
    private let checkoutSegueIdentifier = "showCheckout"
    private var selectedFacility: Facility?
    private var maxTableHeight: CGFloat = 0
    private var currentIndex: Int = 0
    private var initialLoading = false {
        didSet {
            if self.initialLoading {
                ProgressHUD.showHUDAddedTo(self.view, withText: LocalizedStrings.Loading)
            } else {
                ProgressHUD.hideHUDForView(self.view)
            }
        }
    }
    private var facilities = [Facility]()
    private let redoSearchButtonBottomConstraintConstant: CGFloat = 15
    private var hasMorePages = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setMapViewRegion()
        self.setupViews()
        self.registerForKeyboardNotifications()
        
        self.timeSelectionView.showTimeSelectionViewDelegate = self
        self.timeSelectionView.startEndDateDelegate = self
        
        guard let layout = self.spotCardCollectionView.collectionViewLayout as? SpotCardCollectionViewFlowLayout else {
            return
        }
        
        layout.delegate = self
        
        let mapDragRecognizer = UIPanGestureRecognizer(target: self, action: #selector(self.didDragMap(_:)))
        mapDragRecognizer.delegate = self
        self.mapView.addGestureRecognizer(mapDragRecognizer)
        let mapPinchRecognizer = UIPinchGestureRecognizer(target: self, action: #selector(self.didDragMap(_:)))
        mapPinchRecognizer.delegate = self
        self.mapView.addGestureRecognizer(mapPinchRecognizer)
        self.searchBar.becomeFirstResponder()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        NSNotificationCenter
            .defaultCenter()
            .addObserver(self,
                         selector: #selector(applicationWillEnterForeground(_:)),
                         name: UIApplicationWillEnterForegroundNotification,
                         object: nil)
        
        self.updateStartAndEndDatesVsCurrentTimeIfNeeded()
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
        NSNotificationCenter
            .defaultCenter()
            .removeObserver(self)
    }
    
    private func setupViews() {
        self.reservationContainerView.layer.cornerRadius = HeightsAndLengths.standardCornerRadius
        self.reservationContainerView.layer.masksToBounds = true
        
        self.searchSpotsButton.hidden = true
        self.searchSpotsButton.layer.cornerRadius = HeightsAndLengths.standardCornerRadius
        self.searchSpotsButton.backgroundColor = .shp_spotHeroBlue()
        
        self.redoSearchButton.layer.cornerRadius = HeightsAndLengths.redoSearchButtonCornerRadius
        self.redoSearchButton.setTitleColor(.shp_spotHeroBlue(), forState: .Normal)
        self.redoSearchButton.setTitleColor(.grayColor(), forState: .Disabled)
        self.redoSearchButton.hidden = true
        
        self.predictionController.delegate = self
        
        self.spotCardCollectionView.hidden = true
        
        self.predictionTableView.dataSource = self.predictionController
        self.predictionTableView.delegate = self.predictionController
        self.searchBar.delegate = self.predictionController
        
        let bundle = NSBundle.shp_resourceBundle()
        
        self.predictionTableView.registerNib(UINib(nibName: String(GooglePredictionTableHeader), bundle: bundle),
                                             forHeaderFooterViewReuseIdentifier: GooglePredictionTableHeader.reuseIdentifier)
        self.predictionTableView.registerNib(UINib(nibName: String(GooglePredictionTableFooter), bundle: bundle),
                                             forHeaderFooterViewReuseIdentifier: GooglePredictionTableFooter.reuseIdentifier)
        
        self.searchBar.accessibilityLabel = AccessibilityStrings.SearchBar
        self.predictionTableView.accessibilityLabel = AccessibilityStrings.PredictionTableView
        self.timeSelectionView.accessibilityLabel = AccessibilityStrings.TimeSelectionView
        self.closeButton.accessibilityLabel = LocalizedStrings.Close
        self.spotCardCollectionView.accessibilityLabel = AccessibilityStrings.SpotCards
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let vc = segue.destinationViewController as? CheckoutTableViewController {
            vc.facility = self.selectedFacility
            vc.rate = self.selectedFacility?.availableRates.first
        }
    }
    
    private func hideSearchSpots() {
        self.searchSpotsButton.hidden = (self.searchBar.text ?? "").isEmpty
    }
    
    //MARK: Application lifecycle
    
    @objc private func applicationWillEnterForeground(notification: NSNotification) {
        self.updateStartAndEndDatesVsCurrentTimeIfNeeded()
    }
    
    private func updateStartAndEndDatesVsCurrentTimeIfNeeded() {
        self.timeSelectionView.startDatePicker.minimumDate = NSDate().shp_roundDateToNearestHalfHour(roundDown: true)
        
        // Make sure when coming back from the background that the start date is not before
        // the minimum start date.
        if let minimumDate = self.timeSelectionView.startDatePicker.minimumDate where self.startDate.shp_isBeforeDate(minimumDate) {
            let updatedStartDate = minimumDate // already rounded.
            self.timeSelectionView.startDate = updatedStartDate
            self.didChangeStartEndDate(startDate: updatedStartDate, endDate: self.endDate)
            
            // Now, make sure the end date is not before the updated start date
            if self.endDate.shp_isAfterDate(self.startDate) {
                let updatedEndDate = self.startDate
                    .dateByAddingTimeInterval(Constants.SixHoursInSeconds) //Start date is already rounded.
                self.timeSelectionView.endDate = updatedEndDate
                self.didChangeStartEndDate(startDate: self.startDate, endDate: updatedEndDate)
            }
            
            //Update any existing search to ensure shown prices are accurate.
            self.fetchFacilitiesIfPlaceDetailsExists()
        }
    }
    
    //MARK: MapView & Spot Cards Helpers
    
    private func setMapViewRegion() {
        let region = MKCoordinateRegion(center: Constants.ChicagoLocation.coordinate,
                                        span: MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1))
        self.mapView.setRegion(region, animated: true)
        self.mapView.accessibilityLabel = AccessibilityStrings.MapView
    }
    
    private func setCenterCell() {
        let itemIndex = NSIndexPath(forItem: self.currentIndex, inSection: 0)
        self.centerCell = self.spotCardCollectionView.cellForItemAtIndexPath(itemIndex) as? SpotCardCollectionViewCell
    }
    
    /**
     Adds annotations to the map
     
     - parameter panning: Pass true to cause the map not to zoom in on the facilities. Optional (Defaults to false)
     */
    private func addAndShowFacilityAnnotations(facilities: [Facility], firstSearch: Bool) {
        // Only add facilities not already in the list
        let facilitiesToAdd = facilities.filter() { return !self.facilities.contains($0) }
        self.facilities += facilitiesToAdd
        self.spotCardCollectionView.reloadData()
        
        for annotation in self.mapView.annotations {
            if annotation is MKPointAnnotation {
                self.mapView.removeAnnotation(annotation)
                break
            }
        }
        
        let locationAnnotation = MKPointAnnotation()
        if let placeDetails = self.predictionPlaceDetails {
            locationAnnotation.coordinate = placeDetails.location.coordinate
        } else {
            locationAnnotation.coordinate = self.mapView.centerCoordinate
        }
        locationAnnotation.title = self.facilities.isEmpty ? LocalizedStrings.NoSpotsFound : ""
        self.mapView.addAnnotation(locationAnnotation)
        
        var firstAnnotation: FacilityAnnotation?
        for facility in facilitiesToAdd {
            guard let index = self.facilities.indexOf(facility) else {
                //Something weird has happened here, let's just move on.
                continue
            }
            
            let facilityAnnotation = FacilityAnnotation(title: facility.title,
                                                        coordinate: facility.location.coordinate,
                                                        facility: facility,
                                                        index: index)
            if index == 0 {
                firstAnnotation = facilityAnnotation
            }
            
            self.mapView.addAnnotation(facilityAnnotation)
        }
        
        self.showSpotCardCollectionView()
        
        if let predictionPlaceDetails = predictionPlaceDetails where firstSearch {
            let coordinateRegion = MKCoordinateRegionMakeWithDistance(predictionPlaceDetails.location.coordinate,
                                                                      self.defaultSearchRadius,
                                                                      self.defaultSearchRadius)
            self.mapView.setRegion(coordinateRegion, animated: true)
        }
        
        guard let annotation = firstAnnotation else {
            return
        }
        
        if self.centerCell == nil {
            self.mapView.selectAnnotation(annotation, animated: true)
        }
    }
    
    /**
     Shows the annotations with the searched location in the center of the map
     */
    private func showAnnotations() {
        guard let placeDetails = self.predictionPlaceDetails else {
            return
        }
        
        var latitudeDelta: CLLocationDegrees = 0
        var longitudeDelta: CLLocationDegrees = 0
        
        // Loop through all annotations
        // Find the the difference in latitude and longitude from the searched location and the annotation and take the absolute value
        // Set the latitude and longitude deltas to the the new value if it is greater than the current value
        if self.mapView.annotations.count > 1 {
            for annotation in self.mapView.annotations {
                let latitude = abs(placeDetails.location.coordinate.latitude - annotation.coordinate.latitude)
                let longitude = abs(placeDetails.location.coordinate.longitude - annotation.coordinate.longitude)
                
                latitudeDelta = max(latitudeDelta, latitude)
                longitudeDelta = max(longitudeDelta, longitude)
            }
            // Multiply the deltas by 2 plus some extra padding
            let multiplier = 2.2
            
            latitudeDelta *= multiplier
            longitudeDelta *= multiplier
        } else {
            // Convert 1 mile to latitude/longitude degrees
            let delta = 1.0 / UnitsOfMeasurement.ApproximateMilesPerDegreeOfLatitude.rawValue
            latitudeDelta = delta
            longitudeDelta = delta
        }
        
        let region = MKCoordinateRegion(center: placeDetails.location.coordinate, span: MKCoordinateSpan(latitudeDelta: latitudeDelta, longitudeDelta: longitudeDelta))
        
        self.mapView.setRegion(region, animated: true)
    }
    
    private func showSpotCardCollectionView() {
        self.spotCardCollectionView.hidden = false
        self.redoSearchButtonBottomConstraint.constant = self.spotCardCollectionView.frame.height + self.redoSearchButtonBottomConstraintConstant
        self.spotCardCollectionView.reloadData()
    }
    
    private func scrollToSpotCardThenSelectAnnotation(withIndexPath indexPath: NSIndexPath) {
        self.scrollToSpotCard(withIndexPath: indexPath, tap: false)
        let annotation = self.mapView.annotations.flatMap {
            annotation in
            return annotation as? FacilityAnnotation
            }.filter { //Filters the array returned by flatmap
                typed in
                return typed.index == indexPath.row
            }.first //takes the first object returned by the filter
        
        if let annotation = annotation {
            self.mapView.selectAnnotation(annotation, animated: true)
        }
    }
    
    private func scrollToSpotCard(withIndexPath indexPath: NSIndexPath, tap: Bool) {
        self.currentIndex = indexPath.row
        self.spotCardCollectionView.scrollToItemAtIndexPath(indexPath,
                                                            atScrollPosition: .None,
                                                            animated: true)
        self.trackViewPin(tap)
    }
    
    private func visibleMapViewRadiusInMeters() -> Double {
        // Convert the difference between max and min latitude to miles for the diameter
        let diameter = self.mapView.region.span.latitudeDelta
            * UnitsOfMeasurement.ApproximateMilesPerDegreeOfLatitude.rawValue
            * UnitsOfMeasurement.MetersPerMile.rawValue
        return diameter / 2
    }
    
    //MARK: Google Autocomplete Helpers
    
    private func getPlaceDetails(prediction: GooglePlacesPrediction, completion: (GooglePlaceDetails?) -> ()) {
        self.initialLoading = true
        GooglePlacesWrapper.getPlaceDetails(prediction) {
            [weak self]
            placeDetails, error in
            if error != nil {
                self?.initialLoading = false
                completion(nil)
            } else {
                completion(placeDetails)
                //updating initialLoading handled in fetchFacilities()
            }
        }
    }
    
    private func searchPrediction() {
        if let prediction = self.prediction {
            self.getPlaceDetails(prediction, completion: {
                placeDetails in
                if let placeDetails = placeDetails {
                    self.predictionPlaceDetails = placeDetails
                }
            })
        }
    }
    
    //MARK: Facility Helpers
    
    /**
     Fetch the factilities around a given coordinate
     
     - parameter coordinate: coordinate to search around
     - parameter panning:    Whether or not this was triggered by the user panning the map.
     Passing true will cause there to be no loading spinner and no "No spots" error
     Optional (Defaults to false)
     */
    private func fetchFacilities(coordinate: CLLocationCoordinate2D, redo: Bool = false) {
        var maxSearchRadius = self.visibleMapViewRadiusInMeters()
        self.initialLoading = true
        maxSearchRadius = self.defaultSearchRadius
        self.centerCell = nil
        
        FacilityAPI.fetchFacilities(coordinate,
                                    starts: self.startDate,
                                    ends: self.endDate,
                                    maxSearchRadius: maxSearchRadius,
                                    completion: {
                                        [weak self]
                                        facilities, error, hasMorePages in
                                        let firstSearch = (self?.initialLoading == true)
                                        self?.initialLoading = false
                                        self?.hasMorePages = hasMorePages
                                        
                                        //If there are more pages, show the wee loading view.
                                        self?.loadingView.hidden = !hasMorePages
                                        
                                        if facilities.isEmpty && !hasMorePages && firstSearch {
                                            AlertView.presentErrorAlertView(LocalizedStrings.Sorry,
                                                message: LocalizedStrings.NoSpotsFound,
                                                from: self)
                                            MixpanelWrapper.track(.ViewedNoResultsFoundModal)
                                        } else {
                                            MixpanelWrapper.track(.ViewedSearchResultsScreen)
                                        }
                                        
                                        self?.addAndShowFacilityAnnotations(facilities, firstSearch: firstSearch)
                                        
                                        if !hasMorePages && !facilities.isEmpty {
                                            self?.trackUserSearch(redo, type: "Search")
                                        }
            })
    }
    
    private func searchSpots() {
        self.searchSpotsButton.hidden = true
        self.showCollapsedSearchBar()
        self.searchPrediction()
        self.searchBar.resignFirstResponder()
    }
    
    private func clearExistingFacilities() {
        self.facilities = []
        self.currentIndex = 0
        self.spotCardCollectionView.reloadData()
        self.mapView.removeAnnotations(self.mapView.annotations)
    }
    
    //MARK: Actions
    
    @IBAction private func closeButtonPressed(sender: AnyObject) {
        SpotHeroPartnerSDK.SharedInstance.reportSDKClosed()
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction private func collapsedSearchBarTapped(sender: AnyObject) {
        self.collapsedSearchBar.hide()
        self.timeSelectionView.showTimeSelectionView(true)
        self.searchSpotsButton.hidden = false
    }
    
    @IBAction private func searchSpotsButtonPressed(sender: AnyObject) {
        self.searchSpots()
    }
    
    @objc private func didDragMap(gestureRecognizer: UIGestureRecognizer) {
        switch gestureRecognizer.state {
        case .Began:
            self.spotCardCollectionView.hidden = true
            self.redoSearchButton.hidden = true
            self.searchBar.resignFirstResponder()
        case .Ended:
            self.redoSearchButton.hidden = false
            if self.spotCardCollectionView.numberOfItemsInSection(0) > 0 {
                self.showSpotCardCollectionView()
            } else {
                self.redoSearchButtonBottomConstraint.constant = self.redoSearchButtonBottomConstraintConstant
            }
        default:
            break
        }
    }
    
    @IBAction private func didTapMapView(sender: AnyObject) {
        if facilities.isEmpty {
            self.view.endEditing(true)
            self.timeSelectionView.deselect()
        } else {
            self.showCollapsedSearchBar()
            self.searchSpotsButton.hidden = true
        }
    }
    
    @IBAction private func redoSearchButtonPressed(sender: AnyObject) {
        self.redoSearchButton.hidden = true
        self.clearExistingFacilities()
        self.predictionPlaceDetails = nil
        self.searchSpotsButton.hidden = true
        self.showCollapsedSearchBar()
        self.fetchFacilities(self.mapView.centerCoordinate, redo: true)
    }
    
    //MARK: Helpers

    private func showCollapsedSearchBar() {
        self.collapsedSearchBar.show()
        self.timeSelectionView.showTimeSelectionView(false)
        self.collapsedSearchBar.time = NSCalendar.currentCalendar().components([.Hour, .Day, .Minute],
                                                                               fromDate: self.startDate,
                                                                               toDate: self.endDate,
                                                                               options: [])
    }
    
    private func fetchFacilitiesIfPlaceDetailsExists() {
        if let placeDetails = self.predictionPlaceDetails {
            self.fetchFacilities(placeDetails.location.coordinate)
        }
    }
    
    private func trackViewPin(tap: Bool = true) {
        let facility = self.facilities[self.currentIndex]
        
        MixpanelWrapper.track(.TappedSpotPin, properties: [
            .TappedPin: true,
            .ViewingMethod: tap ? "tap" : "swipe",
            .SpotAddress: facility.streetAddress,
            .Distance: facility.distanceInMeters,
            .SpotID: facility.parkingSpotID,
            ])
    }
    
    private func trackUserSearch(redo: Bool = false, type: String) {
        let facility = self.facilities[self.currentIndex]
        
        if let prediction = self.prediction {
            MixpanelWrapper.track(.UserSearched, properties: [
                .SearchQuery: prediction.predictionDescription,
                .TappedRedoSearch: redo,
                .OptimalZoom: self.defaultSearchRadius,
                .ResultsWithinOptimalZoom: self.facilities.count,
                .SpotHeroCity: facility.city,
                .SearchType: type,
                .ReservationLength: NSCalendar.currentCalendar().components([.Hour], fromDate: self.startDate, toDate: self.endDate, options: [.WrapComponents]).hour,
                .TimeFromReservationStart: facility.availableRates.first?.minutesToReservation() ?? 0,
                ])
        }
    }
}

//MARK: PredictionControllerDelegateHoursBetweenDates

extension MapViewController: PredictionControllerDelegate {
    func didUpdatePredictions(predictions: [GooglePlacesPrediction]) {
        self.predictionTableView.reloadData()
        self.view.layoutIfNeeded()
        UIView.animateWithDuration(Constants.ViewAnimationDuration,
                                   animations: {
                                    let headerFooterHeight: CGFloat = 28
                                    let rowHeight: CGFloat = 60
                                    
                                    if !predictions.isEmpty {
                                        self.searchSpotsButton.hidden = true
                                        self.timeSelectionView.showTimeSelectionView(false)
                                        let dynamicHeight = self.searchBarHeight + CGFloat(predictions.count) * rowHeight + headerFooterHeight * 2
                                        let height = min(dynamicHeight, self.maxTableHeight)
                                        self.searchContainerViewHeightConstraint.constant = height
                                        self.reservationContainerViewHeightConstraint.constant = height
                                    } else if predictions.isEmpty && self.searchBar.text?.isEmpty == true {
                                        self.searchContainerViewHeightConstraint.constant = self.searchBarHeight
                                    } else {
                                        self.searchContainerViewHeightConstraint.constant = self.searchBarHeight
                                        self.reservationContainerViewHeightConstraint.constant = self.searchBarHeight
                                    }
                                    
                                    self.view.layoutIfNeeded()
            },
                                   completion: nil)
    }
    
    func didSelectPrediction(prediction: GooglePlacesPrediction) {
        self.prediction = prediction
        self.redoSearchButton.hidden = true
        self.searchBar.text = prediction.predictionDescription
        self.timeSelectionView.showTimeSelectionView(true)
        self.hideSearchSpots()
        self.searchBar.resignFirstResponder()
        self.timeSelectionView.startViewSelected = true
    }
    
    func didTapXButton() {
        self.timeSelectionView.showTimeSelectionView(true)
        self.searchSpotsButton.hidden = true
    }
    
    func didTapSearchButton() {
        guard self.predictionController.predictions.count > 0 else {
            return
        }
        
        let indexPath = NSIndexPath(forRow: 0, inSection: 0)
        self.predictionController.tableView(self.predictionTableView, didSelectRowAtIndexPath: indexPath)
        self.searchSpots()
    }
    
    func shouldSelectFirstPrediction() {
        guard self.predictionController.predictions.count > 0 else {
            return
        }
        
        let indexPath = NSIndexPath(forRow: 0, inSection: 0)
        self.predictionTableView.selectRowAtIndexPath(indexPath, animated: true, scrollPosition: .None)
    }
    
    func didBeginEditingSearchBar() {
        self.timeSelectionView.deselect()
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
    
    func didPressEndDoneButton() {
        guard let text = searchBar.text where !text.isEmpty else {
            return
        }
        
        self.searchSpots()
    }
}

//MARK: StartEndDateDelegate

extension MapViewController: StartEndDateDelegate {
    func didChangeStartEndDate(startDate startDate: NSDate, endDate: NSDate) {
        self.startDate = startDate
        self.endDate = endDate
        self.startEndDateDifferenceInSeconds = endDate.timeIntervalSinceDate(startDate)
    }
    
    func didSelectStartEndView() {
        self.searchBar.resignFirstResponder()
    }
}

//MARK: MKMapViewDelegate

extension MapViewController: MKMapViewDelegate {
    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
        if annotation is MKPointAnnotation {
            return self.locationAnnotationView(annotation)
        }
        
        guard let annotationView = mapView.dequeueReusableAnnotationViewWithIdentifier(FacilityAnnotationView.Identifier) as? FacilityAnnotationView else {
            return FacilityAnnotationView(annotation: annotation, reuseIdentifier: FacilityAnnotationView.Identifier)
        }
        
        if let facilityAnnotation = annotation as? FacilityAnnotation {
            annotationView.annotation = facilityAnnotation
        }
        return annotationView
    }
    
    func mapView(mapView: MKMapView, didSelectAnnotationView view: MKAnnotationView) {
        guard let facilityAnnotation = view.annotation as? FacilityAnnotation else {
            return
        }
        
        let itemIndex = NSIndexPath(forItem: facilityAnnotation.index, inSection: 0)
        self.scrollToSpotCard(withIndexPath: itemIndex, tap: true)
    }
    
    func mapView(mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        if self.hasMorePages {
            self.redoSearchButton.enabled = false
        } else if self.visibleMapViewRadiusInMeters() > Constants.MaxSearchRadiusInMeters {
            self.redoSearchButton.enabled = false
        } else {
            self.redoSearchButton.enabled = true
        }
    }
    
    private func locationAnnotationView(annotation: MKAnnotation) -> MKAnnotationView {
        let annotationView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: "LocationAnnotation")
        annotationView.canShowCallout = self.facilities.isEmpty
        annotationView.enabled = self.facilities.isEmpty
        annotationView.pinTintColor = self.facilities.isEmpty ? .redColor() : .greenColor()
        return annotationView
    }
}

//MARK: UICollectionViewDataSource

extension MapViewController: UICollectionViewDataSource {
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.facilities.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCellWithReuseIdentifier(SpotCardCollectionViewCell.Identifier, forIndexPath: indexPath) as? SpotCardCollectionViewCell else {
            return UICollectionViewCell()
        }
        
        let facility = self.facilities[indexPath.row]
        cell.buyButton.setTitle(LocalizedStrings.BookIt + " | $\(facility.displayPrice())", forState: .Normal)
        cell.streetAddressLabel.text = facility.streetAddress
        let distanceInMiles = UnitsOfMeasurement.distanceInMiles(Double(facility.distanceInMeters))
        //TODO: localize miles
        cell.spotInfoLabel.text = String(format: "\(LocalizedStrings.Distance): %.2f mi", distanceInMiles)
        
        if let rate = facility.availableRates.first {
            if rate.isWheelchairAccessible() {
                cell.accessibleParkingImageView.hidden = false
            } else {
                cell.accessibleParkingImageView.hidden = true
            }
            
            cell.accessibleParkingImageViewWidthConstraint.constant = rate.isWheelchairAccessible() ? 30 : 0
            
            cell.noReentryImageView.hidden = rate.allowsReentry()
        }
        
        self.setCenterCell()
        
        cell.delegate = self
        return cell
    }
}

//MARK: UICollectionViewDelegate

extension MapViewController: UICollectionViewDelegate {
    func collectionView(collectionView: UICollectionView, didEndDisplayingCell cell: UICollectionViewCell, forItemAtIndexPath indexPath: NSIndexPath) {
        self.setCenterCell()
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        if self.currentIndex != indexPath.row {
            self.scrollToSpotCardThenSelectAnnotation(withIndexPath: indexPath)
        }
    }
}

//MARK: UIScrollViewDelegate

extension MapViewController: UIScrollViewDelegate {
    func scrollViewDidEndScrollingAnimation(scrollView: UIScrollView) {
        self.setCenterCell()
    }
}

//MARK: SpotCardCollectionViewDelegate

extension MapViewController: SpotCardCollectionViewDelegate {
    func didTapDoneButton(button: UIButton) {
        guard
            let cell = button.superview?.superview as? SpotCardCollectionViewCell,
            let indexPath = self.spotCardCollectionView.indexPathForCell(cell) else {
                assertionFailure("cannot find spot card cell")
                return
        }
        self.selectedFacility = self.facilities[indexPath.row]
        self.performSegueWithIdentifier(self.checkoutSegueIdentifier, sender: nil)
    }
}

// MARK: - KeyboardNotification

extension MapViewController: KeyboardNotification {
    func registerForKeyboardNotifications() {
        NSNotificationCenter.defaultCenter().addObserverForName(UIKeyboardWillShowNotification,
                                                                object: nil,
                                                                queue: nil) {
                                                                    [weak self]
                                                                    notification in
                                                                    guard
                                                                        let userInfo = notification.userInfo,
                                                                        let frame = userInfo[UIKeyboardFrameEndUserInfoKey] as? NSValue,
                                                                        let viewHeight = self?.view.frame.height,
                                                                        let searchBarHeight = self?.searchBarHeight else {
                                                                            return
                                                                    }
                                                                    
                                                                    let rect = frame.CGRectValue()
                                                                    let totalPadding: CGFloat = 40
                                                                    self?.maxTableHeight = viewHeight - rect.height - totalPadding - searchBarHeight
        }
        
        NSNotificationCenter.defaultCenter().addObserverForName(UIKeyboardWillHideNotification,
                                                                object: nil,
                                                                queue: nil) {
                                                                    [weak self]
                                                                    notification in
                                                                    guard
                                                                        let viewHeight = self?.view.frame.height,
                                                                        let searchBarHeight = self?.searchBarHeight else {
                                                                            return
                                                                    }
                                                                    
                                                                    let totalPadding: CGFloat = 40
                                                                    self?.maxTableHeight = viewHeight - totalPadding - searchBarHeight
        }
    }
}

//MARK: SpotCardCollectionViewFlowLayoutDelegate

extension MapViewController: SpotCardCollectionViewFlowLayoutDelegate {
    func didSwipeCollectionView(direction: UISwipeGestureRecognizerDirection) {
        switch direction {
        case UISwipeGestureRecognizerDirection.Left:
            if self.currentIndex + 1 < self.facilities.count {
                self.currentIndex += 1
            } else {
                return
            }
        case UISwipeGestureRecognizerDirection.Right:
            if self.currentIndex > 0 {
                self.currentIndex -= 1
            } else {
                return
            }
        default:
            return
        }
        
        let itemIndex = NSIndexPath(forItem: self.currentIndex, inSection: 0)
        self.scrollToSpotCardThenSelectAnnotation(withIndexPath: itemIndex)
    }
}

// MARK: - UIGestureRecognizerDelegate

extension MapViewController: UIGestureRecognizerDelegate {
    func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWithGestureRecognizer otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}
