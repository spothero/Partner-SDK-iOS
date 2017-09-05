//
//  MapViewController.swift
//  Pods
//
//  Created by Husein Kareem on 7/13/16.
//
//

import MapKit
import UIKit

class MapViewController: UIViewController {
    
    @IBOutlet weak fileprivate var predictionTableView: UITableView!
    @IBOutlet weak private var mapView: MKMapView!
    @IBOutlet weak private var searchContainerView: UIView!
    @IBOutlet weak fileprivate var searchContainerViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak fileprivate var searchBar: UISearchBar!
    @IBOutlet weak private var collapsedSearchBar: CollapsedSearchBarView!
    @IBOutlet weak fileprivate var timeSelectionView: TimeSelectionView!
    @IBOutlet weak private var reservationContainerView: UIView!
    @IBOutlet weak fileprivate var reservationContainerViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak fileprivate var searchSpotsButton: UIButton!
    @IBOutlet weak fileprivate var spotCardCollectionView: UICollectionView!
    @IBOutlet weak private var closeButton: UIBarButtonItem!
    @IBOutlet weak private var loadingView: UIView!
    @IBOutlet weak fileprivate var redoSearchButton: UIButton!
    @IBOutlet weak private var redoSearchButtonBottomConstraint: NSLayoutConstraint!
    
