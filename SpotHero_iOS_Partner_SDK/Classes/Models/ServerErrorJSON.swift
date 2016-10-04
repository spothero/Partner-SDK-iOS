//
//  ServerErrorJSON.swift
//  Pods
//
//  Created by Ellen Shapiro (Work) on 6/29/16.
//
//

import Foundation

struct ServerErrorJSON {
    let code: String
    let messages: [String]
}

extension ServerErrorJSON: JSONParseable {
    init(json: JSONDictionary) throws {
        self.code = try json.shp_string("code")
        self.messages =  try json.shp_array("messages")
    }
}
