//
//  PredictionTableViewCell.swift
//  Pods
//
//  Created by SpotHeroMatt on 7/14/16.
//
//

import UIKit

class PredictionTableViewCell: UITableViewCell {
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var cityLabel: UILabel!

    func configureCell(prediction: GooglePlacesPrediction) {
        addressLabel.text = prediction.terms.first
        cityLabel.text = prediction.terms
            .filter({ $0 != prediction.terms.first && $0 != prediction.terms.last })
            .joinWithSeparator(", ")
    }
}
