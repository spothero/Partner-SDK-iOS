//
//  HoursOfOperation.swift
//  SpotHero_iOS_Partner_SDK
//
//  Created by Matthew Reed on 1/22/18.
//

import Foundation

struct HoursOfOperation {
    let text: [String]
    let periods: [Period]
    
    fileprivate enum JSONKey: String {
        case
        text,
        periods
    }
}

extension HoursOfOperation {
    init(json: JSONDictionary) throws {
        self.text = try json.shp_array(JSONKey.text.rawValue)
        let periodsArray: [JSONDictionary] = try json.shp_array(JSONKey.periods.rawValue)
        self.periods = try periodsArray.map { try Period(json: $0) }
    }
}
