//
//  TimeSelectionView.swift
//  Pods
//
//  Created by Husein Kareem on 8/2/16.
//
//

import UIKit

protocol TimeSelectionViewDelegate: class {
    func didTapStartView(startDate: NSDate, endDate: NSDate)
    func didTapEndView(startDate: NSDate, endDate: NSDate)
    func timeSelectionViewShouldHide()
}

protocol ShowTimeSelectionViewDelegate: class {
    func timeSelectionViewShouldShow(show: Bool)
}

protocol StartEndDateDelegate: class {
    func didChangeStartEndDate(startDate startDate: NSDate, endDate: NSDate)
    func didSelectStartEndView()
}

class TimeSelectionView: UIView {
    
    @IBOutlet weak private var startDateLabel: UILabel!
    
    @IBOutlet weak private var startTimeTextField: UITextField!
    @IBOutlet weak private var endDateLabel: UILabel!
    @IBOutlet weak private var endTimeTextField: UITextField!
    @IBOutlet private var dateTimeLabels: [UILabel]!
    @IBOutlet weak private var startsView: UIView!
    @IBOutlet weak private var endsView: UIView!
    
    let startDatePicker = UIDatePicker()
    let endDatePicker = UIDatePicker()
    
    weak var delegate: TimeSelectionViewDelegate?
    weak var showTimeSelectionViewDelegate: ShowTimeSelectionViewDelegate?
    weak var startEndDateDelegate: StartEndDateDelegate?
    