    fileprivate var prediction: GooglePlacesPrediction?
    fileprivate let predictionController = PredictionController()
    private var defaultSearchRadius: Double = UnitsOfMeasurement.metersPerMile.rawValue
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
                self.defaultSearchRadius = UnitsOfMeasurement.metersPerMile.rawValue * 5 * padding
            } else {
                self.defaultSearchRadius = UnitsOfMeasurement.metersPerMile.rawValue * padding
            }
            
            self.fetchFacilitiesIfPlaceDetailsExists()
        }
    }
    fileprivate var startDate: Date = Date().shp_roundDateToNearestHalfHour(roundDown: true)
    fileprivate var endDate: Date = Date().addingTimeInterval(Constants.SixHoursInSeconds).shp_roundDateToNearestHalfHour(roundDown: true)
    fileprivate let searchBarHeight: CGFloat = 44
    fileprivate let reservationContainerViewHeight: CGFloat = 134
    fileprivate var startEndDateDifferenceInSeconds: TimeInterval = Constants.SixHoursInSeconds
    private var centerCell: SpotCardCollectionViewCell? {
        willSet {
            self.centerCell?.buyButton.isEnabled = false
            self.centerCell?.buyButton.backgroundColor = .shp_spotHeroBlue()
        }
        didSet {
            self.centerCell?.buyButton.isEnabled = true
            self.centerCell?.buyButton.backgroundColor = .shp_green()
        }
    }
    fileprivate let checkoutSegueIdentifier = "showCheckout"
    fileprivate var selectedFacility: Facility?
    fileprivate var maxTableHeight: CGFloat = 0
    fileprivate var currentIndex: Int = 0
    private var initialLoading = false {
        didSet {
            if self.initialLoading {
                ProgressHUD.showHUDAddedTo(self.view, withText: LocalizedStrings.Loading)
            } else {
                ProgressHUD.hideHUDForView(self.view)
            }
        }
    }
    fileprivate var facilities = [Facility]()
    private let redoSearchButtonBottomConstraintConstant: CGFloat = 15
    fileprivate var hasMorePages = false
    
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
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        NotificationCenter
            .default
            .addObserver(self,
                         selector: #selector(applicationWillEnterForeground(_:)),
                         name: .UIApplicationWillEnterForeground,
                         object: nil)
        
        self.updateStartAndEndDatesVsCurrentTimeIfNeeded()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        NotificationCenter
            .default
            .removeObserver(self)
    }
    
    private func setupViews() {
        self.reservationContainerView.layer.cornerRadius = HeightsAndLengths.standardCornerRadius
        self.reservationContainerView.layer.masksToBounds = true
        
        self.searchSpotsButton.isHidden = true
        self.searchSpotsButton.layer.cornerRadius = HeightsAndLengths.standardCornerRadius
        self.searchSpotsButton.backgroundColor = .shp_spotHeroBlue()
        
        self.redoSearchButton.layer.cornerRadius = HeightsAndLengths.redoSearchButtonCornerRadius
        self.redoSearchButton.setTitleColor(.shp_spotHeroBlue(), for: .normal)
        self.redoSearchButton.setTitleColor(.gray, for: .disabled)
        self.redoSearchButton.isHidden = true
        
        self.predictionController.delegate = self
        
        self.spotCardCollectionView.isHidden = true
        
        self.predictionTableView.dataSource = self.predictionController
        self.predictionTableView.delegate = self.predictionController
        self.searchBar.delegate = self.predictionController
        
        let bundle = Bundle.shp_resourceBundle()
        
        self.predictionTableView.register(UINib(nibName: String(describing: GooglePredictionTableHeader.self), bundle: bundle),
                                          forHeaderFooterViewReuseIdentifier: GooglePredictionTableHeader.reuseIdentifier)
        self.predictionTableView.register(UINib(nibName: String(describing: GooglePredictionTableFooter.self), bundle: bundle),
                                          forHeaderFooterViewReuseIdentifier: GooglePredictionTableFooter.reuseIdentifier)
        
        self.searchBar.accessibilityLabel = AccessibilityStrings.SearchBar
        self.predictionTableView.accessibilityLabel = AccessibilityStrings.PredictionTableView
        self.timeSelectionView.accessibilityLabel = AccessibilityStrings.TimeSelectionView
        self.closeButton.accessibilityLabel = LocalizedStrings.Close
        self.spotCardCollectionView.accessibilityLabel = AccessibilityStrings.SpotCards
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vc = segue.destination as? CheckoutTableViewController {
            vc.facility = self.selectedFacility
            vc.rate = self.selectedFacility?.availableRates.first
        }
    }
    
    fileprivate func hideSearchSpots() {
        self.searchSpotsButton.isHidden = (self.searchBar.text ?? "").isEmpty
    }
    
    //MARK: Application lifecycle
    
    @objc private func applicationWillEnterForeground(_ notification: Notification) {
        self.updateStartAndEndDatesVsCurrentTimeIfNeeded()
    }
    
    private func updateStartAndEndDatesVsCurrentTimeIfNeeded() {
        self.timeSelectionView.startDatePicker.minimumDate = Date().shp_roundDateToNearestHalfHour(roundDown: true)
        
        // Make sure when coming back from the background that the start date is not before
        // the minimum start date.
        if let minimumDate = self.timeSelectionView.startDatePicker.minimumDate,
            self.startDate.shp_isBeforeDate(minimumDate) {
                let updatedStartDate = minimumDate // already rounded.
                self.timeSelectionView.startDate = updatedStartDate
                self.didChangeStartEndDate(startDate: updatedStartDate, endDate: self.endDate)
                
                // Now, make sure the end date is not before the updated start date
                if self.endDate.shp_isAfterDate(self.startDate) {
                    let updatedEndDate = self.startDate
                        .addingTimeInterval(Constants.SixHoursInSeconds) //Start date is already rounded.
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
    
    fileprivate func setCenterCell() {
        let itemIndex = IndexPath(item: self.currentIndex, section: 0)
        self.centerCell = self.spotCardCollectionView.cellForItem(at: itemIndex) as? SpotCardCollectionViewCell
    }
    
    /**
     Adds annotations to the map
     
     - parameter panning: Pass true to cause the map not to zoom in on the facilities. Optional (Defaults to false)
     */
    private func addAndShowFacilityAnnotations(_ facilities: [Facility], firstSearch: Bool) {
        // Only add facilities not already in the list
        let facilitiesToAdd = facilities.filter { return !self.facilities.contains($0) }
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
            guard let index = self.facilities.index(of: facility) else {
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
        
        if let predictionPlaceDetails = predictionPlaceDetails,
            firstSearch {
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
            let delta = 1.0 / UnitsOfMeasurement.approximateMilesPerDegreeOfLatitude.rawValue
            latitudeDelta = delta
            longitudeDelta = delta
        }
        
        let region = MKCoordinateRegion(center: placeDetails.location.coordinate,
                                        span: MKCoordinateSpan(latitudeDelta: latitudeDelta,
                                                               longitudeDelta: longitudeDelta))
        
        self.mapView.setRegion(region, animated: true)
    }
    
    private func showSpotCardCollectionView() {
        self.spotCardCollectionView.isHidden = false
        self.redoSearchButtonBottomConstraint.constant = self.spotCardCollectionView.frame.height + self.redoSearchButtonBottomConstraintConstant
        self.spotCardCollectionView.reloadData()
    }
    
    fileprivate func scrollToSpotCardThenSelectAnnotation(withIndexPath indexPath: IndexPath) {
        self.scrollToSpotCard(withIndexPath: indexPath, tap: false)
        let annotation = self.mapView.annotations
            .flatMap { $0 as? FacilityAnnotation } // take out the nulls
            .first(where: { $0.index == indexPath.row }) //grab the first annotation
        
        if let annotation = annotation {
            self.mapView.selectAnnotation(annotation, animated: true)
        }
    }
    
    fileprivate func scrollToSpotCard(withIndexPath indexPath: IndexPath, tap: Bool) {
        self.currentIndex = indexPath.row
        self.spotCardCollectionView.scrollToItem(at: indexPath,
                                                 at: [],
                                                 animated: true)
        self.trackViewPin(tap)
    }
    
    fileprivate func visibleMapViewRadiusInMeters() -> Double {
        // Convert the difference between max and min latitude to miles for the diameter
        let diameter = self.mapView.region.span.latitudeDelta
            * UnitsOfMeasurement.approximateMilesPerDegreeOfLatitude.rawValue
            * UnitsOfMeasurement.metersPerMile.rawValue
        return diameter / 2
    }
    
    //MARK: Google Autocomplete Helpers
    
    private func getPlaceDetails(_ prediction: GooglePlacesPrediction, completion: @escaping (GooglePlaceDetails?) -> Void) {
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
    private func fetchFacilities(_ coordinate: CLLocationCoordinate2D, redo: Bool = false) {
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
                                        facilities, _, hasMorePages in
                                        let firstSearch = (self?.initialLoading == true)
                                        self?.initialLoading = false
                                        self?.hasMorePages = hasMorePages
                                        
                                        //If there are more pages, show the wee loading view.
                                        self?.loadingView.isHidden = !hasMorePages
                                        
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
    
    fileprivate func searchSpots() {
        self.searchSpotsButton.isHidden = true
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
    
    @IBAction private func closeButtonPressed(_ sender: AnyObject) {
        SpotHeroPartnerSDK.shared.reportSDKClosed()
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction private func collapsedSearchBarTapped(_ sender: AnyObject) {
        self.collapsedSearchBar.hide()
        self.timeSelectionView.showTimeSelectionView(true)
        self.searchSpotsButton.isHidden = false
    }
    
    @IBAction private func searchSpotsButtonPressed(_ sender: AnyObject) {
        self.searchSpots()
    }
    
    @objc private func didDragMap(_ gestureRecognizer: UIGestureRecognizer) {
        switch gestureRecognizer.state {
        case .began:
            self.spotCardCollectionView.isHidden = true
            self.redoSearchButton.isHidden = true
            self.searchBar.resignFirstResponder()
        case .ended:
            self.redoSearchButton.isHidden = false
            if self.spotCardCollectionView.numberOfItems(inSection: 0) > 0 {
                self.showSpotCardCollectionView()
            } else {
                self.redoSearchButtonBottomConstraint.constant = self.redoSearchButtonBottomConstraintConstant
            }
        default:
            break
        }
    }
    
    @IBAction private func didTapMapView(_ sender: AnyObject) {
        if facilities.isEmpty {
            self.view.endEditing(true)
            self.timeSelectionView.deselect()
        } else {
            self.showCollapsedSearchBar()
            self.searchSpotsButton.isHidden = true
        }
    }
    
    @IBAction private func redoSearchButtonPressed(_ sender: AnyObject) {
        self.redoSearchButton.isHidden = true
        self.clearExistingFacilities()
        self.predictionPlaceDetails = nil
        self.searchSpotsButton.isHidden = true
        self.showCollapsedSearchBar()
        self.fetchFacilities(self.mapView.centerCoordinate, redo: true)
    }
    
    //MARK: Helpers
    
    private func showCollapsedSearchBar() {
        self.collapsedSearchBar.show()
        self.timeSelectionView.showTimeSelectionView(false)
        self.collapsedSearchBar.time = Calendar.current.dateComponents([.hour, .day, .minute],
                                                                       from: self.startDate,
                                                                       to: self.endDate)
    }
    
    private func fetchFacilitiesIfPlaceDetailsExists() {
        if let placeDetails = self.predictionPlaceDetails {
            self.fetchFacilities(placeDetails.location.coordinate)
        }
    }
    
    private func trackViewPin(_ tap: Bool = true) {
        let facility = self.facilities[self.currentIndex]
        
        MixpanelWrapper.track(.TappedSpotPin, properties: [
            .TappedPin: true,
            .ViewingMethod: tap ? "tap" : "swipe",
            .SpotAddress: facility.streetAddress,
            .Distance: facility.distanceInMeters,
            .SpotID: facility.parkingSpotID,
            ])
    }
    
    private func trackUserSearch(_ redo: Bool = false, type: String) {
        let facility = self.facilities[self.currentIndex]
        
        if let prediction = self.prediction {
            MixpanelWrapper.track(.UserSearched, properties: [
                .SearchQuery: prediction.predictionDescription,
                .TappedRedoSearch: redo,
                .OptimalZoom: self.defaultSearchRadius,
                .ResultsWithinOptimalZoom: self.facilities.count,
                .SpotHeroCity: facility.city,
                .SearchType: type,
                .ReservationLength: Calendar.current.dateComponents([.hour], from: self.startDate, to: self.endDate).hour ?? 0,
                .TimeFromReservationStart: facility.availableRates.first?.minutesToReservation() ?? 0,
                ])
        }
    }
}

//MARK: PredictionControllerDelegateHoursBetweenDates

extension MapViewController: PredictionControllerDelegate {
    func didUpdatePredictions(_ predictions: [GooglePlacesPrediction]) {
        self.predictionTableView.reloadData()
        self.view.layoutIfNeeded()
        UIView.animate(withDuration: Constants.ViewAnimationDuration,
                       animations: {
                        let headerFooterHeight: CGFloat = 28
                        let rowHeight: CGFloat = 60
                        
                        if !predictions.isEmpty {
                            self.searchSpotsButton.isHidden = true
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
    
    func didSelectPrediction(_ prediction: GooglePlacesPrediction) {
        self.prediction = prediction
        self.redoSearchButton.isHidden = true
        self.searchBar.text = prediction.predictionDescription
        self.timeSelectionView.showTimeSelectionView(true)
        self.hideSearchSpots()
        self.searchBar.resignFirstResponder()
        self.timeSelectionView.startViewSelected = true
    }
    
    func didTapXButton() {
        self.timeSelectionView.showTimeSelectionView(true)
        self.searchSpotsButton.isHidden = true
    }
    
    func didTapSearchButton() {
        guard !self.predictionController.predictions.isEmpty else {
            return
        }
        
        let indexPath = IndexPath(row: 0, section: 0)
        self.predictionController.tableView(self.predictionTableView, didSelectRowAt: indexPath)
        self.searchSpots()
    }
    
    func shouldSelectFirstPrediction() {
        guard !self.predictionController.predictions.isEmpty else {
            return
        }
        
        let indexPath = IndexPath(row: 0, section: 0)
        self.predictionTableView.selectRow(at: indexPath, animated: true, scrollPosition: .none)
    }
    
    func didBeginEditingSearchBar() {
        self.timeSelectionView.deselect()
    }
}

//MARK: ShowTimeSelectionViewDelegate

extension MapViewController: ShowTimeSelectionViewDelegate {
    func timeSelectionViewShouldShow(_ show: Bool) {
        UIView.animate(withDuration: Constants.ViewAnimationDuration, animations: {
            self.reservationContainerViewHeightConstraint.constant = show ? self.reservationContainerViewHeight : self.searchBarHeight
            self.view.layoutIfNeeded()
        })
    }
    
    func didPressEndDoneButton() {
        guard let text = searchBar.text, !text.isEmpty else {
            return
        }
        
        self.searchSpots()
    }
}

//MARK: StartEndDateDelegate

extension MapViewController: StartEndDateDelegate {
    func didChangeStartEndDate(startDate: Date, endDate: Date) {
        self.startDate = startDate
        self.endDate = endDate
        self.startEndDateDifferenceInSeconds = endDate.timeIntervalSince(startDate)
    }
    
    func didSelectStartEndView() {
        self.searchBar.resignFirstResponder()
    }
}

//MARK: MKMapViewDelegate

extension MapViewController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if annotation is MKPointAnnotation {
            return self.locationAnnotationView(annotation)
        }
        
        guard let view = mapView.dequeueReusableAnnotationView(withIdentifier: FacilityAnnotationView.Identifier) as? FacilityAnnotationView else {
            return FacilityAnnotationView(annotation: annotation, reuseIdentifier: FacilityAnnotationView.Identifier)
        }
        
        if let facilityAnnotation = annotation as? FacilityAnnotation {
            view.annotation = facilityAnnotation
        }
        return view
    }
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        guard let facilityAnnotation = view.annotation as? FacilityAnnotation else {
            return
        }
        
        let itemIndex = IndexPath(item: facilityAnnotation.index, section: 0)
        self.scrollToSpotCard(withIndexPath: itemIndex, tap: true)
    }
    
    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        if self.hasMorePages {
            self.redoSearchButton.isEnabled = false
        } else if self.visibleMapViewRadiusInMeters() > Constants.MaxSearchRadiusInMeters {
            self.redoSearchButton.isEnabled = false
        } else {
            self.redoSearchButton.isEnabled = true
        }
    }
    
    private func locationAnnotationView(_ annotation: MKAnnotation) -> MKAnnotationView {
        let annotationView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: "LocationAnnotation")
        annotationView.canShowCallout = self.facilities.isEmpty
        annotationView.isEnabled = self.facilities.isEmpty
        annotationView.pinTintColor = self.facilities.isEmpty ? .red : .green
        return annotationView
    }
}

//MARK: UICollectionViewDataSource

extension MapViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.facilities.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: SpotCardCollectionViewCell.Identifier,
                                                            for: indexPath) as? SpotCardCollectionViewCell else {
            return UICollectionViewCell()
        }
        
        let facility = self.facilities[indexPath.row]
        cell.buyButton.setTitle(LocalizedStrings.BookIt + " | $\(facility.displayPrice())", for: .normal)
        cell.streetAddressLabel.text = facility.streetAddress
        let distanceInMiles = UnitsOfMeasurement.distanceInMiles(Double(facility.distanceInMeters))
        //TODO: localize miles
        cell.spotInfoLabel.text = String(format: "\(LocalizedStrings.Distance): %.2f mi", distanceInMiles)
        
        if let rate = facility.availableRates.first {
            if rate.isWheelchairAccessible() {
                cell.accessibleParkingImageView.isHidden = false
            } else {
                cell.accessibleParkingImageView.isHidden = true
            }
            
            cell.accessibleParkingImageViewWidthConstraint.constant = rate.isWheelchairAccessible() ? 30 : 0
            
            cell.noReentryImageView.isHidden = rate.allowsReentry()
        }
        
        self.setCenterCell()
        
        cell.delegate = self
        return cell
    }
}

//MARK: UICollectionViewDelegate

extension MapViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        self.setCenterCell()
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if self.currentIndex != indexPath.row {
            self.scrollToSpotCardThenSelectAnnotation(withIndexPath: indexPath)
        }
    }
}

//MARK: UIScrollViewDelegate

extension MapViewController: UIScrollViewDelegate {
    func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        self.setCenterCell()
    }
}

