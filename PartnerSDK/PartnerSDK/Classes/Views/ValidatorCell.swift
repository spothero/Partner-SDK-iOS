//
//  ValidatorCell.swift
//  Pods
//
//  Created by SpotHeroMatt on 8/12/16.
//  Copyright © 2016 SpotHero. All rights reserved.
//

import Foundation

protocol ValidatorCell: AnyObject {
    var valid: Bool { get }
    var delegate: ValidatorCellDelegate? { get set }
}

protocol ValidatorCellDelegate: AnyObject {
    func didValidateText()
}
