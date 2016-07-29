//
//  PaymentInfoTableViewCell.swift
//  Pods
//
//  Created by SpotHeroMatt on 7/27/16.
//
//

import UIKit

class PaymentInfoTableViewCell: UITableViewCell {
    @IBOutlet weak var creditCardView: UIView!
    @IBOutlet weak var cardImage: UIImageView!
    @IBOutlet weak var creditCardTextField: UITextField!
    @IBOutlet weak var creditCardContainerView: UIView!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.creditCardView.layer.borderWidth = 1
        //TODO: Use some sort of utility file for colors
        self.creditCardView.layer.borderColor = UIColor(white: 0.9, alpha: 1).CGColor
        self.creditCardView.layer.cornerRadius = 5
        self.creditCardContainerView.layer.cornerRadius = 5
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
}
