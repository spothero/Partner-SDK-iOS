//
//  ImageCollectionViewCell.swift
//  SpotHero_iOS_Partner_SDK
//
//  Created by Matthew Reed on 1/29/18.
//

import UIKit

class ImageCollectionViewCell: UICollectionViewCell {
    static let ReuseIdentifier = String(describing: ImageCollectionViewCell.self)
    @IBOutlet private var imageView: UIImageView!
    private var url: URL?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.imageView.layer.cornerRadius = HeightsAndWidths.standardCornerRadius
    }
    
    func configure(image: CloudinaryImage) {
        let newUrl = URL.shp_cloudinaryURL(fromImage: image,
                                         width: Int(self.bounds.width),
                                         height: Int(self.bounds.height))
        if let url = newUrl, self.url != newUrl {
            self.imageView.shp_setImage(url: url)
            self.url = url
        }
    }
}
