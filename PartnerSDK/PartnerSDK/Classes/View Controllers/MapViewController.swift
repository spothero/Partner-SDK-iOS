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
    
    @IBOutlet private var mapView: MKMapView!
    @IBOutlet private var spotCardCollectionView: UICollectionView!
    @IBOutlet private var loadingView: UIView!

    let titleLabel = UILabel()
    let subtitleLabel = UILabel()
    let titleView = UIStackView()
    
    var googlePlaceDetails: GooglePlaceDetails?
    var city: City?
    
    private var debouncedTask: DebouncedTask?
    
    private var defaultRegionRadius: Double = UnitsOfMeasurement.metersPerMile.rawValue
    private var maxSearchRadius: Double {
        guard self.googlePlaceDetails?.isAirport() != true else {
            // have a wider search radius around airports.
            return self.defaultRegionRadius * 5
        }
        return self.defaultRegionRadius
    }
    var startDate: Date?
    var endDate: Date?
    private let searchBarHeight: CGFloat = 44
    private var startEndDateDifferenceInSeconds: TimeInterval = Constants.SixHoursInSeconds
    private let checkoutSegueIdentifier = "showCheckout"
    private var selectedFacility: Facility?
    private var maxTableHeight: CGFloat = 0
    private var isLoading = false {
        didSet {
            if self.isLoading {
                ProgressHUD.showHUDAddedTo(self.view, withText: LocalizedStrings.Loading)
            } else {
                ProgressHUD.hideHUDForView(self.view)
            }
        }
    }
    private var facilities = [Facility]()
    private lazy var searchCoordinator = SearchCoordinator(delegate: self)
    
    private var searchLocation = CLLocation(latitude: 0, longitude: 0)
    
    private let searchLocationAnnotation = MKPointAnnotation()
    private var selectedFacilityAnnotation: FacilityAnnotation? {
        didSet {
            if
                let annotation = oldValue,
                let oldAnnotationView = self.mapView.view(for: annotation) {
                    oldAnnotationView.isSelected = false
            }
            if
                let annotation = self.selectedFacilityAnnotation,
                let newAnnotationView = self.mapView.view(for: annotation) {
                    newAnnotationView.isSelected = true
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let initialCenterCoordinate = self.getInitialCenterCoordinate()
        self.showDefaultRegionAround(initialCenterCoordinate)
        self.searchCoordinator.fetchIdealSearchDistance(for: initialCenterCoordinate)

        self.addAnnotationForInitialSearchLocation()
        self.setupViews()
        
        // TODO: Confirm ths is tracking the right thing
        MixpanelWrapper.track(.viewedSearchResultsScreen)

        guard let layout = self.spotCardCollectionView.collectionViewLayout as? SpotCardCollectionViewFlowLayout else {
            return
        }
        
        layout.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        NotificationCenter
            .default
            .addObserver(self,
                         selector: #selector(applicationWillEnterForeground(_:)),
                         name: UIApplication.willEnterForegroundNotification,
                         object: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.interactivePopGestureRecognizer?.isEnabled = true

        NotificationCenter
            .default
            .removeObserver(self)
    }
    
    @objc
    private func applicationWillEnterForeground(_ notification: Notification) {
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
            self.clearExistingFacilities()
            self.fetchFacilitiesIfPlaceDetailsExists()
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.navigationController?.interactivePopGestureRecognizer?.isEnabled = false
    }

    private func setupViews() {
        self.spotCardCollectionView.accessibilityLabel = AccessibilityStrings.SpotCards
        self.mapView.accessibilityLabel = AccessibilityStrings.MapView
        
        self.titleView.addArrangedSubview(self.titleLabel)
        self.titleView.addArrangedSubview(self.subtitleLabel)
        self.titleView.axis = .vertical
        self.titleLabel.text = self.googlePlaceDetails?.formattedAddress

        self.titleLabel.font = .shp_subheadTwo
        self.subtitleLabel.font = .shp_body
        
        if let color = self.navigationController?.navigationBar.titleTextAttributes?[.foregroundColor] as? UIColor {
            self.titleLabel.textColor = color
            self.subtitleLabel.textColor = color
        }
        
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(customView: self.titleView)
        self.navigationItem.leftItemsSupplementBackButton = true
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let viewController = segue.destination as? CheckoutViewController {
            viewController.facility = self.selectedFacility
            viewController.rate = self.selectedFacility?.availableRates.first
        }
    }
    
    // MARK: MapView & Spot Cards Helpers
    
    private func getInitialCenterCoordinate() -> CLLocationCoordinate2D {
        let center: CLLocationCoordinate2D
        if let googleDetailsLocation = self.googlePlaceDetails?.location {
            center = googleDetailsLocation.coordinate
        } else if let city = self.city {
            center = city.location.coordinate
        } else {
            center = Constants.ChicagoLocation.coordinate
        }
        return center
    }
    
    /**
     Adds annotations to the map
     
     - parameter panning: Pass true to cause the map not to zoom in on the facilities. Optional (Defaults to false)
     */
    private func addFacilities(_ facilities: [Facility]) {
        
        var existingAnnotationsByID = [Int: FacilityAnnotation]()
        for case let facilityAnnotation as FacilityAnnotation in self.mapView.annotations {
            let facilityID = facilityAnnotation.facility.parkingSpotID
            existingAnnotationsByID[facilityID] = facilityAnnotation
        }
        
        let facilitiesToAdd = facilities.filter { facility in
            // if there is already an existing annotation for this facility
            if let existingAnnotation = existingAnnotationsByID[facility.parkingSpotID] {
                // update the annotation
                existingAnnotation.update(with: facility)
                
                // update the annotation view
                if let facilityAnnotationView = self.mapView.view(for: existingAnnotation) as? FacilityAnnotationView {
                    facilityAnnotationView.annotation = existingAnnotation
                }
                // exclude it from the list of new facilities to add to the map
                return false
            }
            return true
        }
        
        self.facilities += facilitiesToAdd

        self.facilities.sort { $0.distanceInMeters < $1.distanceInMeters }
        self.addAnnotations(for: facilitiesToAdd)
        self.updateSpotCards()
    }

    private func addAnnotationForInitialSearchLocation() {
        if let placeDetails = self.googlePlaceDetails {
            self.searchLocationAnnotation.coordinate = placeDetails.location.coordinate
        } else {
            self.searchLocationAnnotation.coordinate = self.mapView.centerCoordinate
        }
        self.mapView.addAnnotation(self.searchLocationAnnotation)
    }
    
    private func addAnnotations(for facilities: [Facility]) {
        let facilityAnnotations = facilities.map(FacilityAnnotation.init)
        self.mapView.addAnnotations(facilityAnnotations)
        self.updateSearchLocationAnnotation()
    }
    
    private func updateSpotCards() {
        self.spotCardCollectionView.reloadData()
        self.spotCardCollectionView.isHidden = self.facilities.isEmpty
    }
    
    /**
     Shows the annotations with the searched location in the center of the map
     */
    private func showAnnotations() {
        guard let placeDetails = self.googlePlaceDetails else {
            return
        }
        self.showDefaultRegionAround(placeDetails.location.coordinate)
    }
    
    private func showDefaultRegionAround(_ center: CLLocationCoordinate2D, animated: Bool = true) {
        let region = MKCoordinateRegion(center: center,
                                        latitudinalMeters: self.defaultRegionRadius,
                                        longitudinalMeters: self.defaultRegionRadius)
        self.mapView.setRegion(region, animated: animated)
    }
    
    private func selectAnnotation(at index: Int) {
        guard self.facilities.indices.contains(index) else {
            return
        }
        let facility = self.facilities[index]
        let annotation = self.mapView.annotations
            .compactMap { $0 as? FacilityAnnotation }
            .first { $0.facility == facility }
        
        if let annotation = annotation {
            self.mapView.selectAnnotation(annotation, animated: true)
        }
    }
    
    private func scrollToSpotCard(for facility: Facility) {
        if let index = self.facilities.firstIndex(where: { $0.parkingSpotID == facility.parkingSpotID }) {
            self.spotCardCollectionView.scrollToItem(at: IndexPath(item: index, section: 0),
                                                     at: .centeredHorizontally,
                                                     animated: true)
        }
    }
    
    private func visibleMapViewRadiusInMeters() -> Double {
        let centerPoint = MKMapPoint(self.mapView.centerCoordinate)
        let topCenterEdgePoint = MKMapPoint(x: self.mapView.visibleMapRect.midX, y: self.mapView.visibleMapRect.minY)
        // get the distance in meters from the center of the visible map to the top edge of the visible map
        return centerPoint.distance(to: topCenterEdgePoint)
    }
    
    // MARK: Google Autocomplete Helpers
    
    private func getPlaceDetails(_ location: CLLocationCoordinate2D, completion: @escaping (GooglePlaceDetails?) -> Void) {
        self.isLoading = true
        GooglePlacesWrapper.reverseGeocode(coordinate: self.mapView.centerCoordinate) { [weak self] placeDetailsArray, _ in
            if let placeDetails = placeDetailsArray.first {
                completion(placeDetails)
                //updating initialLoading handled in fetchFacilities()
            } else {
                self?.isLoading = false
                completion(nil)
            }
        }
    }

    private func searchCenterOfMapView() {
        self.getPlaceDetails(mapView.centerCoordinate) { placeDetails in
            if let placeDetails = placeDetails {
                self.setPlaceDetails(placeDetails: placeDetails, isRedoneSearch: true)
            }
        }
    }
    
    private func setPlaceDetails(placeDetails: GooglePlaceDetails, isRedoneSearch: Bool = false) {
        self.googlePlaceDetails = placeDetails
        self.fetchFacilitiesIfPlaceDetailsExists(isRedoneSearch: isRedoneSearch)
    }
    
    // MARK: Facility Helpers
    
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
        
        self.searchLocation.shp_timeZone { timeZone in
            let formatter = SHPDateFormatter.DateWithTime
            formatter.timeZone = timeZone
            
            self.subtitleLabel.text = "\(formatter.string(from: startDate)) - \(formatter.string(from: endDate))"
        }
        
        let maxSearchRadius = min(self.visibleMapViewRadiusInMeters(), self.maxSearchRadius)
        self.isLoading = true
        self.trackUserSearch(placeDetails: placeDetails,
                             searchRadius: maxSearchRadius,
                             type: "Search",
                             isRedoneSearch: isRedoneSearch)
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        self.searchCoordinator.fetchFacilities(coordinate: placeDetails.location.coordinate,
                                               starts: startDate,
                                               ends: endDate,
                                               visibleSearchRadius: self.visibleMapViewRadiusInMeters()) { [weak self] facilities, _ in
                                                UIApplication.shared.isNetworkActivityIndicatorVisible = false
                                                self?.isLoading = false
                                                self?.addFacilities(facilities)
        }
    }
    
    private func clearExistingFacilities() {
        self.facilities = []
        self.selectedFacilityAnnotation = nil
        self.spotCardCollectionView.reloadData()
        self.mapView.removeAnnotations(self.mapView.annotations)
    }
    
    // MARK: Helpers
    
    private func fetchFacilitiesIfPlaceDetailsExists(isRedoneSearch: Bool = false) {
        if let placeDetails = self.googlePlaceDetails {
            self.searchLocation = placeDetails.location
            self.fetchFacilities(placeDetails: placeDetails, isRedoneSearch: isRedoneSearch)
        }
    }

    private func trackUserSearch(placeDetails: GooglePlaceDetails,
                                 searchRadius: Double,
                                 type: String,
                                 isRedoneSearch: Bool = false) {
        guard
            let startDate = self.startDate,
            let endDate = self.endDate else {
                return
        }
        
        MixpanelWrapper.track(.userSearched, properties: [
            .searchQuery: placeDetails.formattedAddress,
            // TODO: confirm if we can delete this
            .tappedRedoSearch: isRedoneSearch,
            // TODO: confirm this is tracking the right thing
            .optimalZoom: searchRadius,
            .searchType: type,
            .reservationLength: Calendar.current.dateComponents([.hour], from: startDate, to: endDate).hour ?? 0,
        ])
    }
    
    override func willShowKeyboard(notification: Notification) {
        guard
            let userInfo = notification.userInfo,
            let frame = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect else {
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

// MARK: MKMapViewDelegate

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
        guard let annotation = view.annotation as? FacilityAnnotation else {
            return
        }
        
        self.selectedFacilityAnnotation = annotation
        self.scrollToSpotCard(for: annotation.facility)
        MixpanelWrapper.track(.tappedSpotPin)
    }
    
    private func locationAnnotationView(_ annotation: MKAnnotation) -> MKAnnotationView {
        let annotationView = DestinationAnnotationView(annotation: annotation,
                                                       reuseIdentifier: DestinationAnnotationView.Identifier,
                                                       type: .map)
        self.configureDestinationAnnotationView(annotationView)
        return annotationView
    }
    
    private func updateSearchLocationAnnotation() {
        guard let destinationAnnotationView = self.mapView.view(for: searchLocationAnnotation) as? DestinationAnnotationView else {
            return
        }
        self.configureDestinationAnnotationView(destinationAnnotationView)
        if self.facilities.isEmpty {
            self.mapView.selectAnnotation(self.searchLocationAnnotation, animated: true)
        } else {
            self.mapView.deselectAnnotation(self.searchLocationAnnotation, animated: false)
        }
    }
    
    private func configureDestinationAnnotationView(_ destinationAnnotationView: DestinationAnnotationView) {
        destinationAnnotationView.canShowCallout = self.facilities.isEmpty
        destinationAnnotationView.isEnabled = self.facilities.isEmpty
        destinationAnnotationView.text = self.facilities.isEmpty ? LocalizedStrings.NoSpotsNearby : ""
    }
    
    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        guard self.searchCoordinator.hasIdealSearchDistance else {
            // don't search on region changes if we haven't gotten the ideal search distance yet
            return
        }
        self.debouncedTask?.isCancelled = true
        
        let debouncedTask = DebouncedTask {
            self.debouncedTask = nil
            self.searchCenterOfMapView()
        }
        // Don't debounce the first search - this is the inital region change from setting the ideal search distance.
        let delay = self.searchCoordinator.hasStartedFirstSearch ? 0.3 : 0
        debouncedTask.schedule(withDelay: delay)
        self.debouncedTask = debouncedTask
    }
}

// MARK: UICollectionViewDataSource

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
        cell.configure(facility: facility)
        cell.delegate = self
        return cell
    }
}

