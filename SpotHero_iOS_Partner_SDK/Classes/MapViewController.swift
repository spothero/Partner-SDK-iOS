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
    @IBOutlet weak private var spotCardCollectionView: UICollectionView!
    @IBOutlet weak private var closeButton: UIBarButtonItem!
    
    private var prediction: GooglePlacesPrediction?
    private let predictionController = PredictionController()
    private var predictionPlaceDetails: GooglePlaceDetails? {
        didSet {
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
    private var loading = false
    
    private var facilities = [Facility]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setMapViewRegion()
        self.setupViews()
        self.registerForKeyboardNotifications()
        
        self.datePickerView.delegate = self.timeSelectionView
        self.timeSelectionView.delegate = self.datePickerView
        self.timeSelectionView.showTimeSelectionViewDelegate = self
        self.datePickerView.doneButtonDelegate = self
        self.timeSelectionView.startEndDateDelegate = self
        
        guard let layout = self.spotCardCollectionView.collectionViewLayout as? SpotCardCollectionViewFlowLayout else {
            return
        }
        
        layout.delegate = self
        
        let mapDragRecognizer = UIPanGestureRecognizer(target: self, action: #selector(self.didDragMap(_:)))
        mapDragRecognizer.delegate = self
        self.mapView.addGestureRecognizer(mapDragRecognizer)
        searchBar.becomeFirstResponder()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        NSNotificationCenter
            .defaultCenter()
            .addObserver(self,
                         selector: #selector(applicationWillEnterForeground(_:)),
                         name: UIApplicationWillEnterForegroundNotification,
                         object: nil)
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
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let vc = segue.destinationViewController as? CheckoutTableViewController {
            vc.facility = self.selectedFacility
            vc.rate = self.selectedFacility?.availableRates.first
        }
    }
    
    private func showCollapsedSearchBar() {
        self.searchSpotsButton.hidden = (self.searchBar.text ?? "").isEmpty
    }
    
    //MARK: Application lifecycle
    
    @objc private func applicationWillEnterForeground(notification: NSNotification) {
        // Make sure when coming back from the background that the start date is not before
        // the booking interval.
        let enterForegroundDate = NSDate()
        if self.startDate.compare(enterForegroundDate) != .OrderedAscending {
            let updatedStartDate = enterForegroundDate.shp_roundDateToNearestHalfHour(roundDown: true)
            self.didChangeStartEndDate(startDate: updatedStartDate, endDate: self.endDate)
        }
        
        // Next, make sure the end date is not before the start date
        if self.startDate.compare(self.endDate) != .OrderedAscending {
            let updatedEndDate = self.startDate
                .dateByAddingTimeInterval(Constants.SixHoursInSeconds)
                .shp_roundDateToNearestHalfHour(roundDown: true)
            self.didChangeStartEndDate(startDate: updatedEndDate, endDate: self.endDate)
        }
        
        //Finally, update any existing search to ensure shown prices are accurate.
        self.fetchFacilitiesIfPlaceDetailsExists()
    }
    
    //MARK: MapView & Spot Cards Helpers
    
    private func setMapViewRegion() {
        let region = MKCoordinateRegion(center: Constants.ChicagoLocation.coordinate,
                                        span: MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1))
        self.mapView.setRegion(region, animated: true)
        self.mapView.accessibilityLabel = AccessibilityStrings.MapView
    }
    
    /**
     Adds annotations to the map
     
     - parameter panning: Pass true to cause the map not to zoom in on the facilities. Optional (Defaults to false)
     */
    private func addAndShowFacilityAnnotations(panning: Bool = false) {
        //TODO: Look into caching annotations like the main app
        self.mapView.removeAnnotations(self.mapView.annotations)
        if let placeDetails = self.predictionPlaceDetails {
            let locationAnnotation = MKPointAnnotation()
            locationAnnotation.coordinate = placeDetails.location.coordinate
            locationAnnotation.title = self.facilities.isEmpty ? LocalizedStrings.NoSpotsFound : ""
            self.mapView.addAnnotation(locationAnnotation)
        }
        
        var firstAnnotation: FacilityAnnotation?
        for (i, facility) in self.facilities.enumerate() {
            let facilityAnnotation = FacilityAnnotation(title: facility.title,
                                                        coordinate: facility.location.coordinate,
                                                        facility: facility,
                                                        index: i)
            if i == 0 && !panning {
                firstAnnotation = facilityAnnotation
            }
            self.mapView.addAnnotation(facilityAnnotation)
        }
        self.showSpotCardCollectionView()
        if !panning {
            self.showAnnotations()
            self.currentIndex = 0
            
            guard let annotation = firstAnnotation else {
                return
            }
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
        for annotation in self.mapView.annotations {
            let latitude = abs(placeDetails.location.coordinate.latitude - annotation.coordinate.latitude)
            let longitude = abs(placeDetails.location.coordinate.longitude - annotation.coordinate.longitude)
            
            latitudeDelta = max(latitudeDelta, latitude)
            longitudeDelta = max(longitudeDelta, longitude)
        }
        
        // Multiply the deltas by 2 plus some extra padding
        let multiplier = 2.2
        
        let region = MKCoordinateRegion(center: placeDetails.location.coordinate, span: MKCoordinateSpan(latitudeDelta: latitudeDelta * multiplier, longitudeDelta: longitudeDelta * multiplier))
        
        self.mapView.setRegion(region, animated: true)
    }
    
    private func showSpotCardCollectionView() {
        self.spotCardCollectionView.hidden = false
        self.spotCardCollectionView.reloadData()
    }
    
    private func scrollToSpotCardThenSelectAnnotation(withIndexPath indexPath: NSIndexPath) {
        self.scrollToSpotCard(withIndexPath: indexPath)
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
    
    private func scrollToSpotCard(withIndexPath indexPath: NSIndexPath) {
        self.currentIndex = indexPath.row
        self.centerCell = self.spotCardCollectionView.cellForItemAtIndexPath(indexPath) as? SpotCardCollectionViewCell
        self.spotCardCollectionView.scrollToItemAtIndexPath(indexPath,
                                                            atScrollPosition: .None,
                                                            animated: true)
    }
    
    //MARK: Google Autocomplete Helpers
    
    private func getPlaceDetails(prediction: GooglePlacesPrediction, completion: (GooglePlaceDetails?) -> ()) {
        self.startLoading()
        GooglePlacesWrapper.getPlaceDetails(prediction) {
            placeDetails, error in
            if let error = error {
                self.stopLoading()
                completion(nil)
            } else {
                completion(placeDetails)
                //stopLoading() handled in fetchFacilities()
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
    private func fetchFacilities(coordinate: CLLocationCoordinate2D, panning: Bool = false) {
        if !panning {
            self.startLoading()
        }

        FacilityAPI.fetchFacilities(coordinate,
                                    starts: self.startDate,
                                    ends: self.endDate,
                                    completion: {
                                        [weak self]
                                        facilities, error in
                                        self?.stopLoading()
                                        if facilities.isEmpty && !panning {
                                            AlertView.presentErrorAlertView(LocalizedStrings.Sorry, message: LocalizedStrings.NoSpotsFound, from: self)
                                        }
                                        
                                        self?.facilities = facilities
                                        self?.addAndShowFacilityAnnotations(panning)
            })
    }
    
    private func searchSpots() {
        self.searchSpotsButton.hidden = true
        self.collapsedSearchBar.show()
        self.timeSelectionView.showTimeSelectionView(false)
        let hoursBetweenDates = self.startEndDateDifferenceInSeconds / Constants.SecondsInHour
        self.collapsedSearchBar.text = String(format: LocalizedStrings.HoursBetweenDatesFormat, hoursBetweenDates)
        self.searchPrediction()
        self.searchBar.resignFirstResponder()
    }
    
    //MARK: Actions
    
    @IBAction private func closeButtonPressed(sender: AnyObject) {
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
            self.searchBar.resignFirstResponder()
        case .Ended:
            self.fetchFacilities(self.mapView.centerCoordinate, panning: true)
        default:
            break
        }
    }
    
    @IBAction private func didTapMapView(sender: AnyObject) {
        self.searchBar.resignFirstResponder()
        self.datePickerView.showDatePickerView(false)
        self.timeSelectionView.deselect()
    }
    
    //MARK: Helpers
    
    private func startLoading() {
        if !self.loading {
            self.loading = true
            ProgressHUD.showHUDAddedTo(self.view, withText: LocalizedStrings.Loading)
        }
    }
    
    private func stopLoading() {
        if self.loading {
            self.loading = false
            ProgressHUD.hideHUDForView(self.view)
        }
    }
    
    private func fetchFacilitiesIfPlaceDetailsExists() {
        if let placeDetails = self.predictionPlaceDetails {
            self.fetchFacilities(placeDetails.location.coordinate)
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
                                    
                                    if predictions.count > 0 {
                                        self.searchSpotsButton.hidden = true
                                        self.timeSelectionView.showTimeSelectionView(false)
                                        let dynamicHeight = self.searchBarHeight + CGFloat(predictions.count) * rowHeight + headerFooterHeight * 2
                                        let height = min(dynamicHeight, self.maxTableHeight)
                                        self.searchContainerViewHeightConstraint.constant = height
                                        self.reservationContainerViewHeightConstraint.constant = height
                                    } else {
                                        self.searchContainerViewHeightConstraint.constant = self.searchBarHeight
                                    }
                                    self.view.layoutIfNeeded()
            },
                                   completion: nil)
    }
    
    func didSelectPrediction(prediction: GooglePlacesPrediction) {
        self.prediction = prediction
        self.searchBar.text = prediction.description
        self.timeSelectionView.showTimeSelectionView(true)
        self.showCollapsedSearchBar()
        self.searchBar.resignFirstResponder()
        self.timeSelectionView.startViewSelected = true
        self.datePickerView.showDatePickerView(true)
    }
    
    func didTapXButton() {
        self.timeSelectionView.showTimeSelectionView(true)
        self.searchSpotsButton.hidden = true
    }
    
    func didTapSearchButton() {
        guard self.predictionController.predictions.count > 0 else {
            self.searchSpots()
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
        self.datePickerView.showDatePickerView(false)
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
}

//MARK: DatePickerDoneButtonDelegate

extension MapViewController: DatePickerDoneButtonDelegate {
    func didPressDoneButton() {
        if self.timeSelectionView.endViewSelected {
            self.datePickerView.timeSelectionViewShouldHide()
            guard let text = searchBar.text where !text.isEmpty else {
                return
            }
            
            self.searchSpots()
        } 
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
        if let placeDetails = self.predictionPlaceDetails {
            if annotation.coordinate.latitude == placeDetails.location.coordinate.latitude &&
                annotation.coordinate.longitude == placeDetails.location.coordinate.longitude {
                let annotationView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: "LocationAnnotation")
                annotationView.canShowCallout = self.facilities.isEmpty
                annotationView.enabled = self.facilities.isEmpty
                annotationView.pinTintColor = self.facilities.isEmpty ? .redColor() : .greenColor()
                return annotationView
            }
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
        self.scrollToSpotCard(withIndexPath: itemIndex)
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
        }
        
        cell.delegate = self
        return cell
    }
}

//MARK: UICollectionViewDelegate

extension MapViewController: UICollectionViewDelegate {
    func collectionView(collectionView: UICollectionView, willDisplayCell cell: UICollectionViewCell, forItemAtIndexPath indexPath: NSIndexPath) {
        let itemIndex = NSIndexPath(forItem: self.currentIndex, inSection: 0)
        self.centerCell = self.spotCardCollectionView.cellForItemAtIndexPath(itemIndex) as? SpotCardCollectionViewCell
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        if let cell = collectionView.cellForItemAtIndexPath(indexPath) where cell !== self.centerCell {
            self.scrollToSpotCardThenSelectAnnotation(withIndexPath: indexPath)
        }
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