//MARK: SpotCardCollectionViewDelegate

extension MapViewController: SpotCardCollectionViewDelegate {
    func didTapDoneButton(_ button: UIButton) {
        guard
            let cell = button.superview?.superview as? SpotCardCollectionViewCell,
            let indexPath = self.spotCardCollectionView.indexPath(for: cell) else {
                assertionFailure("cannot find spot card cell")
                return
        }
        self.selectedFacility = self.facilities[indexPath.row]
        self.performSegue(withIdentifier: self.checkoutSegueIdentifier, sender: nil)
    }
}

// MARK: - KeyboardNotification

extension MapViewController: KeyboardNotification {
    func registerForKeyboardNotifications() {
        NotificationCenter
            .default
            .addObserver(forName: .UIKeyboardWillShow,
                         object: nil,
                         queue: nil) {
                            [weak self]
                            notification in
                            guard
                                let userInfo = notification.userInfo,
                                let frame = userInfo[UIKeyboardFrameEndUserInfoKey] as? CGRect,
                                let viewHeight = self?.view.frame.height,
                                let searchBarHeight = self?.searchBarHeight else {
                                    return
                            }
                            
                            let totalPadding: CGFloat = 40
                            self?.maxTableHeight = viewHeight - frame.height - totalPadding - searchBarHeight
        }
        
        NotificationCenter
            .default
            .addObserver(forName: .UIKeyboardWillHide,
                         object: nil,
                         queue: nil) {
                            [weak self]
                            _ in
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
    func didSwipeCollectionView(_ direction: UISwipeGestureRecognizerDirection) {
        switch direction {
        case UISwipeGestureRecognizerDirection.left:
            if self.currentIndex + 1 < self.facilities.count {
                self.currentIndex += 1
            } else {
                return
            }
        case UISwipeGestureRecognizerDirection.right:
            if self.currentIndex > 0 {
                self.currentIndex -= 1
            } else {
                return
            }
        default:
            return
        }
        
        let itemIndex = IndexPath(item: self.currentIndex, section: 0)
        self.scrollToSpotCardThenSelectAnnotation(withIndexPath: itemIndex)
    }
}

// MARK: - UIGestureRecognizerDelegate

extension MapViewController: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer,
                           shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}
