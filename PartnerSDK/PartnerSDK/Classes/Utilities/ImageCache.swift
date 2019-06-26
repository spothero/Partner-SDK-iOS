//
//  ImageCache.swift
//  SpotHero_iOS_Partner_SDK
//
//  Created by Matthew Reed on 12/22/17.
//

import UIKit

class ImageCache {
    static let shared = ImageCache()
    
    typealias ImageCacheCompletion = (UIImage?) -> Void
    
    private let cache = NSCache<NSString, UIImage>()
    
    private let synchronizationQueue: DispatchQueue = {
        let name = String(format: "com.spothero.imagecache.synchronizationqueue-%08x%08x", arc4random(), arc4random())
        return DispatchQueue(label: name)
    }()
    
    func fetch(url: URL, completion: @escaping ImageCacheCompletion) -> URLSessionDataTask? {
        var dataTask: URLSessionDataTask?
        if let cachedImage = cache.object(forKey: url.absoluteString as NSString) {
            completion(cachedImage)
        } else {
            dataTask = URLSession.shared.dataTask(with: url) { data, _, _ in
                guard let data = data else {
                    DispatchQueue.main.async {
                        completion(nil)
                    }
                    return
                }
                
                let image = UIImage(data: data)
                DispatchQueue.main.async {
                    completion(image)
                }
            }
            dataTask?.resume()
        }
    
        return dataTask
    }
}
