//
//  StringEnum.swift
//  Pods
//
//  Created by Matthew Reed on 7/22/16.
//
//

import Foundation

protocol StringEnum {
    
    init?(rawValue: String)
    
    var rawValue: String { get }
}
