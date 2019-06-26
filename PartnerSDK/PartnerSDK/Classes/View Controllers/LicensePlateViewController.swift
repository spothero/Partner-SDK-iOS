//
//  LicensePlateViewController.swift
//  SpotHero_iOS_Partner_SDK
//
//  Created by Reed.Hogan on 6/4/19.
//  Copyright © 2019 SpotHero, Inc. All rights reserved.
//

import UIKit

protocol LicensePlateViewControllerDelegate: AnyObject {
    func addedLicensePlate(_ licensePlate: String)
}

class LicensePlateViewController: UIViewController {
    
    static let StoryboardIdentifier = String(describing: LicensePlateViewController.self)
    
    static func fromStoryboard() -> LicensePlateViewController {
        return Storyboard.main.viewController(from: self.StoryboardIdentifier)
    }
    
    @IBOutlet private var licensePlateTextField: SHPTextField!
    @IBOutlet private var licensePlateLabel: UILabel!
    @IBOutlet private var licensePlateExplanationLabel: UILabel!
    @IBOutlet private var stateTitleLabel: UILabel!
    @IBOutlet private var stateLabel: UILabel!
    @IBOutlet private var caretImageView: UIImageView!
    @IBOutlet private var addLicensePlateButton: UIButton!
    @IBOutlet private var addLicensePlateButtonContainer: UIView!
    
    weak var delegate: LicensePlateViewControllerDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = LocalizedStrings.AddLicensePlate
        self.licensePlateTextField.delegate = self
        self.licensePlateLabel.text = LocalizedStrings.License
        self.licensePlateTextField.setAttributedPlaceholder(text: LocalizedStrings.LicensePlate)
        self.licensePlateExplanationLabel.text = LocalizedStrings.LicensePlateInstructions
        self.stateTitleLabel.text = LocalizedStrings.LicensePlateStateTitle
        self.stateLabel.text = nil
        self.caretImageView.tintColor = .shp_tire
        self.licensePlateTextField.inputAccessoryView = self.addLicensePlateButtonContainer
        self.addLicensePlateButton.setTitle(LocalizedStrings.AddLicensePlate, for: .normal)
        self.addLicensePlateButtonContainer.shp_addShadow()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.licensePlateTextField.becomeFirstResponder()
    }
    
    private func updateAddLicensePlateButton() {
        self.addLicensePlateButton.isEnabled = self.licensePlateTextField?.text?.isEmpty == false
    }
    
    @IBAction private func addLicensePlateButtonTapped() {
        guard
            let licensePlate = self.licensePlateTextField.text,
            Validator.validateLicense(licensePlate) else {
                return
        }
        self.delegate?.addedLicensePlate(licensePlate)
    }
    
    @IBAction private func licensePlateStateTapped() {
        let licensePlateStateViewController = LicensePlateStateViewController.fromStoryboard()
        licensePlateStateViewController.delegate = self
        self.present(licensePlateStateViewController, animated: true)
    }
}

// MARK: - UITextFieldDelegate

extension LicensePlateViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.addLicensePlateButtonTapped()
        return true
    }
    
    func textField(_ textField: UITextField,
                   shouldChangeCharactersIn range: NSRange,
                   replacementString string: String) -> Bool {
        guard textField === self.licensePlateTextField else {
            return true
        }

        defer {
            self.updateAddLicensePlateButton()
        }
        
        //the format function returns if formatting occurred, negate that to determine if we should allow regular typing
        return !LicensePlateFormatter.format(plateTextField: textField,
                                             forRange: range,
                                             replacementString: string)
    }
}

// MARK: - StateSelectionDelegate

extension LicensePlateViewController: StateSelectionDelegate {
    func stateSelected(_ state: String) {
        self.stateTitleLabel.text = LocalizedStrings.SelectedLicensePlateStateTitle
        self.stateLabel.text = state
    }
}