// MARK: UICollectionViewDelegate

extension MapViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        self.selectAnnotation(at: indexPath.item)
    }
}

// MARK: SpotCardCollectionViewDelegate

extension MapViewController: SpotCardCollectionViewDelegate {
    func didTapViewDetailsButton(_ button: UIButton, cell: SpotCardCollectionViewCell) {
        guard let indexPath = self.spotCardCollectionView.indexPath(for: cell) else {
            return
        }
        
        let facility = self.facilities[indexPath.row]
        let viewController = SpotDetailsViewController.fromStoryboard()
        viewController.facility = facility
        viewController.searchLocation = self.searchLocation
        viewController.searchLocationName = self.googlePlaceDetails?.formattedAddress
        viewController.searchStartDate = self.startDate
        viewController.searchEndDate = self.endDate
        self.navigationController?.pushViewController(viewController, animated: true)
    }
    
    func didTapBuyButton(_ button: UIButton, cell: SpotCardCollectionViewCell) {
        guard let indexPath = self.spotCardCollectionView.indexPath(for: cell) else {
            return
        }
        // TODO: directly perform the segue so we dont have to store the facility in a variable
        self.selectedFacility = self.facilities[indexPath.row]
        self.performSegue(withIdentifier: self.checkoutSegueIdentifier, sender: nil)
    }
}

