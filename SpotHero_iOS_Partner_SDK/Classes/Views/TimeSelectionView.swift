//
//  TimeSelectionView.swift
//  Pods
//
//  Created by Husein Kareem on 8/2/16.
//
//

import UIKit

protocol TimeSelectionViewDelegate: class {
    func didTapStartView(_ startDate: Date, endDate: Date)
    func didTapEndView(_ startDate: Date, endDate: Date)
    func timeSelectionViewShouldHide()
}

protocol ShowTimeSelectionViewDelegate: class {
    func timeSelectionViewShouldShow(_ show: Bool)
    func didPressEndDoneButton()
}

protocol StartEndDateDelegate: class {
    func didChangeStartEndDate(startDate: Date, endDate: Date)
    func didSelectStartEndView()
}

class TimeSelectionView: UIView {
    
    @IBOutlet weak private var startDateLabel: UILabel!
    
    @IBOutlet weak fileprivate var startTimeTextField: UITextField!
    @IBOutlet weak private var endDateLabel: UILabel!
    @IBOutlet weak fileprivate var endTimeTextField: UITextField!
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
            if self.startViewSelected {
                self.startTimeTextField.becomeFirstResponder()
            } else {
                self.startDateLabel.textColor = .black
                self.startTimeTextField.textColor = .black
            }
        }
    }
    var endViewSelected = false {
        didSet {
            if self.endViewSelected {
                self.endTimeTextField.becomeFirstResponder()
            } else {
                self.endDateLabel.textColor = .black
                self.endTimeTextField.textColor = .black
            }
        }
    }
    var startDate: Date = Date().shp_roundDateToNearestHalfHour(roundDown: true) {
        didSet {
            self.startDatePicker.date = self.startDate
            self.setDateTimeLabels(self.startDate, endDate: self.endDate)
            self.startEndDateDelegate?.didChangeStartEndDate(startDate: self.startDate, endDate: self.endDate)
            self.startTimeTextField.text = SHPDateFormatter.TimeOnly.string(from: self.startDate)
        }
    }
    var endDate: Date = Date().addingTimeInterval(Constants.SixHoursInSeconds).shp_roundDateToNearestHalfHour(roundDown: true) {
        didSet {
            self.endDatePicker.date = self.endDate
            self.setDateTimeLabels(self.startDate, endDate: self.endDate)
            self.startEndDateDelegate?.didChangeStartEndDate(startDate: self.startDate, endDate: self.endDate)
            self.endTimeTextField.text = SHPDateFormatter.TimeOnly.string(from: self.endDate)
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.setupTimeSelectionView()
    }
    
    private func setupTimeSelectionView() {
        self.startDate = Date().shp_roundDateToNearestHalfHour(roundDown: true)
        self.endDate = self.startDate.addingTimeInterval(Constants.SixHoursInSeconds)
        
        self.startDateLabel.accessibilityLabel = AccessibilityStrings.StartDateLabel
        self.endDateLabel.accessibilityLabel = AccessibilityStrings.EndDateLabel
        self.startTimeTextField.accessibilityLabel = AccessibilityStrings.StartTimeTextField
        self.endTimeTextField.accessibilityLabel = AccessibilityStrings.EndTimeTextField
        self.startsView.accessibilityLabel = AccessibilityStrings.StartsTimeSelectionView
        self.endsView.accessibilityLabel = AccessibilityStrings.EndsTimeSelectionView
        
        self.startDatePicker.accessibilityLabel = AccessibilityStrings.StartDatePicker
        self.endDatePicker.accessibilityLabel = AccessibilityStrings.EndDatePicker
        
        self.startTimeTextField.delegate = self
        self.endTimeTextField.delegate = self
        
        self.setupDatePickers()
    }
    
    private func setupDatePickers() {
        self.startDatePicker.minuteInterval = 30
        self.endDatePicker.minuteInterval = 30
        
        self.startDatePicker.backgroundColor = .white
        self.endDatePicker.backgroundColor = .white
        
        self.startDatePicker.addTarget(self, action: #selector(self.startDateChanged(_:)), for: .valueChanged)
        self.endDatePicker.addTarget(self, action: #selector(self.endDateChanged(_:)), for: .valueChanged)
        
        self.startTimeTextField.inputView = self.startDatePicker
        self.endTimeTextField.inputView = self.endDatePicker
        
        let startToolbar = UIToolbar(frame: CGRect(x: 0, y: 0, width: self.frame.width, height: 44))
        let flexibleSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let startDoneButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(self.startDoneButtonPressed))
        let startToolbarLabel = UILabel()
        startToolbarLabel.text = LocalizedStrings.SetStartTime
        startToolbarLabel.sizeToFit()
        let startLabelBarButtonItem = UIBarButtonItem(customView: startToolbarLabel)
        startToolbar.items = [flexibleSpace, startLabelBarButtonItem, flexibleSpace, startDoneButton]
        
        let endToolbar = UIToolbar(frame: CGRect(x: 0, y: 0, width: self.frame.width, height: 44))
        let endDoneButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(self.endDoneButtonPressed))
        let endToolbarLabel = UILabel()
        endToolbarLabel.text = LocalizedStrings.SetEndTime
        endToolbarLabel.sizeToFit()
        let endLabelBarButtonItem = UIBarButtonItem(customView: endToolbarLabel)
        endToolbar.items = [flexibleSpace, endLabelBarButtonItem, flexibleSpace, endDoneButton]
        
        self.startTimeTextField.inputAccessoryView = startToolbar
        self.endTimeTextField.inputAccessoryView = endToolbar
    }
    
    private func setDateTimeLabels(_ startDate: Date, endDate: Date) {
        for label in self.dateTimeLabels {
            if label == self.startDateLabel {
                label.text = SHPDateFormatter.PrettyMonthDayDate.string(from: self.startDate)
            } else if label == self.endDateLabel {
                label.text = SHPDateFormatter.PrettyMonthDayDate.string(from: self.endDate)
            }
        }
    }
    
    /**
     Deselect both time selection views
     */
    func deselect() {
        self.deselectStartView()
        self.deselectEndView()
    }
    
    /**
     Deselect start time selection view
     */
    func deselectStartView() {
        self.startViewSelected = false
        self.startTimeTextField.resignFirstResponder()
    }
    
    /**
     Deselect end time selection view
     */
    func deselectEndView() {
        self.endViewSelected = false
        self.endTimeTextField.resignFirstResponder()
    }
    
    /**
     Show or hide time selection view
     
     - parameter show: pass in true to show, false to hide
     */
    func showTimeSelectionView(_ show: Bool) {
        self.isHidden = !show
        self.showTimeSelectionViewDelegate?.timeSelectionViewShouldShow(show)
        if self.isHidden {
            self.startTimeTextField.resignFirstResponder()
            self.endTimeTextField.resignFirstResponder()
        }
    }
    
    func setStartEndDateTimeLabelWithDate(_ date: Date) {
        if self.startViewSelected {
            self.startDate = date
            if self.endDate.timeIntervalSince(date) < Constants.ThirtyMinutesInSeconds {
                self.endDate = date.addingTimeInterval(Constants.SixHoursInSeconds).shp_roundDateToNearestHalfHour(roundDown: true)
            }
        } else if self.endViewSelected {
            self.endDate = date
        }
    }
    
    //MARK: Actions
    
    @IBAction private func startViewTapped(_ sender: AnyObject) {
        self.startViewSelected = true
        self.delegate?.didTapStartView(self.startDate, endDate: self.endDate)
    }
    
    @IBAction private func endViewTapped(_ sender: AnyObject) {
        self.endViewSelected = true
        self.delegate?.didTapEndView(self.startDate, endDate: self.endDate)
    }
    
    @objc private func startDoneButtonPressed() {
        self.startTimeTextField.resignFirstResponder()
    }
    
    @objc private func endDoneButtonPressed() {
        self.endTimeTextField.resignFirstResponder()
        self.showTimeSelectionViewDelegate?.didPressEndDoneButton()
    }
    
    @objc private func startDateChanged(_ datePicker: UIDatePicker) {
        self.setStartEndDateTimeLabelWithDate(datePicker.date)
    }
    
    @objc private func endDateChanged(_ datePicker: UIDatePicker) {
        self.setStartEndDateTimeLabelWithDate(datePicker.date)
    }
    
    //MARK: Helpers
    
    fileprivate func selectStartView() {
        self.endViewSelected = false
        self.startEndDateDelegate?.didSelectStartEndView()
    }
    
    fileprivate func selectEndView() {
        self.startViewSelected = false
        self.startEndDateDelegate?.didSelectStartEndView()
    }
    
    fileprivate func updateMinimumDateIfNeeded() {
        if let minimumDate = self.startDatePicker.minimumDate, self.startDate.compare(minimumDate) == .orderedAscending {
            self.startDate = minimumDate
        }
    }
}

//MARK: UITextFieldDelegate

extension TimeSelectionView: UITextFieldDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField) {
        switch textField {
        case self.startTimeTextField:
            self.selectStartView()
            self.startDatePicker.minimumDate = Date().shp_roundDateToNearestHalfHour(roundDown: true)
            self.updateMinimumDateIfNeeded()
        case self.endTimeTextField:
            self.selectEndView()
            self.endDatePicker.minimumDate = self.startDate.shp_roundDateToNearestHalfHour(roundDown: false)
        default:
            break
        }
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        switch textField {
        case self.startTimeTextField:
            self.endTimeTextField.becomeFirstResponder()
        default:
            self.deselectEndView()
        }
    }
}
