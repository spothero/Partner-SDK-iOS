//
//  SpotCardCollectionViewCell.swift
//  Pods
//
//  Created by Husein Kareem on 9/9/16.
//
//

import UIKit

protocol SpotCardCollectionViewDelegate {
    func didTapDoneButton(button: UIButton)
}

class SpotCardCollectionViewCell: UICollectionViewCell {
    var delegate: SpotCardCollectionViewDelegate?
    
    static let Identifier = "SpotCardCellID"
    static let ItemWidth: CGFloat = 275
    static let ItemHeight: CGFloat = 120
    static let ItemSpacing: CGFloat = 10
    @IBOutlet weak var buyButton: UIButton!
    @IBOutlet weak var streetAddressLabel: UILabel!
    @IBOutlet weak var spotInfoLabel: UILabel!
    @IBOutlet weak var accessibleParkingImageView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.layer.cornerRadius = HeightsAndLengths.standardCornerRadius
        self.backgroundColor = .whiteColor()
        self.layer.borderWidth = 1.0
        self.layer.borderColor = UIColor.shp_lightGray().CGColor
    
        self.accessibleParkingImageView.image = UIImage(named: "accessibility",
                                                        inBundle: NSBundle.shp_resourceBundle(),
                                                        compatibleWithTraitCollection: nil)
        self.buyButton.backgroundColor = .shp_spotHeroBlue()
    }
    
    @IBAction func didTapBuyButton(button: UIButton) {
        self.delegate?.didTapDoneButton(button)
    }
}
