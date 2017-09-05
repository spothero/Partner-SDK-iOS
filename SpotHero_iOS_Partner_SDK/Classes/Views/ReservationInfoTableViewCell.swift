//
//  ReservationInfoTableViewCell.swift
//  Pods
//
//  Created by Matthew Reed on 7/27/16.
//
//

import UIKit

class ReservationInfoTableViewCell: UITableViewCell {
    @IBOutlet private(set) weak var titleLabel: UILabel!
    @IBOutlet private(set) weak var primaryLabel: UILabel!
    @IBOutlet private(set) weak var secondaryLabel: UILabel!
    
    static let reuseIdentifier = "reservationInfoCell"
}
