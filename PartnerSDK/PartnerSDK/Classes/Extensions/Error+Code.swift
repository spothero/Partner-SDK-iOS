//
//  Error+Code.swift
//  SpotHero_iOS_Partner_SDK
//
//  Created by Reed.Hogan on 5/20/19.
//  Copyright © 2019 SpotHero, Inc. All rights reserved.
//

import Foundation

extension Error {
    var code: Int {
        return (self as NSError).code
    }
}
