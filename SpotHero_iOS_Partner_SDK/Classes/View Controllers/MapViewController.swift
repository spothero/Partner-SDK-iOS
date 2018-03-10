//
//  MapViewController.swift
//  Pods
//
//  Created by Husein Kareem on 7/13/16.
//
//

import MapKit
import UIKit

class MapViewController: SpotHeroPartnerViewController {
    
    @IBOutlet weak fileprivate var mapView: MKMapView!
    @IBOutlet weak fileprivate var spotCardCollectionView: UICollectionView!
    @IBOutlet weak private var loadingView: UIView!
    @IBOutlet weak fileprivate var redoSearchButton: UIButton!
    @IBOutlet weak private var redoSearchButtonBottomConstraint: NSLayoutConstraint!
    let titleLabel = UILabel()
    let subtitleLabel = UILabel()
    let titleView = UIStackView()
    
    var prediction: GooglePlacesPrediction?
    var city: City?
    
    private var defaultSearchRadius: Double = UnitsOfMeasurement.metersPerMile.rawValue
    fileprivate var predictionPlaceDetails: GooglePlaceDetails?
    var startDate: Date?
    var endDate: Date?
    fileprivate let searchBarHeight: CGFloat = 44
    fileprivate let reservationContainerViewHeight: CGFloat = 134
    fileprivate var startEndDateDifferenceInSeconds: TimeInterval = Constants.SixHoursInSeconds
    private var centerCell: SpotCardCollectionViewCell?
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
    fileprivate var spotCardFacilities = [Facility]()
    private let redoSearchButtonBottomConstraintConstant: CGFloat = 15
    fileprivate var hasMorePages = false
    
    fileprivate var searchLocation = CLLocation(latitude: 0, longitude: 0)
    
    private var originalSearchCoordinate = CLLocation(latitude: 0, longitude: 0)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.search()
        self.setMapViewRegion()
        self.setupViews()
        
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
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        NotificationCenter
            .default
            .addObserver(self,
                         selector: #selector(applicationWillEnterForeground(_:)),
                         name: .UIApplicationWillEnterForeground,
                         object: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.interactivePopGestureRecognizer?.isEnabled = true

        NotificationCenter
            .default
            .removeObserver(self)
    }
    
    @objc private func applicationWillEnterForeground(_ notification: Notification) {
        self.updateDatesIfNeeded()
    }
    
    private func datesValid() -> Bool {
        return self.startDate?.shp_isWithinAHalfHourOfDate(Date()) == true
    }
    
