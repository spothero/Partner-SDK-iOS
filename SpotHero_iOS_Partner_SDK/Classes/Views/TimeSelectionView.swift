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

protocol StartEndDateDelegate {
    func didChangeStartEndDate(startDate startDate: NSDate, endDate: NSDate)
    func didSelectStartEndView()
}

class TimeSelectionView: UIView {
    
    @IBOutlet weak private var startDateLabel: UILabel!
    @IBOutlet weak private var startTimeLabel: UILabel!
    @IBOutlet weak private var endDateLabel: UILabel!
    @IBOutlet weak private var endTimeLabel: UILabel!
    @IBOutlet private var dateTimeLabels: [UILabel]!
    @IBOutlet weak private var startsView: UIView!
    @IBOutlet weak private var endsView: UIView!
    
    var delegate: TimeSelectionViewDelegate?
    var showTimeSelectionViewDelegate: ShowTimeSelectionViewDelegate?
    var startEndDateDelegate: StartEndDateDelegate?
    
    var startViewSelected = false {
        didSet {
            if (self.startViewSelected) {
                self.startDateLabel.textColor = .shp_spotHeroBlue()
                self.startTimeLabel.textColor = .shp_spotHeroBlue()
                self.endViewSelected = false
                self.startEndDateDelegate?.didSelectStartEndView()
            } else {
                self.startDateLabel.textColor = .blackColor()
                self.startTimeLabel.textColor = .blackColor()
            }
        }
    }
    var endViewSelected = false {
        didSet {
            if (self.endViewSelected) {
                self.endDateLabel.textColor = .shp_spotHeroBlue()
                self.endTimeLabel.textColor = .shp_spotHeroBlue()
                self.startViewSelected = false
                self.startEndDateDelegate?.didSelectStartEndView()
            } else {
                self.endDateLabel.textColor = .blackColor()
                self.endTimeLabel.textColor = .blackColor()
            }
        }
    }
    private var startDate: NSDate = NSDate().shp_roundDateToNearestHalfHour(roundDown: true) {
        didSet {
            self.setDateTimeLabels(self.startDate, endDate: self.endDate)
            self.startEndDateDelegate?.didChangeStartEndDate(startDate: self.startDate, endDate: self.endDate)
        }
    }
    private var endDate: NSDate = NSDate().dateByAddingTimeInterval(Constants.SixHoursInSeconds).shp_roundDateToNearestHalfHour(roundDown: true) {
        didSet {
            self.setDateTimeLabels(self.startDate, endDate: self.endDate)
            self.startEndDateDelegate?.didChangeStartEndDate(startDate: self.startDate, endDate: self.endDate)
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.setupTimeSelectionView()
    }
    
    private func setupTimeSelectionView() {
        self.startDate = NSDate().shp_roundDateToNearestHalfHour(roundDown: true)
        self.endDate = NSDate().dateByAddingTimeInterval(Constants.SixHoursInSeconds).shp_roundDateToNearestHalfHour(roundDown: true)
        
        self.startDateLabel.accessibilityLabel = AccessibilityStrings.StartDateLabel
        self.endDateLabel.accessibilityLabel = AccessibilityStrings.EndDateLabel
        self.startTimeLabel.accessibilityLabel = AccessibilityStrings.StartTimeLabel
        self.endTimeLabel.accessibilityLabel = AccessibilityStrings.EndTimeLabel
        self.startsView.accessibilityLabel = AccessibilityStrings.StartsTimeSelectionView
        self.endsView.accessibilityLabel = AccessibilityStrings.EndsTimeSelectionView
    }
    
    private func setDateTimeLabels(startDate: NSDate, endDate: NSDate) {
        for label in self.dateTimeLabels {
            if (label == self.startDateLabel) {
                label.text = DateFormatter.PrettyMonthDayDate.stringFromDate(self.startDate)
            } else if (label == self.startTimeLabel) {
                label.text = DateFormatter.TimeOnly.stringFromDate(self.startDate)
            } else if (label == self.endDateLabel) {
                label.text = DateFormatter.PrettyMonthDayDate.stringFromDate(self.endDate)
            } else if (label == self.endTimeLabel) {
                label.text = DateFormatter.TimeOnly.stringFromDate(self.endDate)
            }
        }
    }
    
    /**
     Show or hide time selection view
     
     - parameter show: pass in true to show, false to hide
     */
    func showTimeSelectionView(show: Bool) {
        self.hidden = !show
        self.showTimeSelectionViewDelegate?.timeSelectionViewShouldShow(show)
        if self.hidden {
            self.delegate?.timeSelectionViewShouldHide()
        }
    }
    
    private func setStartEndDateTimeLabelWithDate(date: NSDate) {
        if (self.startViewSelected) {
            self.startDate = date
            if (self.endDate.timeIntervalSinceDate(date) < Constants.ThirtyMinutesInSeconds) {
                self.endDate = date.shp_roundDateToNearestHalfHour(roundDown: false)
            }
        } else if (self.endViewSelected) {
            self.endDate = date
        }
    }
    
    //MARK: Actions
    
    @IBAction private func startViewTapped(sender: AnyObject) {
        self.startViewSelected = true
        self.delegate?.didTapStartView(self.startDate, endDate: self.endDate)
    }
    
    @IBAction private func endViewTapped(sender: AnyObject) {
        self.endViewSelected = true
        self.delegate?.didTapEndView(self.startDate, endDate: self.endDate)
    }
    
}

//MARK: DatePickerViewDelegate

extension TimeSelectionView: DatePickerViewDelegate {
    func didPressDoneButton() {
        self.startViewSelected = false
        self.endViewSelected = false
    }
    
    func didChangeDatePickerValue(date: NSDate) {
        self.setStartEndDateTimeLabelWithDate(date)
    }
}
