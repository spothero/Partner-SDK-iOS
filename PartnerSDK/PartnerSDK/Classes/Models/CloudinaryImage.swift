//
//  CloudinaryImage.swift
//  SpotHero_iOS_Partner_SDK
//
//  Created by Matthew Reed on 1/29/18.
//

import Foundation

struct CloudinaryImage {
    let centerX: Double
    let centerY: Double
    let version: String
    let id: String
    let order: Int
}

extension CloudinaryImage {
    init(json: JSONDictionary) throws {
        self.centerX = try json.shp_double("center_x")
        self.centerY = try json.shp_double("center_y")
        self.version = try json.shp_string("version")
        self.id = try json.shp_string("id")
        self.order = try json.shp_int("order")
    }
}
