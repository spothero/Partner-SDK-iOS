//
//  SpotDetailsViewController.swift
//  SpotHero_iOS_Partner_SDK
//
//  Created by Matthew Reed on 12/25/17.
//

import MapKit
import UIKit

class SpotDetailsViewController: SpotHeroPartnerViewController {
    static let StoryboardIdentifier = String(describing: SpotDetailsViewController.self)
    
    @IBOutlet private var titleLabel: HeadlineLabel!
    @IBOutlet private var startTimeLabel: BodyLabel!
    @IBOutlet private var endTimeLabel: BodyLabel!
    @IBOutlet private var startDateTimeLabel: TitleLabel!
    @IBOutlet private var endDateTimeLabel: TitleLabel!
    @IBOutlet private var distanceLabel: TitleLabel!
    @IBOutlet private var walkingDistanceLabel: BodyLabel!
    @IBOutlet private var mapView: MKMapView!
    @IBOutlet fileprivate var imageCollectionView: UICollectionView!
    @IBOutlet private var hoursTitleLabel: TitleLabel!
    @IBOutlet private var hoursLabel: BodyLabel!
    @IBOutlet private var restrictionsTitleLabel: TitleLabel!
    @IBOutlet private var restrictionsLabel: BodyLabel!
    @IBOutlet private var moreButton: LinkButton!
    @IBOutlet private var aboutTitleLabel: TitleLabel!
    @IBOutlet private var aboutLabel: BodyLabel!
    @IBOutlet private var readMoreButton: LinkButton!
    @IBOutlet private var bookButton: PrimaryButton!
    @IBOutlet private var bookButtonContainer: UIView!
    @IBOutlet private var scrollView: UIScrollView!
    @IBOutlet private var hoursContainerView: UIView!
    @IBOutlet private var restrictionsContainerView: UIView!
    @IBOutlet private var aboutContainerView: UIView!
    @IBOutlet private var daysAndHoursView: UIView!
    @IBOutlet private var daysLabel: UILabel!
    @IBOutlet private var hoursPeriodLabel: UILabel!
    @IBOutlet private var hoursTypeLabel: UILabel!
    @IBOutlet private var separatorView: UIView!
    @IBOutlet fileprivate var topContentStackView: UIStackView!
    @IBOutlet fileprivate var topContentLeadingContraint: NSLayoutConstraint!
    @IBOutlet private var amenityContainerView: UIView!
    @IBOutlet private var separatorContainerView: UIView!
    @IBOutlet private var spacerView: UIView!
    @IBOutlet private var datesContainerView: UIStackView!
    @IBOutlet private var calloutStackView: UIStackView!
    @IBOutlet private var calloutContainerView: UIView!
    @IBOutlet private var walkingDistanceContainerView: UIView!
    
    private var restrictionsExpanded = false
    private var aboutExpanded = false
    
    fileprivate lazy var imageCellSize: CGSize = {
        return CGSize(width: self.topContentStackView.frame.width,
                      height: self.imageCollectionView.frame.height)
    }()
    