    var startViewSelected = false {
        didSet {
            if (self.startViewSelected) {
                self.startTimeTextField.becomeFirstResponder()
            } else {
                self.startDateLabel.textColor = .blackColor()
                self.startTimeTextField.textColor = .blackColor()
            }
        }
    }
    var endViewSelected = false {
        didSet {
            if (self.endViewSelected) {
                self.endTimeTextField.becomeFirstResponder()
            } else {
                self.endDateLabel.textColor = .blackColor()
                self.endTimeTextField.textColor = .blackColor()
            }
        }
    }
    var startDate: NSDate = NSDate().shp_roundDateToNearestHalfHour(roundDown: true) {
        didSet {
            self.startDatePicker.date = self.startDate
            self.setDateTimeLabels(self.startDate, endDate: self.endDate)
            self.startEndDateDelegate?.didChangeStartEndDate(startDate: self.startDate, endDate: self.endDate)
            self.startTimeTextField.text = DateFormatter.TimeOnly.stringFromDate(self.startDate)
        }
    }
    var endDate: NSDate = NSDate().dateByAddingTimeInterval(Constants.SixHoursInSeconds).shp_roundDateToNearestHalfHour(roundDown: true) {
        didSet {
            self.endDatePicker.date = self.endDate
            self.setDateTimeLabels(self.startDate, endDate: self.endDate)
            self.startEndDateDelegate?.didChangeStartEndDate(startDate: self.startDate, endDate: self.endDate)
            self.endTimeTextField.text = DateFormatter.TimeOnly.stringFromDate(self.endDate)
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.setupTimeSelectionView()
    }
    
    private func setupTimeSelectionView() {
        self.startDate = NSDate().shp_roundDateToNearestHalfHour(roundDown: true)
        self.endDate = self.startDate.dateByAddingTimeInterval(Constants.SixHoursInSeconds)
        
        self.startDateLabel.accessibilityLabel = AccessibilityStrings.StartDateLabel
        self.endDateLabel.accessibilityLabel = AccessibilityStrings.EndDateLabel
        self.startTimeTextField.accessibilityLabel = AccessibilityStrings.StartTimeLabel
        self.endTimeTextField.accessibilityLabel = AccessibilityStrings.EndTimeLabel
        self.startsView.accessibilityLabel = AccessibilityStrings.StartsTimeSelectionView
        self.endsView.accessibilityLabel = AccessibilityStrings.EndsTimeSelectionView
        
        self.setupSelectionViews()
        self.setupDatePickers()
    }
    
    private func setupSelectionViews() {
        self.startTimeTextField.delegate = self
        self.endTimeTextField.delegate = self
    }
    
    private func setupDatePickers() {
        self.startDatePicker.minuteInterval = 30
        self.endDatePicker.minuteInterval = 30
        
        self.startDatePicker.addTarget(self, action: #selector(self.startDateChanged(_:)), forControlEvents: .ValueChanged)
        self.endDatePicker.addTarget(self, action: #selector(self.endDateChanged(_:)), forControlEvents: .ValueChanged)
        
        self.startTimeTextField.inputView = self.startDatePicker
        self.endTimeTextField.inputView = self.endDatePicker
        
        let toolbar = UIToolbar(frame: CGRect(x: 0, y: 0, width: self.frame.width, height: 44))
        let flexibleSpace = UIBarButtonItem(barButtonSystemItem: .FlexibleSpace, target: nil, action: nil)
        let doneButton = UIBarButtonItem(barButtonSystemItem: .Done, target: self, action: #selector(self.doneButtonPressed))
        toolbar.items = [flexibleSpace, doneButton]
        toolbar.backgroundColor = .whiteColor()
        
        self.startTimeTextField.inputAccessoryView = toolbar
        self.endTimeTextField.inputAccessoryView = toolbar
    }
    
    private func setDateTimeLabels(startDate: NSDate, endDate: NSDate) {
        for label in self.dateTimeLabels {
            if (label == self.startDateLabel) {
                label.text = DateFormatter.PrettyMonthDayDate.stringFromDate(self.startDate)
            } else if (label == self.endDateLabel) {
                label.text = DateFormatter.PrettyMonthDayDate.stringFromDate(self.endDate)
            }
        }
    }
    
    /**
     Deselect both time selection views
     */
    func deselect() {
        self.startViewSelected = false
        self.endViewSelected = false
    }
    
    /**
     Show or hide time selection view
     
     - parameter show: pass in true to show, false to hide
     */
    func showTimeSelectionView(show: Bool) {
        self.hidden = !show
        self.showTimeSelectionViewDelegate?.timeSelectionViewShouldShow(show)
        if self.hidden {
            self.startTimeTextField.resignFirstResponder()
            self.endTimeTextField.resignFirstResponder()
        }
    }
    
    private func setStartEndDateTimeLabelWithDate(date: NSDate) {
        if (self.startViewSelected) {
            self.startDate = date
            if (self.endDate.timeIntervalSinceDate(date) < Constants.ThirtyMinutesInSeconds) {
                self.endDate = date.dateByAddingTimeInterval(Constants.SixHoursInSeconds).shp_roundDateToNearestHalfHour(roundDown: true)
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
    
    func doneButtonPressed() {
        self.startTimeTextField.resignFirstResponder()
        self.endTimeTextField.resignFirstResponder()
    }
    
    func startDateChanged(datePicker: UIDatePicker) {
        self.startDate = datePicker.date
    }
    
    func endDateChanged(datePicker: UIDatePicker) {
        self.endDate = datePicker.date
    }
    
    // Helpers
    
    private func selectStartView() {
        self.startDateLabel.textColor = .shp_spotHeroBlue()
        self.startTimeTextField.textColor = .shp_spotHeroBlue()
        self.endViewSelected = false
        self.startEndDateDelegate?.didSelectStartEndView()
    }
    
    private func selectEndView() {
        self.endDateLabel.textColor = .shp_spotHeroBlue()
        self.endTimeTextField.textColor = .shp_spotHeroBlue()
        self.startViewSelected = false
        self.startEndDateDelegate?.didSelectStartEndView()
    }
}

//MARK: UITextFieldDelegate

extension TimeSelectionView: UITextFieldDelegate {
    func textFieldDidBeginEditing(textField: UITextField) {
        switch textField {
        case self.startTimeTextField:
            self.selectStartView()
            self.startDatePicker.minimumDate = NSDate().shp_roundDateToNearestHalfHour(roundDown: true)
        case self.endTimeTextField:
            self.selectEndView()
            self.endDatePicker.minimumDate = self.startDate.shp_roundDateToNearestHalfHour(roundDown: false)
        default:
            break
        }
    }
}
