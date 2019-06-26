//
//  SearchViewController.swift
//  SpotHero_iOS_Partner_SDK
//
//  Created by Matthew Reed on 12/5/17.
//

import UIKit

class SearchViewController: SpotHeroPartnerViewController {
    @IBOutlet private var titleLabel: UILabel!
    @IBOutlet private var detailsLabel: UILabel!
    @IBOutlet private var searchLabel: UILabel!
    @IBOutlet fileprivate var searchBar: TextInputView!
    @IBOutlet fileprivate var contentContainerView: UIView!
    @IBOutlet fileprivate var containerView: UIView!
    @IBOutlet fileprivate var tableView: UITableView!
    @IBOutlet fileprivate var startDateInput: DateInputView!
    @IBOutlet fileprivate var endDateInput: DateInputView!
    @IBOutlet fileprivate var dateContainerView: UIView!
    @IBOutlet private var whatTimeLabel: UILabel!
    @IBOutlet fileprivate var whatTimeLabelContainer: UIView!
    @IBOutlet fileprivate var scrollView: UIScrollView!
    fileprivate lazy var searchButton: PrimaryButton = {
        let button = PrimaryButton()
        button.setTitle(LocalizedStrings.Search, for: .normal)
        button.addTarget(self, action: #selector(self.search), for: .touchUpInside)
        return button
    }()
    
    static let StoryboardIdentifier = String(describing: SearchViewController.self)
    
    fileprivate var containerViewBottomConstraint: NSLayoutConstraint?
    fileprivate var predictions = [GooglePlacesPrediction]()
    fileprivate var debouncedTask: DebouncedTask?
    
    fileprivate var selectedPrediction: GooglePlacesPrediction?
    fileprivate var selectedCity: City?
    private var googlePlaceDetails: GooglePlaceDetails?
    
    fileprivate var cities = CityListAPI.cities
    fileprivate var tapGesture: UITapGestureRecognizer?
    
    static func fromStoryboard() -> SearchViewController {
        return Storyboard.main.viewController(from: self.StoryboardIdentifier)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.setupViews()
    }

    private func setupViews() {
        self.title = LocalizedStrings.BookParking
        self.titleLabel.text = LocalizedStrings.ParkSmarter
        self.detailsLabel.text = LocalizedStrings.SearchDetail
        self.searchLabel.text = LocalizedStrings.WhereAreYouGoing
        self.searchBar.accessibilityLabel = AccessibilityStrings.SearchBar
        self.searchBar.placeholder = LocalizedStrings.SearchPlaceholder
        self.searchBar.image = UIImage(shp_named: "ic_search")
        self.searchBar.delegate = self
        self.tableView.dataSource = self
        self.tableView.delegate = self
        self.startDateInput.placeholder = LocalizedStrings.StartTime
        self.startDateInput.image = UIImage(shp_named: "icn_clock")
        self.startDateInput.setToolbarTitle(LocalizedStrings.StartTime, buttonText: LocalizedStrings.Next)
        self.startDateInput.dateDelegate = self
        self.startDateInput.delegate = self
        self.endDateInput.placeholder = LocalizedStrings.EndTime
        self.endDateInput.image = UIImage(shp_named: "icn_clock")
        self.endDateInput.setToolbarTitle(LocalizedStrings.EndTime, buttonText: LocalizedStrings.Search)
        self.endDateInput.dateDelegate = self
        self.endDateInput.delegate = self
        self.whatTimeLabel.text = LocalizedStrings.WhatTime
        self.whatTimeLabel.font = .shp_headline
        self.whatTimeLabel.textColor = .shp_primary
        self.setupSearchButton()

        if cities.isEmpty {
            CityListAPI.getCities { [weak self] cities in
                self?.cities = cities
                self?.tableView.reloadData()
            }
        }
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.hideKeyboard(gesture:)))
        self.view.addGestureRecognizer(tapGesture)
        self.tapGesture = tapGesture
        self.tapGesture?.isEnabled = false
    }
    
    private func setupSearchButton() {
        self.scrollView.addSubview(self.searchButton)
        self.searchButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            self.searchButton.leadingAnchor.constraint(equalTo: self.scrollView.leadingAnchor),
            self.searchButton.trailingAnchor.constraint(equalTo: self.scrollView.trailingAnchor),
            self.searchButton.bottomAnchor.constraint(equalTo: self.scrollView.layoutMarginsGuide.bottomAnchor),
            self.searchButton.heightAnchor.constraint(equalToConstant: 44),
        ])
        self.searchButton.isHidden = true
    }
    
    override func willShowKeyboard(notification: Notification) {
        guard
            let userInfo = notification.userInfo,
            let keyboardFrame = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect else {
                return
        }
        
        let inset = UIEdgeInsets(top: 0,
                                 left: 0,
                                 bottom: keyboardFrame.height + HeightsAndWidths.Margins.Large,
                                 right: 0)
        
        self.tableView.contentInset = inset
        self.scrollView.contentInset = inset
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.updateDates()
    }
    
    override func willHideKeyboard(notification: Notification) {
        self.tableView.contentInset = UIEdgeInsets.zero
        self.scrollView.contentInset = UIEdgeInsets.zero
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let map = segue.destination as? MapViewController else {
            return
        }
        
        map.googlePlaceDetails = self.googlePlaceDetails
        map.city = self.selectedCity
        map.startDate = self.startDateInput.date
        map.endDate = self.endDateInput.date
    }
    
    private func updateDates() {
        self.startDateInput.minimumDate = Date().shp_roundDateToNearestHalfHour(roundDown: true)
        if endDateInput.minimumDate != nil {
            self.setMinimumEndDate()
        }
    }
    
    fileprivate func setMinimumEndDate() {
        self.endDateInput.minimumDate = self.startDateInput.date.shp_roundDateToNearestHalfHour(roundDown: false)
    }
    
    @IBAction fileprivate func search() {
        guard self.endDateInput.date.shp_isAfterDate(self.startDateInput.date) else {
            return
        }
        
        let completion: GooglePlaceDetailsCompletion = { [weak self] details, error in
            guard let self = self else {
                return
            }
            // TODO: handle error? possibly fallback on apple's geodecoding?
            self.googlePlaceDetails = details
            Segue.showMap.perform(viewController: self)
        }
        
        if let prediction = self.selectedPrediction {
            GooglePlacesWrapper.getPlaceDetails(prediction, completion: completion)
        } else if let city = self.selectedCity {
            GooglePlacesWrapper.getPlaceDetails(city, completion: completion)
        }
    }
    
    @IBAction private func hideKeyboard(gesture: UITapGestureRecognizer) {
        self.view.endEditing(true)
    }
}

