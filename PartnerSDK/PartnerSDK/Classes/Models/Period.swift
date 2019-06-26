//
//  Period.swift
//  SpotHero_iOS_Partner_SDK
//
//  Created by Matthew Reed on 1/22/18.
//

import Foundation

struct Period {
    let startDayOfWeekInt: Int
    let startDayOfWeek: String
    let startTime: Date?
    let type: String
    let endDayOfWeekInt: Int
    let endDayOfWeek: String
    let endTime: Date?
    
    //swiftlint:disable identifier_name
    fileprivate enum JSONKey: String {
        case
        start_dow_int,
        start_dow,
        start_time,
        hours_type,
        end_dow,
        end_dow_int,
        end_time
    }
    //swiftlint:enable identifier_name
}

extension Period {
    init(json: JSONDictionary) throws {
        self.startDayOfWeekInt = try json.shp_int(JSONKey.start_dow_int.rawValue)
        self.startDayOfWeek = try json.shp_string(JSONKey.start_dow.rawValue)
        let startTimeString = try json.shp_string(JSONKey.start_time.rawValue)
        self.startTime = SHPDateFormatter.APITime.date(from: startTimeString)
        self.type = try json.shp_string(JSONKey.hours_type.rawValue)
        self.endDayOfWeekInt = try json.shp_int(JSONKey.end_dow_int.rawValue)
        self.endDayOfWeek = try json.shp_string(JSONKey.end_dow.rawValue)
        let endTimeString = try json.shp_string(JSONKey.end_time.rawValue)
        self.endTime = SHPDateFormatter.APITime.date(from: endTimeString)
    }
}
