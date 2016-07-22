//
//  Constants.swift
//  Pods
//
//  Created by Husein Kareem on 7/13/16.
//
//

import Foundation
import CoreLocation

enum Constants {
    static let ChicagoLocation = CLLocation(latitude: 41.894503, longitude: -87.636659)
    static let dateFormatter: NSDateFormatter = {
        let _dateFormatter = NSDateFormatter()
        _dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm"
        return _dateFormatter
    }()
}