// MARK: TextInputViewDelegate

extension SearchViewController: TextInputViewDelegate {
    func didBeginEditing(input: TextInputView) {
        if input === self.searchBar {
            self.tapGesture?.isEnabled = false
            self.scrollView.isScrollEnabled = false
            self.contentContainerView.isHidden = true
            self.navigationController?.setNavigationBarHidden(true, animated: true)
            if self.containerViewBottomConstraint == nil {
                self.containerViewBottomConstraint = self.containerView.heightAnchor.constraint(equalTo: self.view.heightAnchor)
            } else {
                self.dateContainerView.isHidden = true
                self.tableView.isHidden = false
                self.whatTimeLabelContainer.isHidden = true
                self.searchButton.isHidden = true
            }
            
            //Magic number from design plus extra space for status bar
            let topScrollViewMargin = 42
            self.scrollView.contentOffset = CGPoint(x: 0, y: -topScrollViewMargin)
            self.containerViewBottomConstraint?.isActive = true
            self.searchButton.isHidden = true
        } else {
            self.tapGesture?.isEnabled = true
            self.scrollView.isScrollEnabled = true
            self.searchButton.isHidden = false
            self.scrollView.scrollRectToVisible(input.frame, animated: true)
            self.searchButton.isHidden = false
        }
    }
    
    func didEndEditing(input: TextInputView) {
        if input === self.startDateInput {
            self.setMinimumEndDate()
        }
    }
    
    func didUpdateText(text: String?, input: TextInputView) {
        guard let text = text else {
            return
        }
        
        self.debouncedTask?.isCancelled = true
        
        let debouncedTask = DebouncedTask { [weak self] in
            self?.debouncedTask = nil
            
            GooglePlacesWrapper.getPredictions(text) { predictions, _ in
                self?.predictions = predictions
                self?.tableView.reloadData()
            }
        }
        
        debouncedTask.schedule(withDelay: 0.3)
        self.debouncedTask = debouncedTask
    }
}

// MARK: UITableViewDelegate

extension SearchViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = UIView()
        let label = UILabel()
        label.font = .shp_title
        label.textColor = .shp_primary
        label.text = self.predictions.isEmpty ? LocalizedStrings.AvailableCities : LocalizedStrings.RecommendedPlaces
        label.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(label)
        view.backgroundColor = .white
        let topPadding: CGFloat = 24
        let bottomPadding: CGFloat = 16
        NSLayoutConstraint.activate([
            label.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            label.topAnchor.constraint(equalTo: view.topAnchor, constant: topPadding),
            view.bottomAnchor.constraint(equalTo: label.bottomAnchor, constant: bottomPadding),
        ])
        
        return view
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let completion: TimeZoneCompletion = {
            [weak self]
            timeZone in
            self?.tableView.isHidden = true
            self?.containerViewBottomConstraint?.isActive = false
            self?.dateContainerView.isHidden = false
            self?.whatTimeLabelContainer.isHidden = false
            self?.navigationController?.setNavigationBarHidden(false, animated: true)
            self?.startDateInput.timeZone = timeZone
            self?.endDateInput.timeZone = timeZone
            self?.startDateInput.becomeActive()
        }
        
        let title: String
        if self.predictions.isEmpty {
            let city = self.cities[indexPath.row]
            title = city.title
            self.selectedCity = city
            city.location.shp_timeZone(completion: completion)
            self.selectedPrediction = nil
        } else {
            let prediction = self.predictions[indexPath.row]
            title = prediction.predictionDescription
            self.selectedPrediction = prediction
            prediction.timeZone(completion: completion)
            self.selectedCity = nil
        }
        
        self.searchBar.text = title
        
    }
}

// MARK: UITableViewDataSource

extension SearchViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.predictions.isEmpty ? self.cities.count : self.predictions.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: SearchTableViewCell.ReuseIdentifier) as? SearchTableViewCell else {
            assertionFailure("Cannot create SearchTableViewCell")
            return UITableViewCell()
        }
        
        let title = self.predictions.isEmpty ? self.cities[indexPath.row].title : self.predictions[indexPath.row].predictionDescription
        cell.configure(title: title)

        return cell
    }
}

// MARK: UITableViewDelegate

extension SearchViewController: DateInputViewDelegate {
    func didTapButton(input: DateInputView) {
        if input == self.startDateInput {
            self.endDateInput.becomeActive()
        } else {
            self.search()
        }
    }
    
    func didUpdateDate(input: DateInputView) {
        if input === self.startDateInput && self.startDateInput.date.shp_isAfterDate(self.endDateInput.date) {
            self.setMinimumEndDate()
        }
    }
}
