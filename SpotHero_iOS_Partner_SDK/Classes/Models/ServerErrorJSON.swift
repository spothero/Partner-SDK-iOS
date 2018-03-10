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
        let data = try json.shp_dictionary("data") as JSONDictionary
        let errors = try data.shp_array("errors") as [JSONDictionary]
        
        guard let error = errors.first else {
            throw JSONParsingError.noResults
        }
        
        self.code = try error.shp_string("code")
        self.messages = try error.shp_array("messages")
    }
}
