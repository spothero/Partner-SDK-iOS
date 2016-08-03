//
//  PredictionTableViewCell.swift
//  Pods
//
//  Created by Matthew Reed on 7/14/16.
//
//

import UIKit

class PredictionTableViewCell: UITableViewCell {
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var cityLabel: UILabel!

    func configureCell(prediction: GooglePlacesPrediction) {
        addressLabel.text = prediction.terms.first
        
        // Remove first term (address) and last term (country) and join with a comma
        cityLabel.text = prediction.terms
            .filter({ $0 != prediction.terms.first && $0 != prediction.terms.last })
            .joinWithSeparator(", ")
    }
}
