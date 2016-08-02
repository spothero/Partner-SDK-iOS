//
//  ReservationInfoTableViewCell.swift
//  Pods
//
//  Created by Matthew Reed on 7/27/16.
//
//

import UIKit

class ReservationInfoTableViewCell: UITableViewCell {
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var primaryLabel: UILabel!
    @IBOutlet weak var secondaryLabel: UILabel!
    
    static let reuseIdentifier = "reservationInfoCell"
    
    func configureCell(row: ReservationInfoRow, facility: Facility, rate: Rate) {
        self.titleLabel.text = row.title()
        
        switch row {
        case ReservationInfoRow.Address:
            self.primaryLabel.text = facility.streetAddress
            self.secondaryLabel.text = "\(facility.city), \(facility.state)"
        case ReservationInfoRow.Starts:
            self.primaryLabel.text = "\(DateFormatter.RelativeDate.stringFromDate(rate.starts)), \(DateFormatter.DateOnlyNoYear.stringFromDate(rate.starts))"
            self.secondaryLabel.text = DateFormatter.TimeOnly.stringFromDate(rate.starts)
        case ReservationInfoRow.Ends:
            self.primaryLabel.text = "\(DateFormatter.RelativeDate.stringFromDate(rate.ends)), \(DateFormatter.DateOnlyNoYear.stringFromDate(rate.ends))"
            self.secondaryLabel.text = DateFormatter.TimeOnly.stringFromDate(rate.ends)
        }
    }
}