    var facility: Facility?
    var searchLocation: CLLocation?
    var searchLocationName: String?
    var searchStartDate: Date?
    var searchEndDate: Date?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setupViews()
        self.setupFacility()
        MixpanelWrapper.track(.viewedSpotDetails)
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
        if !self.datesValid() {
            AlertView.presentErrorAlertView(LocalizedStrings.Error,
                                            message: LocalizedStrings.RateExpired,
                                            from: self) {
                                                [weak self]
                                                _ in
                                                self?.navigationController?.popToRootViewController(animated: true)
                                            }
        }
    }
    
    private func datesValid() -> Bool {
        guard let rate = self.facility?.availableRates.first else {
            return false
        }
        return rate.starts.shp_isWithinAHalfHourOfDate(Date()) == true
    }
    
    static func fromStoryboard() -> SpotDetailsViewController {
        return Storyboard.main.viewController(from: SpotDetailsViewController.StoryboardIdentifier)
    }
    
    func setupViews() {
        self.title = LocalizedStrings.SpotDetails
        self.startTimeLabel.text = LocalizedStrings.StartTime
        self.endTimeLabel.text = LocalizedStrings.EndTime
        self.distanceLabel.text = LocalizedStrings.DistanceFromDestination
        self.hoursTitleLabel.text = LocalizedStrings.HoursOfOperation
        self.aboutTitleLabel.text = LocalizedStrings.AboutThisSpot
        self.restrictionsTitleLabel.text = LocalizedStrings.Restrictions
        self.readMoreButton.setTitle(LocalizedStrings.ReadMore, for: .normal)
        self.bookButtonContainer.shp_addShadow()
        // Inset from design
        self.scrollView.contentInset = UIEdgeInsets(top: 0,
                                                    left: 0,
                                                    bottom: self.bookButtonContainer.frame.height + 32,
                                                    right: 0)
        self.separatorView.transform = CGAffineTransform.identity.rotated(by: CGFloat.pi / 8)
        self.imageCollectionView.dataSource = self
        self.imageCollectionView.delegate = self
        
        self.navigationController?.interactivePopGestureRecognizer?.delegate = self
        
        if DeviceType.isEqualOrLessThanIphone5() {
            self.separatorContainerView.isHidden = true
            self.spacerView.isHidden = true
            self.datesContainerView.axis = .vertical
            self.datesContainerView.spacing = HeightsAndWidths.Margins.Standard
        }
    }
    
    func setupFacility() {
        guard
            let facility = self.facility,
            let rate = facility.availableRates.first else {
                assertionFailure("You should have a facility")
                return
        }
        
        self.titleLabel.text = facility.title
        let formatter = SHPDateFormatter.DateWithTimeNoSlash
        if let timeZoneIdentifier = self.facility?.timeZone {
            formatter.timeZone = TimeZone(identifier: timeZoneIdentifier)
        }
        self.startDateTimeLabel.text = formatter.string(from: rate.starts)
        self.endDateTimeLabel.text = formatter.string(from: rate.ends)
        if let priceString = SHPNumberFormatter.dollarStringFromCents(rate.price) {
            self.bookButton.setTitle(String(format: LocalizedStrings.BookSpotFormat, priceString), for: .normal)
        }
        self.setRestrictions(facility: facility)
        self.setHours(facility: facility)
        self.aboutLabel.text = facility.gettingHere
        self.aboutLabel.numberOfLines = 3
        self.walkingDistanceLabel.numberOfLines = 1
        self.setupMap(facility: facility)
        self.setAmenities(rate: rate)
        
        //No oversized property so we are just gonna do this the dumb way until that's fixed
        var oversized = false
        var oversizedDescription = ""
        for restriction in facility.restrictions {
            if restriction.contains("oversize") {
                oversized = true
                oversizedDescription = restriction
                break
            }
        }
        if oversized {
            self.calloutContainerView.isHidden = false
            let callout = CalloutView(kind: .oversized(description: oversizedDescription))
            callout.delegate = self
            self.calloutStackView.addArrangedSubview(callout)
        }
        
        if
            let searchStart = self.searchStartDate,
            let searchEnd = self.searchEndDate,
            !searchEnd.shp_isEqual(rate.ends) {
                self.calloutContainerView.isHidden = false
                let callout = CalloutView(kind: .autoextension(oldTime: self.timeString(startDate: searchStart, endDate: searchEnd),
                                                               newTime: self.timeString(startDate: rate.starts, endDate: rate.ends)))
                callout.delegate = self
                self.calloutStackView.addArrangedSubview(callout)
        }
        
        if
            let start = rate.onlineCommuterRateEnterStart,
            let end = rate.onlineCommuterRateEnterEnd,
            let description = rate.onlineCommuterRateDescription,
            rate.isOnlineCommuterRate {
                self.calloutContainerView.isHidden = false
                let minutesFormatter = SHPDateFormatter.TimeOnly
                let noMinutesFormatter = SHPDateFormatter.TimeOnlyNoMins
            
                let startString: String
                if start.shp_onTheHour() {
                    startString = noMinutesFormatter.string(from: start)
                } else {
                    startString = minutesFormatter.string(from: start)
                }
            
                let endString: String
                if end.shp_onTheHour() {
                    endString = noMinutesFormatter.string(from: end)
                } else {
                    endString = minutesFormatter.string(from: end)
                }
            
                let callout = CalloutView(kind: .earlybird(startTime: startString, endTime: endString, description: description))
                callout.delegate = self
                self.calloutStackView.addArrangedSubview(callout)
        }
    }
    
    private func timeString(startDate: Date, endDate: Date) -> String {
        if startDate.shp_inSameDayAs(otherDate: endDate) {
            let dateOnlyFormatter = SHPDateFormatter.DateOnlyNoYear
            let timeOnlyFormatter = SHPDateFormatter.TimeOnly
            
            if let timeZone = self.facility?.timeZone {
                dateOnlyFormatter.timeZone = TimeZone(identifier: timeZone)
                timeOnlyFormatter.timeZone = TimeZone(identifier: timeZone)
            }

            return String(format: LocalizedStrings.SameDayFormat,
                          dateOnlyFormatter.string(from: startDate),
                          timeOnlyFormatter.string(from: startDate),
                          timeOnlyFormatter.string(from: endDate))
        }
        let dateFormatter = SHPDateFormatter.DateWithTimeNoComma
        return String(format: LocalizedStrings.DifferentDayFormat,
                      dateFormatter.string(from: startDate),
                      dateFormatter.string(from: endDate))
    }
    
    private func setRestrictions(facility: Facility) {
        guard !facility.restrictions.isEmpty else {
            self.restrictionsContainerView.isHidden = true
            return
        }
        
        let limit = 2
        let countToShow = self.restrictionsExpanded ? facility.restrictions.count : limit
        self.restrictionsExpanded = !self.restrictionsExpanded
        
        if facility.restrictions.count > countToShow {
            self.moreButton.setTitle(String(format: LocalizedStrings.MoreFormat, String(facility.restrictions.count - limit)),
                                     for: .normal)
        } else {
            self.moreButton.setTitle(LocalizedStrings.ReadLess, for: .normal)
        }
        
        self.moreButton.isHidden = facility.restrictions.count <= limit
        
        var restrictions = [String]()
        let count = min(countToShow, facility.restrictions.count)
        
        for index in 0..<count {
            restrictions.append("• \(facility.restrictions[index])")
        }
        
        self.restrictionsLabel.text = restrictions.joined(separator: "\n\n")
    }
    
    private func setHours(facility: Facility) {
        guard !facility.hoursOfOperation.text.isEmpty || !facility.hoursOfOperation.periods.isEmpty else {
            self.hoursContainerView.isHidden = true
            return
        }
        
        let hours = facility.hoursOfOperation
        let periods = hours.periods
        
        if !hours.text.isEmpty {
            self.hoursLabel.text = hours.text.joined(separator: " ")
        } else {
            self.hoursLabel.isHidden = true
        }
        
        if !periods.isEmpty {
            var hoursArray = [String]()
            var daysArray = [String]()
            var typeArray = [String]()
            
            for period in periods {
                let type = period.type
                let startDay = period.startDayOfWeek
                let startDayInt = period.startDayOfWeekInt
                let endDay = period.endDayOfWeek
                let endDayInt = period.endDayOfWeekInt
                
                typeArray.append(type.capitalized)
                
                let daysLine: String
                if startDayInt != endDayInt {
                    daysLine = "\(startDay) - \(endDay)"
                } else {
                    daysLine = "\(startDay)"
                }
                daysArray.append(daysLine)
                
                let hoursLine: String
                let dateFormatter = SHPDateFormatter.TimeOnly
                dateFormatter.timeZone = TimeZone(identifier: facility.timeZone)
                if
                    let startTime = period.startTime,
                    let endTime = period.endTime {
                        hoursLine = "\(dateFormatter.string(from: startTime)) - \(dateFormatter.string(from: endTime))"
                } else {
                    hoursLine = ""
                }

                hoursArray.append(hoursLine)
            }
            
            self.hoursTypeLabel.text = typeArray.joined(separator: "\n")
            self.daysLabel.text = daysArray.joined(separator: "\n")
            self.hoursPeriodLabel.text = hoursArray.joined(separator: "\n")
        } else {
            self.daysAndHoursView.isHidden = true
        }
    }
    
    private func setupMap(facility: Facility) {
        self.mapView.delegate = self
        self.setWalkingTime(facility: facility)
    }
    
    private func setWalkingTime(facility: Facility) {
        guard
            let searchLocation = self.searchLocation,
            let searchLocationName = self.searchLocationName else {
                return
        }
        
        let facilityCoordinate = facility.location.coordinate
        
        self.mapView?.delegate = self
        self.addAnnotations(start: facilityCoordinate, end: searchLocation.coordinate)
        
        let request = MKDirectionsRequest()
        request.source = MKMapItem(placemark: MKPlacemark(coordinate: facilityCoordinate))
        request.destination = MKMapItem(placemark: MKPlacemark(coordinate: searchLocation.coordinate))
        request.transportType = .walking
        
        let directions = MKDirections(request: request)
        
        directions.calculate {
            [weak self]
            response, _ in
            guard let strongSelf = self else {
                return
            }
            
            if let route = response?.routes.first {
                let rect = route.polyline.boundingMapRect
                let inset: CGFloat = 50 //From trial and error
                let padding = UIEdgeInsets(top: inset,
                                           left: inset,
                                           bottom: inset,
                                           right: inset)
                strongSelf.mapView?.setVisibleMapRect(rect,
                                                 edgePadding: padding,
                                                 animated: false)
                strongSelf.mapView?.add(route.polyline)
                
                let formatter = DateComponentsFormatter()
                formatter.unitsStyle = .short
                formatter.allowedUnits = [.hour, .minute]
                
                guard let distanceString = formatter.string(from: route.expectedTravelTime) else {
                    return
                }
                
                strongSelf.walkingDistanceLabel.text = String(format: LocalizedStrings.WalkingFormat,
                                                         distanceString,
                                                         searchLocationName)
            } else {
                strongSelf.walkingDistanceContainerView.isHidden = true
                strongSelf.mapView.showAnnotations(strongSelf.mapView.annotations, animated: false)
            }
        }
    }
    
    private func setAmenities(rate: Rate) {
        let amenitiesView = AmenityView(multilineAmenities: rate.appVisibleAmenities, width: self.titleLabel.frame.width)
        amenitiesView.translatesAutoresizingMaskIntoConstraints = false
        self.amenityContainerView.addSubview(amenitiesView)
        NSLayoutConstraint.activate([
            amenitiesView.topAnchor.constraint(equalTo: self.amenityContainerView.topAnchor, constant: HeightsAndWidths.Margins.Standard),
            amenitiesView.leadingAnchor.constraint(equalTo: self.amenityContainerView.leadingAnchor),
            amenitiesView.trailingAnchor.constraint(equalTo: self.amenityContainerView.trailingAnchor),
            amenitiesView.bottomAnchor.constraint(equalTo: self.amenityContainerView.bottomAnchor, constant: -HeightsAndWidths.Margins.Standard),
            ])
    }
    
    private func addAnnotations(start: CLLocationCoordinate2D, end: CLLocationCoordinate2D) {
        let startAnnotation = DestinationAnnotation(type: .spotDetailsSpot, coordinate: start)
        self.mapView?.addAnnotation(startAnnotation)
        
        let endAnnotation = DestinationAnnotation(type: .spotDetailsDestination, coordinate: end)
        self.mapView?.addAnnotation(endAnnotation)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let viewController = segue.destination as? CheckoutViewController {
            viewController.facility = self.facility
            viewController.rate = self.facility?.availableRates.first
        }
    }
    
    @IBAction func moreButtonTapped(_ sender: Any) {
        guard let facility = self.facility else {
            return
        }
        
        self.setRestrictions(facility: facility)
    }
    
    @IBAction func readMoreButtonTapped(_ sender: Any) {
        self.aboutExpanded = !self.aboutExpanded
        self.aboutLabel.numberOfLines = self.aboutExpanded ? 0 : 3
        self.readMoreButton.setTitle(self.aboutExpanded ? LocalizedStrings.ReadLess : LocalizedStrings.ReadMore,
                                     for: .normal)
    }
    
    @IBAction func bookButtonTapped(_ sender: Any) {
        Segue.showCheckout.perform(viewController: self)
    }
}

