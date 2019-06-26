//
//  SpotCardCollectionViewCell.swift
//  Pods
//
//  Created by Husein Kareem on 9/9/16.
//
//

import MapKit
import UIKit

protocol SpotCardCollectionViewDelegate: AnyObject {
    func didTapBuyButton(_ button: UIButton, cell: SpotCardCollectionViewCell)
    func didTapViewDetailsButton(_ button: UIButton, cell: SpotCardCollectionViewCell)
}

class SpotCardCollectionViewCell: UICollectionViewCell {
    weak var delegate: SpotCardCollectionViewDelegate?
    
    static let Identifier = "SpotCardCellID"
    static let ItemWidth: CGFloat = 275
    static let ItemHeight: CGFloat = 177
    static let ItemSpacing: CGFloat = 10
    static let DistanceFormatter: MKDistanceFormatter = {
        let formatter = MKDistanceFormatter()
        formatter.unitStyle = .abbreviated
        return formatter
    }()
    
    @IBOutlet private var buyButton: UIButton!
    @IBOutlet private var streetAddressLabel: UILabel!
    @IBOutlet private var distanceLabel: UILabel!
    @IBOutlet private var viewDetailsButton: UIButton!
    @IBOutlet private var priceLabel: UILabel!
    @IBOutlet private var spotImageView: UIImageView!
    @IBOutlet private var amenityView: AmenityView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.setupViews()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        self.amenityView.removeAllAmenities()
    }
    
    private func setupViews() {
        self.layer.cornerRadius = HeightsAndWidths.standardCornerRadius
        self.backgroundColor = .white
        
        self.buyButton.setTitle(LocalizedStrings.BookSpot, for: .normal)
        self.buyButton.setTitleColor(.shp_link, for: .normal)
        self.buyButton.titleLabel?.font = .shp_link
        
        self.viewDetailsButton.setTitleColor(.shp_link, for: .normal)
        self.viewDetailsButton.titleLabel?.font = .shp_link
        self.viewDetailsButton.setTitle(LocalizedStrings.ViewDetails, for: .normal)
        self.amenityView.spacing = HeightsAndWidths.Margins.Standard
        // Non standard corner radius from designs
        self.spotImageView.layer.cornerRadius = 8
        self.spotImageView.clipsToBounds = true
    }
    
    func configure(facility: Facility) {
        self.streetAddressLabel.text = facility.streetAddress
        if let priceInPennies = facility.availableRates.first?.price {
            self.priceLabel.text = SHPNumberFormatter.dollarStringFromCents(priceInPennies)
        }
    
        self.distanceLabel.text = SpotCardCollectionViewCell.DistanceFormatter.string(fromDistance: CLLocationDistance(facility.distanceInMeters))
        
        self.setImage(facility: facility)
        
        if let rate = facility.availableRates.first {
            self.amenityView.configureWithRate(rate)
        }
    }
    
    private func setImage(facility: Facility) {
        guard let url = URL.shp_cloudinaryURL(withString: facility.defaultImageURL,
                                              width: Int(self.spotImageView.frame.width),
                                              height: Int(self.spotImageView.frame.height),
                                              scale: Int(UIScreen.main.scale)) else {
                                                return
        }
        
        self.spotImageView.shp_setImage(url: url)
    }
    
    @IBAction private func buyButtonTapped(_ button: UIButton) {
        self.delegate?.didTapBuyButton(button, cell: self)
    }
    
    @IBAction private func viewDetailsButtonTapped(_ button: UIButton) {
        self.delegate?.didTapViewDetailsButton(button, cell: self)
    }
}
