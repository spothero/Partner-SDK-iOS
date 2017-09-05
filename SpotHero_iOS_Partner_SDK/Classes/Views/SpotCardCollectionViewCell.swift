//
//  SpotCardCollectionViewCell.swift
//  Pods
//
//  Created by Husein Kareem on 9/9/16.
//
//

import UIKit

protocol SpotCardCollectionViewDelegate: class {
    func didTapDoneButton(_ button: UIButton)
}

class SpotCardCollectionViewCell: UICollectionViewCell {
    weak var delegate: SpotCardCollectionViewDelegate?
    
    static let Identifier = "SpotCardCellID"
    static let ItemWidth: CGFloat = 275
    static let ItemHeight: CGFloat = 120
    static let ItemSpacing: CGFloat = 10
    @IBOutlet private(set) weak var buyButton: UIButton!
    @IBOutlet private(set) weak var streetAddressLabel: UILabel!
    @IBOutlet private(set) weak var spotInfoLabel: UILabel!
    @IBOutlet private(set) weak var accessibleParkingImageView: UIImageView!
    @IBOutlet private(set) weak var noReentryImageView: UIImageView!    
    //swiftlint:disable:next variable_name (yes, this is long. so what?)
    @IBOutlet private(set) weak var accessibleParkingImageViewWidthConstraint: NSLayoutConstraint!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.layer.cornerRadius = HeightsAndLengths.standardCornerRadius
        self.backgroundColor = .white
        self.layer.borderWidth = 1.0
        self.layer.borderColor = UIColor.shp_lightGray().cgColor
    
        self.accessibleParkingImageView.image = UIImage(named: "accessibility",
                                                        in: Bundle.shp_resourceBundle(),
                                                        compatibleWith: nil)
        self.noReentryImageView.image = UIImage(named: "Noreentry",
                                                in: Bundle.shp_resourceBundle(),
                                                compatibleWith: nil)
        self.buyButton.backgroundColor = .shp_spotHeroBlue()
        self.buyButton.isEnabled = false
        self.buyButton.accessibilityLabel = LocalizedStrings.BookIt
    }
    
    @IBAction func didTapBuyButton(_ button: UIButton) {
        self.delegate?.didTapDoneButton(button)
    }
}
