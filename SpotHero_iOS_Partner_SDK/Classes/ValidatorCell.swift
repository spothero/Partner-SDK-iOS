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
    var delegate: ValidatorCellDelegate? { get set }
    func setErrorState(valid: Bool, error: ValidatorError?)
}

protocol ValidatorCellDelegate  {
    func didValidateText()
}
