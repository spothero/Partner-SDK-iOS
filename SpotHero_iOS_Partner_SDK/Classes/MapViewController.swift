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
    
    var predictions = [GooglePlacesPrediction]() {
        didSet {
            self.updatePredictions()
        }
    }
    
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
        self.searchContainerView.layer.cornerRadius = 5
        self.searchContainerView.layer.masksToBounds = true
    }
    
    @IBAction private func closeButtonPressed(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    private func updatePredictions() {
        self.predictionTableView.reloadData()
        self.view.layoutIfNeeded()
        UIView.animateWithDuration(0.3, animations: {             
            let searchBarHeight: CGFloat = 44
            let headerFooterHeight: CGFloat = 28
            let rowHeight: CGFloat = 60
            
            if self.predictions.count > 0 {
                self.searchContainerViewHeightConstraint.constant = searchBarHeight + CGFloat(self.predictions.count) * rowHeight + headerFooterHeight * 2
            } else {
                self.searchContainerViewHeightConstraint.constant = searchBarHeight
            }
            self.view.layoutIfNeeded()
            }, completion: nil)
    }
}

extension MapViewController: UITableViewDataSource {
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.predictions.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("predictionCell", forIndexPath: indexPath) as! PredictionTableViewCell
        
        cell.configureCell(predictions[indexPath.row])
        
        return cell
    }
}

extension MapViewController: UITableViewDelegate {
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let prediction = predictions[indexPath.row]
        searchBar.text = prediction.description
        predictions.removeAll()
        GooglePlacesWrapper.getPlaceDetails(prediction) {
            placeDetails, error in
            if let placeDetails = placeDetails {
                //TODO: Search place for spots
            }
        }
    }
    
    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = UIView()
        view.backgroundColor = .whiteColor()
        
        let label = UILabel()
        label.text = LocalizedStrings.BestMatches
        label.font = UIFont.systemFontOfSize(14)
        label.textColor = UIColor(white: 0.6, alpha: 1)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.preservesSuperviewLayoutMargins = true
        
        view.addSubview(label)
        view.preservesSuperviewLayoutMargins = true

        view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("|-[label]",
            options: NSLayoutFormatOptions(rawValue: 0),
            metrics: nil,
            views: ["label" : label]))
        view.addConstraint(NSLayoutConstraint(item: label,
            attribute: .CenterY,
            relatedBy: .Equal,
            toItem: view,
            attribute: .CenterY,
            multiplier: 1,
            constant: 0))
        
        let border = UIView()
        border.translatesAutoresizingMaskIntoConstraints = false
        border.backgroundColor = UIColor(white: 0.9, alpha: 1)
        
        view.addSubview(border)
        
        view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("|-0-[border]-0-|",
            options: NSLayoutFormatOptions(rawValue: 0),
            metrics: nil,
            views: ["border" : border]))
        view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:[border(1)]-0-|",
            options: NSLayoutFormatOptions(rawValue: 0),
            metrics: nil,
            views: ["border" : border]))
        
        self.view.layoutIfNeeded()
        
        return view
    }
    
    func tableView(tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let view = UIView()
        view.backgroundColor = .whiteColor()
        
        let imageView = UIImageView(image: UIImage(named: "powered_by_google_on_white", inBundle: NSBundle(forClass: MapViewController.self), compatibleWithTraitCollection: nil))
        imageView.contentMode = .ScaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(imageView)
        
        view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("|-[imageView]-|",
            options: NSLayoutFormatOptions(rawValue: 0),
            metrics: nil,
            views: ["imageView" : imageView]))
        view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|-[imageView]-|",
            options: NSLayoutFormatOptions(rawValue: 0),
            metrics: nil,
            views: ["imageView" : imageView]))
        
        let border = UIView()
        border.translatesAutoresizingMaskIntoConstraints = false
        border.backgroundColor = UIColor(white: 0.9, alpha: 1)
        
        view.addSubview(border)
        
        view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("|-0-[border]-0-|",
            options: NSLayoutFormatOptions(rawValue: 0),
            metrics: nil,
            views: ["border" : border]))
        view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|-0-[border(1)]",
            options: NSLayoutFormatOptions(rawValue: 0),
            metrics: nil,
            views: ["border" : border]))
        
        self.view.layoutIfNeeded()
        
        return view
    }
}

extension MapViewController: UISearchBarDelegate {
    func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
        GooglePlacesWrapper.getPredictions(searchText) { (predictions, error) -> (Void) in
            NSOperationQueue.mainQueue().addOperationWithBlock({
                self.predictions = predictions
            })
        }
    }
}
