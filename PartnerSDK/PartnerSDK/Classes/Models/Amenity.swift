//
//  Amenity.swift
//  SpotHero_iOS_Partner_SDK
//
//  Created by Matthew Reed on 12/22/17.
//

import Foundation

struct Amenity {
    let name: String
    let slug: String
    let visible: Bool
}

extension Amenity {
    init(json: JSONDictionary) throws {
        self.name = try json.shp_string("name")
        self.slug = try json.shp_string("slug")
        self.visible = try json.shp_bool("visible")
    }
}
