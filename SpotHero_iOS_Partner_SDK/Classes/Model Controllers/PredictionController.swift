//
//  PredictionController.swift
//  Pods
//
//  Created by SpotHeroMatt on 7/15/16.
//
//

import UIKit

protocol PredictionControllerDelegate {
    func didUpdatePredictions(predictions: [GooglePlacesPrediction])
    func didSelectPrediction(prediction: GooglePlacesPrediction)
}

class PredictionController: NSObject {
    var predictions = [GooglePlacesPrediction]() {
        didSet {
            delegate?.didUpdatePredictions(self.predictions)
        }
    }
    
    var delegate: PredictionControllerDelegate?
}

extension PredictionController: UITableViewDataSource {
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.predictions.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("predictionCell", forIndexPath: indexPath) as! PredictionTableViewCell
        
        cell.configureCell(predictions[indexPath.row])
        
        return cell
    }
}

extension PredictionController: UITableViewDelegate {
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let prediction = predictions[indexPath.row]
        delegate?.didSelectPrediction(prediction)
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
            
        return view
    }
}

extension PredictionController: UISearchBarDelegate {
    func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
        GooglePlacesWrapper.getPredictions(searchText) { (predictions, error) -> (Void) in
            NSOperationQueue.mainQueue().addOperationWithBlock({
                self.predictions = predictions
            })
        }
    }
}