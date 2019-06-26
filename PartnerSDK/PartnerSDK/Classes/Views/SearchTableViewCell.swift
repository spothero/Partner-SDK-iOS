//
//  SearchTableViewCell.swift
//  SpotHero_iOS_Partner_SDK
//
//  Created by Matthew Reed on 12/8/17.
//

import UIKit

class SearchTableViewCell: UITableViewCell {
    static let ReuseIdentifier = String(describing: SearchTableViewCell.self)

    @IBOutlet private var titleLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.titleLabel.font = .shp_subhead
        self.titleLabel.textColor = .shp_link
    }
    
    func configure(title: String) {
        self.titleLabel.text = title
    }
}