// MARK: SpotCardCollectionViewFlowLayoutDelegate

extension MapViewController: SpotCardCollectionViewFlowLayoutDelegate {
    func didSwipeCollectionView(_ direction: UISwipeGestureRecognizer.Direction, currentIndex: Int) {
        var newIndex = currentIndex
        switch direction {
        case .left where newIndex + 1 < self.facilities.count:
            newIndex += 1
        case .right where newIndex > 0:
            newIndex -= 1
        default:
            return
        }
        self.selectAnnotation(at: newIndex)
    }
}

// MARK: UIGestureRecognizerDelegate

extension MapViewController: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer,
                           shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}

// MARK: - IdealSearchDistanceDelegate

extension MapViewController: IdealSearchDistanceDelegate {
    func idealSearchDistanceUpdated(distance: Double, center: CLLocationCoordinate2D) {
        let aspectRatio = Double(self.mapView.bounds.width / self.mapView.bounds.height)
        // distance is a radius - convert this to a vertical diameter
        let verticalSpan = distance * 2
        // adjust the width to the aspect ratio of the mapView
        let horizontalSpan = verticalSpan * aspectRatio
        let region = MKCoordinateRegion(center: center,
                                        latitudinalMeters: verticalSpan,
                                        longitudinalMeters: horizontalSpan)
        self.mapView.setRegion(region, animated: true)
    }
}
