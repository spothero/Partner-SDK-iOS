//
//  ValidatorCell.swift
//  Pods
//
//  Created by SpotHeroMatt on 8/12/16.
//  Copyright © 2016 SpotHero. All rights reserved.
//

import Foundation

protocol ValidatorCell: class {
    var valid: Bool { get }
    weak var delegate: ValidatorCellDelegate? { get set }
}

protocol ValidatorCellDelegate: class {
    func didValidateText()
}
