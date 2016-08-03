//
//  PredictionController.swift
//  Pods
//
//  Created by Matthew Reed on 7/15/16.
//
//

import UIKit

protocol PredictionControllerDelegate {
    func didUpdatePredictions(predictions: [GooglePlacesPrediction])
    func didSelectPrediction(prediction: GooglePlacesPrediction)
    func didTapXButton()
}

class PredictionController: NSObject {
    private var predictions = [GooglePlacesPrediction]() {
        didSet {
            guard let delegate = self.delegate?.didUpdatePredictions(self.predictions) else {
                return assertionFailure("delegate is nil")
            }
        }
    }
    
    var delegate: PredictionControllerDelegate?
}

//MARK: UITableViewDataSource

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

//MARK: UITableViewDelegate

extension PredictionController: UITableViewDelegate {
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let prediction = predictions[indexPath.row]
        guard let delegate = self.delegate else {
            return assertionFailure("delegate is nil")
        }
        delegate.didSelectPrediction(prediction)
        self.predictions.removeAll()
        GooglePlacesWrapper.getPlaceDetails(prediction) {
            placeDetails, error in
            if let placeDetails = placeDetails {
                //TODO: Search place for spots
            }
        }
    }
    
    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = tableView.dequeueReusableHeaderFooterViewWithIdentifier("predictionHeader") as! GooglePredictionTableHeader
        view.label.text = LocalizedStrings.BestMatches
        return view
    }
    
    func tableView(tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let view = tableView.dequeueReusableHeaderFooterViewWithIdentifier("predictionFooter")
        return view
    }
}

//MARK: UISearchBarDelegate

extension PredictionController: UISearchBarDelegate {
    func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
        GooglePlacesWrapper.getPredictions(searchText) { (predictions, error) -> (Void) in
            NSOperationQueue.mainQueue().addOperationWithBlock({
                self.predictions = predictions
            })
        }
        
        if (searchText.characters.count == 0) {
            self.delegate?.didTapXButton()
        }
    }
}