    private func updateDatesIfNeeded() {
        if !self.datesValid() {
            guard
                let startDate = self.startDate,
                let endDate = self.endDate else {
                    assertionFailure("You should seriously have dates")
                    return
            }
        
            let duration = endDate.timeIntervalSince(startDate)
            self.startDate = Date().shp_roundDateToNearestHalfHour(roundDown: true)
            self.endDate = self.startDate?.addingTimeInterval(duration).shp_roundDateToNearestHalfHour(roundDown: false)
            self.fetchFacilitiesIfPlaceDetailsExists()
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.navigationController?.interactivePopGestureRecognizer?.isEnabled = false
    }
    private func search() {
        if let prediction = self.prediction {
            self.searchPrediction(prediction: prediction)
        } else if let city = self.city {
            self.searchCity(city: city)
        } else {
            assertionFailure("You need either a city or prediction")
        }
    }
    
    private func setupViews() {
        self.redoSearchButton.isHidden = true
        
        self.spotCardCollectionView.isHidden = true
        
        self.spotCardCollectionView.accessibilityLabel = AccessibilityStrings.SpotCards
        
        self.titleView.addArrangedSubview(self.titleLabel)
        self.titleView.addArrangedSubview(self.subtitleLabel)
        self.titleView.axis = .vertical
        
        self.titleLabel.font = .shp_subheadTwo
        self.subtitleLabel.font = .shp_body
        
        if let color = self.navigationController?.navigationBar.titleTextAttributes?[NSForegroundColorAttributeName] as? UIColor {
            self.titleLabel.textColor = color
            self.subtitleLabel.textColor = color
        }
        
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(customView: self.titleView)
        self.navigationItem.leftItemsSupplementBackButton = true
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vc = segue.destination as? CheckoutViewController {
            vc.facility = self.selectedFacility
            vc.rate = self.selectedFacility?.availableRates.first
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
        if let predictionPlaceDetails = predictionPlaceDetails, firstSearch {
            let coordinateRegion = MKCoordinateRegionMakeWithDistance(predictionPlaceDetails.location.coordinate,
                                                                      self.defaultSearchRadius,
                                                                      self.defaultSearchRadius)
            self.mapView.setRegion(coordinateRegion, animated: false)
        }
        
        // Show 2x more facilities than in the visible map region
        let origin = MKMapPoint(x: self.mapView.visibleMapRect.origin.x - self.mapView.visibleMapRect.size.width / 2,
                                y: self.mapView.visibleMapRect.origin.y - self.mapView.visibleMapRect.size.height / 2)
        let size = MKMapSize(width: self.mapView.visibleMapRect.size.width * 2,
                             height: self.mapView.visibleMapRect.size.height * 2)
        let rect = MKMapRect(origin: origin, size: size)
        let facilitiesToAdd = facilities.filter {
            facility in
            // Also only add facilities not already in the list
            return !self.facilities.contains(facility) && rect.shp_contains(coordinate: facility.location.coordinate)
        }

        self.facilities += facilitiesToAdd

        // Filter out facilities that require license plate
        self.facilities = self.facilities
            .filter { !$0.licensePlateRequired }
            .sorted { $0.distanceInMeters < $1.distanceInMeters }
        
        if firstSearch {
            for annotation in self.mapView.annotations where annotation is MKPointAnnotation {
                self.mapView.removeAnnotation(annotation)
            }
            
            let locationAnnotation = MKPointAnnotation()
            if let placeDetails = self.predictionPlaceDetails {
                locationAnnotation.coordinate = placeDetails.location.coordinate
            } else {
                locationAnnotation.coordinate = self.mapView.centerCoordinate
            }
            self.mapView.addAnnotation(locationAnnotation)
            
            if self.facilities.isEmpty {
                self.mapView.selectAnnotation(locationAnnotation, animated: true)
            }
        }

        for facility in facilitiesToAdd {
            let facilityAnnotation = FacilityAnnotation(title: facility.title,
                                                        coordinate: facility.location.coordinate,
                                                        facility: facility)
            
            self.mapView.addAnnotation(facilityAnnotation)
        }
        
        self.addSpotCards()
    }
    
    private func addSpotCards() {
        // Only add visible spots to spot cards
        self.spotCardFacilities = self.facilities.filter {
            facility in
            return self.mapView.visibleMapRect.shp_contains(coordinate: facility.location.coordinate)
        }
        self.spotCardCollectionView.reloadData()
        
        for case let annotation as FacilityAnnotation in self.mapView.annotations where annotation.facility == self.spotCardFacilities.first {
            self.mapView.selectAnnotation(annotation, animated: true)
        }
        self.spotCardCollectionView.isHidden = self.spotCardFacilities.isEmpty
        self.redoSearchButton.isHidden = !self.spotCardFacilities.isEmpty
    }
    
    /**
     Shows the annotations with the searched location in the center of the map
     */
    private func showAnnotations() {
        guard let placeDetails = self.predictionPlaceDetails else {
            return
        }
    
        let delta = self.defaultSearchRadius / UnitsOfMeasurement.approximateMilesPerDegreeOfLatitude.rawValue
        let latitudeDelta: CLLocationDegrees = delta
        let longitudeDelta: CLLocationDegrees = delta
        
        let region = MKCoordinateRegion(center: placeDetails.location.coordinate,
                                        span: MKCoordinateSpan(latitudeDelta: latitudeDelta,
                                                               longitudeDelta: longitudeDelta))
        
        self.mapView.setRegion(region, animated: true)
    }
    
    fileprivate func selectAnnotation(withIndexPath indexPath: IndexPath) {
        let facility = self.spotCardFacilities[indexPath.row]
        let annotation = self.mapView.annotations
            .flatMap { $0 as? FacilityAnnotation }
            .first { $0.facility == facility }
        
        if let annotation = annotation {
            self.mapView.selectAnnotation(annotation, animated: true)
        }
    }
    
    fileprivate func scrollToSpotCard(index: Int) {
        self.currentIndex = index
        
        let indexPath = IndexPath(item: index, section: 0)
        self.spotCardCollectionView.scrollToItem(at: indexPath,
                                                 at: [],
                                                 animated: true)
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
    
    private func getPlaceDetails(_ city: City, completion: @escaping (GooglePlaceDetails?) -> Void) {
        self.initialLoading = true
        GooglePlacesWrapper.getPlaceDetails(city) {
            [weak self]
            placeDetails, _ in
            if let placeDetails = placeDetails {
                completion(placeDetails)
                //updating initialLoading handled in fetchFacilities()
            } else {
                self?.initialLoading = false
                completion(nil)
            }
        }
    }
    
    private func getPlaceDetails(_ location: CLLocationCoordinate2D, completion: @escaping (GooglePlaceDetails?) -> Void) {
        self.initialLoading = true
        GooglePlacesWrapper.reverseGeocode(coordinate: self.mapView.centerCoordinate) {
            [weak self]
            placeDetailsArray, _ in
            if let placeDetails = placeDetailsArray.first {
                completion(placeDetails)
                //updating initialLoading handled in fetchFacilities()
            } else {
                self?.initialLoading = false
                completion(nil)
            }
        }
    }
    
    private func searchPrediction(prediction: GooglePlacesPrediction) {
        self.getPlaceDetails(prediction, completion: {
            placeDetails in
            if let placeDetails = placeDetails {
                self.setPlaceDetails(placeDetails: placeDetails)
            }
        })
    }
    
    private func searchCity(city: City) {
        self.getPlaceDetails(city, completion: {
            placeDetails in
            if let placeDetails = placeDetails {
                self.setPlaceDetails(placeDetails: placeDetails)
            }
        })
    }
    
    private func searchCoordinate() {
        self.getPlaceDetails(mapView.centerCoordinate) {
            placeDetails in
            if let placeDetails = placeDetails {
                self.setPlaceDetails(placeDetails: placeDetails, isRedoneSearch: true)
            }
        }
    }
    
    private func setPlaceDetails(placeDetails: GooglePlaceDetails, isRedoneSearch: Bool = false) {
        self.predictionPlaceDetails = placeDetails
        self.fetchFacilitiesIfPlaceDetailsExists(isRedoneSearch: isRedoneSearch)
    }
    
    //MARK: Facility Helpers
    
    /**
     Fetch the factilities around a given coordinate
     
     - parameter coordinate: coordinate to search around
     - parameter panning:    Whether or not this was triggered by the user panning the map.
     Passing true will cause there to be no loading spinner and no "No spots" error
     Optional (Defaults to false)
     */
    private func fetchFacilities(placeDetails: GooglePlaceDetails, isRedoneSearch: Bool = false) {
        guard
            let startDate = self.startDate,
            let endDate = self.endDate else {
                return
        }
        
        self.searchLocation.shp_timeZone {
            timeZone in
            let formatter = SHPDateFormatter.DateWithTime
            formatter.timeZone = timeZone
            
            self.subtitleLabel.text = "\(formatter.string(from: startDate)) - \(formatter.string(from: endDate))"
        }
        
        var maxSearchRadius = self.visibleMapViewRadiusInMeters()
        self.initialLoading = true
        maxSearchRadius = self.defaultSearchRadius
        self.centerCell = nil
        self.trackUserSearch(placeDetails: placeDetails, isRedoneSearch: isRedoneSearch, type: "Search")
        FacilityAPI.fetchFacilities(placeDetails.location.coordinate,
                                    starts: startDate,
                                    ends: endDate,
                                    maxSearchRadius: maxSearchRadius,
                                    completion: {
                                        [weak self]
                                        facilities, _, hasMorePages in
                                        let firstSearch = (self?.initialLoading == true)
                                        self?.initialLoading = false
                                        self?.hasMorePages = hasMorePages
                                        
                                        //If there are more pages, show the wee loading view.
                                        self?.loadingView.isHidden = !hasMorePages
                                        
                                        if firstSearch {
                                            MixpanelWrapper.track(.viewedSearchResultsScreen)
                                        }
                                        
                                        self?.addAndShowFacilityAnnotations(facilities, firstSearch: firstSearch)
        })
    }
    
    private func clearExistingFacilities() {
        self.facilities = []
        self.spotCardFacilities = []
        self.currentIndex = 0
        self.spotCardCollectionView.reloadData()
        self.mapView.removeAnnotations(self.mapView.annotations)
    }
    
    //MARK: Actions
    
    @objc private func didDragMap(_ gestureRecognizer: UIGestureRecognizer) {
        switch gestureRecognizer.state {
        case .ended:
            self.addSpotCards()
        default:
            break
        }
    }
    
    @IBAction private func redoSearchButtonPressed(_ sender: AnyObject) {
        self.updateDatesIfNeeded()
        self.redoSearchButton.isHidden = true
        self.predictionPlaceDetails = nil
        self.searchCoordinate()
    }
    
    //MARK: Helpers
    
    private func fetchFacilitiesIfPlaceDetailsExists(isRedoneSearch: Bool = false) {
        if let placeDetails = self.predictionPlaceDetails {
            self.searchLocation = placeDetails.location
            
            self.titleLabel.text = placeDetails.formattedAddress
            
            self.clearExistingFacilities()
            
            // Add some padding around default region to account for screen being a rectangle
            let padding = 1.5
            
            if placeDetails.isAirport() {
                //have a wider search radius around airports.
                self.defaultSearchRadius = UnitsOfMeasurement.metersPerMile.rawValue * 5 * padding
            } else {
                self.defaultSearchRadius = UnitsOfMeasurement.metersPerMile.rawValue / 5 * padding
            }
            
            self.originalSearchCoordinate = placeDetails.location
            self.fetchFacilities(placeDetails: placeDetails, isRedoneSearch: isRedoneSearch)
        }
    }

    private func trackUserSearch(placeDetails: GooglePlaceDetails, isRedoneSearch: Bool = false, type: String) {
        guard
            let startDate = self.startDate,
            let endDate = self.endDate else {
                return
        }
        
        MixpanelWrapper.track(.userSearched, properties: [
            .searchQuery: placeDetails.formattedAddress,
            .tappedRedoSearch: isRedoneSearch,
            .optimalZoom: self.defaultSearchRadius,
            .searchType: type,
            .reservationLength: Calendar.current.dateComponents([.hour], from: startDate, to: endDate).hour ?? 0,
            ])
    }
    
    override func willShowKeyboard(notification: Notification) {
        guard
            let userInfo = notification.userInfo,
            let frame = userInfo[UIKeyboardFrameEndUserInfoKey] as? CGRect else {
                return
        }
        
        let viewHeight = self.view.frame.height
        let totalPadding: CGFloat = 40
        self.maxTableHeight = viewHeight - frame.height - totalPadding - self.searchBarHeight
    }
    
    func willHideKeyboard() {
        let viewHeight = self.view.frame.height
        
        let totalPadding: CGFloat = 40
        self.maxTableHeight = viewHeight - totalPadding - self.searchBarHeight
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
        guard
            let annotation = view.annotation as? FacilityAnnotation,
            let facility = annotation.facility,
            let index = self.spotCardFacilities.index(of: facility) else {
                return
        }
        
        self.scrollToSpotCard(index: index)
        MixpanelWrapper.track(.tappedSpotPin)
    }
    
    private func locationAnnotationView(_ annotation: MKAnnotation) -> MKAnnotationView {
        let annotationView = DestinationAnnotationView(annotation: annotation, reuseIdentifier: DestinationAnnotationView.Identifier, type: .map)
        annotationView.canShowCallout = self.facilities.isEmpty
        annotationView.isEnabled = self.facilities.isEmpty
        annotationView.text = self.facilities.isEmpty ? LocalizedStrings.NoSpotsFound : ""
        return annotationView
    }
}

//MARK: UICollectionViewDataSource

extension MapViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.spotCardFacilities.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: SpotCardCollectionViewCell.Identifier,
                                                            for: indexPath) as? SpotCardCollectionViewCell else {
            return UICollectionViewCell()
        }
        
        let facility = self.spotCardFacilities[indexPath.row]
        cell.configure(facility: facility)
        
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
            self.selectAnnotation(withIndexPath: indexPath)
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
    func didTapViewDetailsButton(_ button: UIButton, cell: SpotCardCollectionViewCell) {
        guard let indexPath = self.spotCardCollectionView.indexPath(for: cell) else {
            return
        }
        
        let facility = self.spotCardFacilities[indexPath.row]
        let vc = SpotDetailsViewController.fromStoryboard()
        vc.facility = facility
        vc.searchLocation = self.searchLocation
        vc.searchLocationName = self.predictionPlaceDetails?.formattedAddress
        vc.searchStartDate = self.startDate
        vc.searchEndDate = self.endDate
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func didTapBuyButton(_ button: UIButton, cell: SpotCardCollectionViewCell) {
        guard let indexPath = self.spotCardCollectionView.indexPath(for: cell) else {
            return
        }
        
        self.selectedFacility = self.spotCardFacilities[indexPath.row]
        self.performSegue(withIdentifier: self.checkoutSegueIdentifier, sender: nil)
    }
}

//MARK: SpotCardCollectionViewFlowLayoutDelegate

extension MapViewController: SpotCardCollectionViewFlowLayoutDelegate {
    func didSwipeCollectionView(_ direction: UISwipeGestureRecognizerDirection) {
        switch direction {
        case UISwipeGestureRecognizerDirection.left:
            if self.currentIndex + 1 < self.spotCardFacilities.count {
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
        self.selectAnnotation(withIndexPath: itemIndex)
    }
}

// MARK: - UIGestureRecognizerDelegate

extension MapViewController: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer,
                           shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}
