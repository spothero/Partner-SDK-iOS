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
    @IBOutlet private var dateTimeLabels: [UILabel]!
    
    var delegate: TimeSelectionViewDelegate?
    var showTimeSelectionViewDelegate: ShowTimeSelectionViewDelegate?
    
    private var isStartView = false
    private let thirtyMinsInSeconds: NSTimeInterval = 1800
    private var startDate: NSDate = NSDate().shp_dateByRoundingMinutesBy30(roundDown: true) {
        didSet {
            self.setDateTimeLabels(self.startDate, endDate: self.endDate)
        }
    }
    
    private var endDate: NSDate = NSDate().shp_dateByRoundingMinutesBy30(roundDown: false) {
        didSet {
            self.setDateTimeLabels(self.startDate, endDate: self.endDate)
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.setupTimeSelectionView()
    }
    
    private func setupTimeSelectionView() {
        self.startDate = NSDate().shp_dateByRoundingMinutesBy30(roundDown: true)
        self.endDate = NSDate().shp_dateByRoundingMinutesBy30(roundDown: false)
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
    
    /**
     Sets the start and end view selected state
     
     - parameter selected: pass in true to show selected state, false to show unselected state
     */
    func startEndViewSelected(selected: Bool) {
        if selected {
            if (self.isStartView) {
                self.startDateLabel.textColor = .shp_spotHeroBlue()
                self.startTimeLabel.textColor = .shp_spotHeroBlue()
                self.endDateLabel.textColor = .blackColor()
                self.endTimeLabel.textColor = .blackColor()
            } else {
                self.startDateLabel.textColor = .blackColor()
                self.startTimeLabel.textColor = .blackColor()
                self.endDateLabel.textColor = .shp_spotHeroBlue()
                self.endTimeLabel.textColor = .shp_spotHeroBlue()
            }
        } else {
            self.dateTimeLabels.forEach { $0.textColor = .blackColor() }
        }
    }
    
    /**
     Sets the start and end date time labels
     
     - parameter date: pass in date to display on label
     */
    func setStartEndDateTimeLabelWithDate(date: NSDate) {
        if (self.isStartView) {
            self.startDate = date
            if (self.endDate.timeIntervalSinceDate(date) < self.thirtyMinsInSeconds) {
                self.endDate = date.shp_dateByRoundingMinutesBy30(roundDown: false)
            }
        } else {
            self.endDate = date
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
