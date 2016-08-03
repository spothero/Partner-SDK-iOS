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
    
    @IBOutlet weak private var startDateLabel: UILabel!
    @IBOutlet weak private var startTimeLabel: UILabel!
    @IBOutlet weak private var endDateLabel: UILabel!
    @IBOutlet weak private var endTimeLabel: UILabel!
    
    var delegate: TimeSelectionViewDelegate?
    var showTimeSelectionViewDelegate: ShowTimeSelectionViewDelegate?
    
    private var isStartView = false
    private let thirtyMins: NSTimeInterval = 1800
    private var startDate: NSDate = NSDate.dateByRoundingMinutesDownBy30(NSDate())
    private var endDate: NSDate = NSDate.dateByRoundingMinutesUpBy30(NSDate.dateByRoundingMinutesDownBy30(NSDate()))
    
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
            if (self.isStartView) {
                self.startDateLabel.textColor = UIColor.shp_spotHeroBlue()
                self.startTimeLabel.textColor = UIColor.shp_spotHeroBlue()
                self.endDateLabel.textColor = UIColor.blackColor()
                self.endTimeLabel.textColor = UIColor.blackColor()
            } else {
                self.endDateLabel.textColor = UIColor.shp_spotHeroBlue()
                self.endTimeLabel.textColor = UIColor.shp_spotHeroBlue()
                self.startDateLabel.textColor = UIColor.blackColor()
                self.startTimeLabel.textColor = UIColor.blackColor()
            }
        } else {
            self.startDateLabel.textColor = UIColor.blackColor()
            self.startTimeLabel.textColor = UIColor.blackColor()
            self.endDateLabel.textColor = UIColor.blackColor()
            self.endTimeLabel.textColor = UIColor.blackColor()
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
                self.endDate = NSDate.dateByRoundingMinutesUpBy30(date)
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
        self.startDateLabel.text = startDateLabelText
        self.startTimeLabel.text = startTimeLabelText
        self.endDateLabel.text = endDateLabelText
        self.endTimeLabel.text = endTimeLabelText
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
