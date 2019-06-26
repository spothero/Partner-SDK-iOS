//
//  UIImageView+SpotHeroPartner.swift
//  SpotHero_iOS_Partner_SDK
//
//  Created by Matthew Reed on 12/22/17.
//

import UIKit

extension UIImageView {
    private struct AssociatedKey {
        static var activeDataTask = "shp_UIImageView.ActiveDataTask"
    }
    
    //swiftlint:disable:next identifier_name
    private var shp_activeDataTask: URLSessionDataTask? {
        get {
            return objc_getAssociatedObject(self, &AssociatedKey.activeDataTask) as? URLSessionDataTask
        }
        set {
            objc_setAssociatedObject(self, &AssociatedKey.activeDataTask, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    func shp_setImage(url: URL, placeholderImage: UIImage? = nil) {
        self.shp_cancelImageRequest()
        
        self.image = placeholderImage
        
        self.shp_activeDataTask = ImageCache.shared.fetch(url: url) { [weak self] image in
            self?.image = image
            self?.shp_activeDataTask = nil
        }
    }
    
    private func shp_cancelImageRequest() {
        guard let activeDataTask = self.shp_activeDataTask else {
            return
        }
        
        activeDataTask.cancel()
        
        self.shp_activeDataTask = nil
    }
}
