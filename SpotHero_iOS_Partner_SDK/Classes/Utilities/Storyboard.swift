//
//  Storyboard.swift
//  SpotHero_iOS_Partner_SDK
//
//  Created by Matthew Reed on 12/25/17.
//

import UIKit

enum Storyboard: String {
    case main = "Main"
    
    func viewController<T>(from identifier: String) -> T {
        let storyboard = UIStoryboard(name: self.rawValue, bundle: Bundle.shp_resourceBundle())
        let vc = storyboard.instantiateViewController(withIdentifier: identifier)
        
        guard let typedVC = vc as? T else {
            fatalError("The view controller with identifier \(identifier) in storyboard \(self.rawValue) was not of type \(T.self)")
        }
        
        return typedVC
    }
}
