//
//  TimeSelectionView.swift
//  Pods
//
//  Created by Husein Kareem on 8/2/16.
//
//

import UIKit

protocol TimeSelectionViewDelegate {
    func didTapStartView(startDate: NSDate, endDate: NSDate)
    func didTapEndView(startDate: NSDate, endDate: NSDate)
    func timeSelectionViewShouldHide()
}

protocol ShowTimeSelectionViewDelegate {
    func timeSelectionViewShouldShow(show: Bool)
}

class TimeSelectionView: UIView {
    
    @IBOutlet private var dateTimeLabels: [UILabel]?
    
    var delegate: TimeSelectionViewDelegate?
    var showTimeSelectionViewDelegate: ShowTimeSelectionViewDelegate?
    
    private var isStartView = false
    private let thirtyMins: NSTimeInterval = 1800
    private var startDate: NSDate = NSDate().shp_dateByRoundingMinutesBy30(true)
    private var endDate: NSDate = NSDate().shp_dateByRoundingMinutesBy30(true).shp_dateByRoundingMinutesBy30(false)
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.setupTimeSelectionView()
    }
    
    private func setupTimeSelectionView() {
        self.setStartEndDateTimeLabels(startDateLabelText: DateFormatter.PrettyMonthDayDate.stringFromDate(self.startDate),
                                       startTimeLabelText: DateFormatter.TimeOnly.stringFromDate(self.startDate),
                                       endDateLabelText: DateFormatter.PrettyMonthDayDate.stringFromDate(self.endDate),
                                       endTimeLabelText: DateFormatter.TimeOnly.stringFromDate(self.endDate))
    }
    
    /**
     Show or hide time selection view
     
     - parameter show: pass in true to show, false to hide
     */
    func showTimeSelectionView(show: Bool) {
        self.hidden = !show
        self.showTimeSelectionViewDelegate?.timeSelectionViewShouldShow(show)
        if !show {
            self.delegate?.timeSelectionViewShouldHide()
        }
    }
    
    /**
     Sets the start and end view selected state
     
     - parameter selected: pass in true to show selected state, false to show unselected state
     */
    func startEndViewSelected(selected: Bool) {
        if selected {
            guard let dateTimeLabels = self.dateTimeLabels?.enumerate() else {
                return
            }
            if (self.isStartView) {
                for (i, label) in dateTimeLabels {
                    label.textColor = i < 2 ? UIColor.shp_spotHeroBlue() : UIColor.blackColor()
                }
            } else {
                for (i, label) in dateTimeLabels {
                    label.textColor = i >= 2 ? UIColor.shp_spotHeroBlue() : UIColor.blackColor()
                }
            }
        } else {
            self.dateTimeLabels?.forEach({ (label) in
                label.textColor = UIColor.blackColor()
            })
        }
    }
    
    /**
     Sets the start and end date time labels
     
     - parameter date: pass in date to display on label
     */
    func setStartEndDateTimeLabelWithDate(date: NSDate) {
        if (self.isStartView) {
            self.startDate = date
            if (self.endDate.timeIntervalSinceDate(date) < self.thirtyMins) {
                self.endDate = date.shp_dateByRoundingMinutesBy30(false)
            }
        } else {
            self.endDate = date
        }
        
        self.setStartEndDateTimeLabels(startDateLabelText: DateFormatter.PrettyMonthDayDate.stringFromDate(self.startDate),
                                       startTimeLabelText: DateFormatter.TimeOnly.stringFromDate(self.startDate),
                                       endDateLabelText: DateFormatter.PrettyMonthDayDate.stringFromDate(self.endDate),
                                       endTimeLabelText: DateFormatter.TimeOnly.stringFromDate(self.endDate))
    }
    
    private func setStartEndDateTimeLabels(startDateLabelText startDateLabelText: String,
                                                              startTimeLabelText: String,
                                                              endDateLabelText: String,
                                                              endTimeLabelText: String) {
        guard let dateTimeLabels = self.dateTimeLabels?.enumerate() else {
            return
        }
        for (i, label) in dateTimeLabels {
            switch i {
            case 0:
                label.text = startDateLabelText
            case 1:
                label.text = startTimeLabelText
            case 2:
                label.text = endDateLabelText
            case 3:
                label.text = endTimeLabelText
            default:
                assertionFailure("self.dateTimeLabels has more than 4 labels")
            }
        }
    }
    
    //MARK: Actions
    
    @IBAction private func startViewTapped(sender: AnyObject) {
        self.isStartView = true
        self.startEndViewSelected(true)
        self.delegate?.didTapStartView(self.startDate, endDate: self.endDate)
    }
    
    @IBAction private func endViewTapped(sender: AnyObject) {
        self.isStartView = false
        self.startEndViewSelected(true)
        self.delegate?.didTapEndView(self.startDate, endDate: self.endDate)
    }
    
}

//MARK: DatePickerViewDelegate

extension TimeSelectionView: DatePickerViewDelegate {
    func didPressDoneButton() {
        self.startEndViewSelected(false)
    }
    
    func didChangeDatePickerValue(date: NSDate) {
        self.setStartEndDateTimeLabelWithDate(date)
    }
}
