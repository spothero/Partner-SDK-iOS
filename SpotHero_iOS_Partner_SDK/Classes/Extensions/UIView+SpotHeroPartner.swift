//
//  UIView+SpotHeroPartner.swift
//  SpotHero_iOS_Partner_SDK
//
//  Created by Matthew Reed on 1/9/18.
//

import Foundation

extension UIView {
    /// Add a drop shadow to this view's layer
    ///
    /// - Parameters:
    ///   - color: Shadow color, defaults to black
    ///   - opacity: Shadow opacity, default of HeightsAndWidths.Shadow.Opacity.Standard
    ///   - offset: Shadow offset, defaults to zero meaning drop shadow in all directions
    ///   - radius: Shadow radius, defaults to HeightsAndWidths.Shadow.Radius.Standard
    func shp_addShadow(color: UIColor = .black,
                       opacity: Float = HeightsAndWidths.Shadow.Opacity.Standard,
                       offset: CGSize = .zero,
                       radius: CGFloat = HeightsAndWidths.Shadow.Radius.Standard) {
        let layer = self.layer
        let shadowPath = UIBezierPath(rect: self.bounds)
        layer.shadowPath = shadowPath.cgPath
        layer.masksToBounds = false
        layer.shadowColor = color.cgColor
        layer.shadowOpacity = opacity
        layer.shadowOffset = offset
        layer.shadowRadius = radius
    }
}