//MARK: - MKMapViewDelegate

extension SpotDetailsViewController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        guard let polyline = overlay as? MKPolyline else {
            return MKOverlayRenderer(overlay: overlay)
        }
        
        let renderer = MKPolylineRenderer(polyline: polyline)
        renderer.strokeColor = .shp_shift
        renderer.lineWidth = 2
        renderer.lineDashPattern = [10, 10]
        return renderer
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        guard let annotation = annotation as? DestinationAnnotation else {
            return nil
        }
        
        let mapAnnotationView: DestinationAnnotationView
        if let recycledView = mapView
            .dequeueReusableAnnotationView(withIdentifier: DestinationAnnotationView.Identifier) as? DestinationAnnotationView {
                mapAnnotationView = recycledView
        } else {
            mapAnnotationView = DestinationAnnotationView(annotation: annotation,
                                                          reuseIdentifier: DestinationAnnotationView.Identifier,
                                                          type: annotation.type)
        }
        
        mapAnnotationView.annotation = annotation
        
        mapAnnotationView.canShowCallout = false
        return mapAnnotationView
    }
}

//MARK: - UICollectionViewDataSource

extension SpotDetailsViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.facility?.images.count ?? 0
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ImageCollectionViewCell.ReuseIdentifier,
                                                            for: indexPath) as? ImageCollectionViewCell else {
            return UICollectionViewCell()
        }
        
        if let image = self.facility?.images[indexPath.row] {
            cell.configure(image: image)
        }
        
        return cell
    }
}

