//
//  DateInputView.swift
//  SpotHero_iOS_Partner_SDK
//
//  Created by Matthew Reed on 12/19/17.
//

import UIKit

protocol DateInputViewDelegate: class {
    func didTapButton(input: DateInputView)
    func didUpdateDate(input: DateInputView)
}

class DateInputView: TextInputView {
    private let datePicker = UIDatePicker()
    private let toolbar = UIToolbar()
    private let toolbarLabel = UILabel()
    private let toolbarButton = LinkBarButtonItem()
    weak var dateDelegate: DateInputViewDelegate?
    private var formatter = SHPDateFormatter.PrettyDayDateTime
    
    var timeZone: TimeZone? {
        get {
            return self.datePicker.timeZone
        }
        set {
            self.datePicker.timeZone = newValue
            self.formatter.timeZone = newValue
        }
    }
    
    var date: Date {
        return self.datePicker.date
    }
    
    var minimumDate: Date? {
        get {
            return self.datePicker.minimumDate
        }
        set {
            self.datePicker.minimumDate = newValue
            self.setDate()
        }
    }
    
    override func setupViews() {
        super.setupViews()
        self.datePicker.backgroundColor = .white
        self.textField.inputView = self.datePicker
        self.textField.inputAccessoryView = self.toolbar
        self.textField.tintColor = .clear
        self.toolbar.translatesAutoresizingMaskIntoConstraints = false
        self.toolbar.heightAnchor.constraint(equalToConstant: 44)
        self.toolbarLabel.font = .shp_subhead
        self.toolbarLabel.textColor = .shp_primary
        let titleBarButtonItem = UIBarButtonItem(customView: self.toolbarLabel)
        let flexibleSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        self.toolbar.items = [titleBarButtonItem, flexibleSpace, toolbarButton]
        self.toolbarButton.target = self
        self.toolbarButton.action = #selector(self.toolbarButtonTapped)
        self.datePicker.addTarget(self, action: #selector(self.didSelectDate), for: .valueChanged)
        self.datePicker.minuteInterval = 30
        self.textField.clearButtonMode = .never
    }
    
    override func becomeActive() {
        super.becomeActive()
        self.setDate()
    }
    
    private func setDate() {
        self.textField.text = self.formatter.string(from: self.date)
        self.dateDelegate?.didUpdateDate(input: self)
    }
    
    func setToolbarTitle(_ title: String, buttonText: String) {
        self.toolbarLabel.text = title
        self.toolbarButton.title = buttonText
    }
    
    @IBAction private func toolbarButtonTapped() {
        self.dateDelegate?.didTapButton(input: self)
    }
    
    @IBAction private func didSelectDate() {
        self.setDate()
    }
}
