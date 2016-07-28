//
//  PersonalInfoTableViewCell.swift
//  Pods
//
//  Created by SpotHeroMatt on 7/27/16.
//
//

import UIKit

class PersonalInfoTableViewCell: UITableViewCell, CheckoutCell {
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var primaryLabel: UILabel!
    
    func configureCell(title: String, primaryText: String, secondaryText: String) {
        self.titleLabel.text = title
        self.primaryLabel.text = primaryText
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
