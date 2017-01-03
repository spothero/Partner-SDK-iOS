//
//  PredictionController.swift
//  Pods
//
//  Created by Matthew Reed on 7/15/16.
//
//

import UIKit

protocol PredictionControllerDelegate: class {
    func didUpdatePredictions(predictions: [GooglePlacesPrediction])
    func didSelectPrediction(prediction: GooglePlacesPrediction)
    func didTapXButton()
    func didTapSearchButton()
    func didBeginEditingSearchBar()
    func shouldSelectFirstPrediction()
}

class PredictionController: NSObject {
    let headerFooterHeight: CGFloat = 30
    var block: dispatch_block_t?
    
    var predictions = [GooglePlacesPrediction]()
    
    weak var delegate: PredictionControllerDelegate?
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
        self.predictions.removeAll()
        delegate.didSelectPrediction(prediction)
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
    
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        // Number chosen to match designs
        return self.headerFooterHeight
    }
    
    func tableView(tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        // Number chosen to match designs
        return self.headerFooterHeight
    }
}

//MARK: UISearchBarDelegate

extension PredictionController: UISearchBarDelegate {
    func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
        if let block = self.block {
            dispatch_block_cancel(block)
        }
        
        self.block = dispatch_block_create(DISPATCH_BLOCK_INHERIT_QOS_CLASS) {
            [weak self] in
            self?.searchText(searchText)
        }
        
        let delay: Double
        
        if TestingHelper.isUITesting() {
            delay = 1.0
        } else {
            delay = 0.3
        }
        
        // Force unwrapped due to block being set above
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(delay * Double(NSEC_PER_SEC))),
                       dispatch_get_main_queue(),
                       self.block!)
    }
    
    func searchText(searchText: String) {
        GooglePlacesWrapper.getPredictions(searchText) {
            [weak self]
            predictions, error in
            self?.predictions = predictions
            guard let delegate = self?.delegate else {
                assertionFailure("Delegate is nil!")
                return
            }
            
            if !predictions.isEmpty {
                delegate.shouldSelectFirstPrediction()
            } else {
                delegate.didTapXButton()
            }
        }
        
        if (searchText.isEmpty) {
            self.delegate?.didTapXButton()
        }
    }
    
    func searchBarTextDidBeginEditing(searchBar: UISearchBar) {
        self.delegate?.didBeginEditingSearchBar()
    }
    
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        guard !predictions.isEmpty else {
            return
        }
        
        self.delegate?.didTapSearchButton()
        searchBar.resignFirstResponder()
    }
}