extension SpotDetailsViewController: UICollectionViewDelegate {
    func scrollViewWillEndDragging(_ scrollView: UIScrollView,
                                   withVelocity velocity: CGPoint,
                                   targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        guard let images = facility?.images else {
            return
        }
        
        let velocityX = velocity.x
        let gesture = scrollView.panGestureRecognizer
        let point = gesture.location(in: scrollView)
        
        // Get the spot card that was panned. Otherwise just scroll to the current center
        guard
            let collectionView = scrollView as? UICollectionView,
            let layout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout,
            let indexPath = collectionView.indexPathForItem(at: point) else {
                return
        }
        
        // Guess based on trial and error
        let velocityThreshold: CGFloat = 0.3
        var indexToScrollTo: Int = indexPath.item
        
        // If the velocity is less than the threshold see how far it was panned
        if abs(velocityX) < velocityThreshold {
            // Get amount scrollview was panned
            let deltaX = gesture.translation(in: collectionView).x
            // Guess based on trial and error
            let nextCardThreshold: CGFloat = scrollView.frame.width / 3.0
            // if the delta is greater that the threshold then go to next card.
            if deltaX > nextCardThreshold {
                indexToScrollTo -= 1
            } else if deltaX < -nextCardThreshold {
                indexToScrollTo += 1
            }
        } else {
            // Scroll to a card in the direction of the velocity
            let pagesToScroll = Int(velocityX.rounded())
            indexToScrollTo += pagesToScroll
        }
        
        //clamp the new index to the bounds of the items array
        indexToScrollTo = min(max(indexToScrollTo, 0), images.count - 1)
        guard images.indices.contains(indexToScrollTo) else {
            assertionFailure("trying to scroll to a cell that's out of bounds: \(indexToScrollTo)")
            return
        }
        
        //update the targetContentOffset so that the desired index is centered on screen
        let cellSpacing = layout.minimumLineSpacing
        let insets = collectionView.contentInset.left + collectionView.contentInset.right
        targetContentOffset.pointee.x = CGFloat(indexToScrollTo) * (self.imageCellSize.width + cellSpacing) - insets
    }
}

//MARK: - UICollectionViewDelegateFlowLayout

extension SpotDetailsViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        return self.imageCellSize
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0,
                            left: self.topContentLeadingContraint.constant,
                            bottom: 0,
                            right: self.topContentLeadingContraint.constant)
    }
}

extension SpotDetailsViewController: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer,
                           shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return otherGestureRecognizer !== self.imageCollectionView.panGestureRecognizer
    }
}

extension SpotDetailsViewController: CalloutViewDelegate {
    func didTapInfoButton(calloutView: CalloutView) {
        let viewController = PopoverViewController(kind: calloutView.kind)
        viewController.view.alpha = 0.0
        self.present(viewController, animated: false) {
            UIView.animate(withDuration: Animation.Duration.Standard) {
                viewController.view.alpha = 1.0
            }
        }
    }
}
