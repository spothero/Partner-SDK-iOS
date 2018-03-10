//
//  PredictionController.swift
//  Pods
//
//  Created by Matthew Reed on 7/15/16.
//
//

import UIKit

protocol PredictionControllerDelegate: class {
    func didUpdatePredictions(_ predictions: [GooglePlacesPrediction])
    func didSelectPrediction(_ prediction: GooglePlacesPrediction)
    func didTapXButton()
    func didTapSearchButton()
    func didBeginEditingSearchBar()
    func shouldSelectFirstPrediction()
}

//TODO: Decide if we still need this
class PredictionController: NSObject {
    let headerFooterHeight: CGFloat = 30
    var debouncedTask: DebouncedTask?
    
    var predictions = [GooglePlacesPrediction]() {
        didSet {
            guard let delegate = self.delegate else {
                assertionFailure("delegate is nil")
                return
            }
            
            delegate.didUpdatePredictions(self.predictions)
        }
    }
    
    weak var delegate: PredictionControllerDelegate?
}

//MARK: UITableViewDataSource

extension PredictionController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.predictions.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "predictionCell", for: indexPath) as? PredictionTableViewCell else {
            assertionFailure("Could not get prediction tableview cell")
            return UITableViewCell()
        }
        
        cell.configureCell(predictions[indexPath.row])
        
        return cell
    }
}

//MARK: UITableViewDelegate

extension PredictionController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let prediction = predictions[indexPath.row]
        guard let delegate = self.delegate else {
            return assertionFailure("delegate is nil")
        }
        self.predictions.removeAll()
        delegate.didSelectPrediction(prediction)
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard let view = tableView.dequeueReusableHeaderFooterView(withIdentifier: "predictionHeader") as? GooglePredictionTableHeader else {
            assertionFailure("Could not dequeue predicton header")
            return nil
        }
        view.label.text = LocalizedStrings.BestMatches
        return view
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let view = tableView.dequeueReusableHeaderFooterView(withIdentifier: "predictionFooter")
        return view
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        // Number chosen to match designs
        return self.headerFooterHeight
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        // Number chosen to match designs
        return self.headerFooterHeight
    }
}

//MARK: UISearchBarDelegate

extension PredictionController: UISearchBarDelegate {

    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        self.debouncedTask?.isCancelled = true
        
        let debouncedTask = DebouncedTask(task: {
            [weak self] in
            self?.debouncedTask = nil
            self?.searchText(searchText)
        })
        
        let delay: Double
        
        if TestingHelper.isUITesting() {
            delay = 1.0
        } else {
            delay = 0.3
        }
        
        debouncedTask.schedule(withDelay: delay)
        self.debouncedTask = debouncedTask
    }
    
    func searchText(_ searchText: String) {
        GooglePlacesWrapper.getPredictions(searchText) {
            [weak self]
            predictions, _ in
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
        
        if searchText.isEmpty {
            self.delegate?.didTapXButton()
        }
    }
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        self.delegate?.didBeginEditingSearchBar()
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        guard !predictions.isEmpty else {
            return
        }
        
        self.delegate?.didTapSearchButton()
        searchBar.resignFirstResponder()
    }
}
