//
//  URL+SpotHeroPartner.swift
//  SpotHero_iOS_Partner_SDK
//
//  Created by Matthew Reed on 12/22/17.
//

import Foundation

public extension URL {
    
    private enum Cloudinary: String {
        static let host = "res.cloudinary.com"
        static let imagePath = "image/upload"
        
        case
        fill = "c_fill",
        height = "h_",
        width = "w_",
        scale = "dpr_"
        
        func withValue(_ value: Int) -> String {
            return "\(self.rawValue)\(value)"
        }
    }
    
    /// Create a URL from a Cloudinary URL string, inserting width and height parameters.
    ///
    /// - parameter urlString: A Cloudinary URL string to modify
    /// - parameter width: The width of the requested image, in points
    /// - parameter height: The height of the requested image, in points
    /// - parameter scale: The points to pixels scale to use
    /// - parameter fill: [Optional] Whether to add an aspect fill parameter, defaults to false
    /// - returns: A URL for a image with width, height, and scale parameters
    static func shp_cloudinaryURL(withString urlString: String,
                                  width: Int,
                                  height: Int,
                                  scale: Int,
                                  fill: Bool = false) -> URL? {
        
        guard
            var components = URLComponents(string: urlString), components.host == Cloudinary.host else {
                assertionFailure("\(urlString) does not appear to be a Cloudinary URL")
                return URL(string: urlString)
        }
        
        assert(scale >= 1, "Scale must be at least 1!")
        
        // eg: http://res.cloudinary.com/spothero/image/upload/v1471462941/amenity_icons/in-out_ccmaiu.png
        // http -> https
        components.scheme = "https"
        
        var path = components.path
        
        //if the path already has params, remove them
        if path.contains(Cloudinary.width.rawValue) || path.contains(Cloudinary.width.rawValue) {
            let pathSeparator = "/"
            var components = path.components(separatedBy: pathSeparator)
            for (index, part) in components.enumerated() {
                if part.contains(Cloudinary.width.rawValue) || part.contains(Cloudinary.width.rawValue) {
                    components.remove(at: index)
                    break
                }
            }
            path = components.joined(separator: pathSeparator)
        }
        
        //only add width and height params if they're not already in the URL string
        if !(path.contains(Cloudinary.width.rawValue) && path.contains(Cloudinary.width.rawValue)) {
            // http://cloudinary.com/documentation/image_transformations#resizing_and_cropping_images
            
            var parameters: [String] = [
                Cloudinary.width.withValue(width),
                Cloudinary.height.withValue(height),
                Cloudinary.scale.withValue(scale),
                ]
            
            if fill {
                parameters.append(Cloudinary.fill.rawValue)
            }
            
            let widthAndHeight = parameters.joined(separator: ",")
            
            let widthAndHeightImagePath = "\(Cloudinary.imagePath)/\(widthAndHeight)"
            
            path = path.replacingOccurrences(of: Cloudinary.imagePath,
                                             with: widthAndHeightImagePath)
        }
        components.path = path
        return components.url
    }
    
    /// Returns a url from a cloudinary image
    ///
    /// - Parameters:
    ///   - id: Cloudinary image id
    ///   - width: Width for image [defaults to 0]
    ///   - height: Height for image [defaults to 0]
    ///   - centerX: CenterX from cloudinary image
    ///   - centerY: CenterY from cloudinary image
    ///   - version: Cloudinary image version
    /// - Returns: URL for image
    static func shp_cloudinaryURL(fromID imageID: String,
                                  width: Int = 0,
                                  height: Int = 0,
                                  centerX: Int,
                                  centerY: Int,
                                  scale: Int,
                                  version: String) -> URL? {
        var urlString = "https://res.cloudinary.com/spothero/image/upload/"
        
        if width > 0 {
            urlString.append("w_\(width),")
        }
        
        if height > 0 {
            urlString.append("h_\(height),")
        }
        
        urlString.append("c_fill,g_xy_center,x_\(centerX),y_\(centerY)/v\(version)/\(imageID)")
        return self.shp_cloudinaryURL(withString: urlString,
                                      width: width,
                                      height: height,
                                      scale: scale)
    }
    
    internal static func shp_cloudinaryURL(fromImage image: CloudinaryImage,
                                           width: Int,
                                           height: Int) -> URL? {
        return self.shp_cloudinaryURL(fromID: image.id,
                                      width: width,
                                      height: height,
                                      centerX: Int(image.centerX),
                                      centerY: Int(image.centerY),
                                      scale: Int(UIScreen.main.scale),
                                      version: image.version)
    }
}
