//
//  TextInputView.swift
//  SpotHero_iOS_Partner_SDK
//
//  Created by Matthew Reed on 12/5/17.
//

import UIKit

protocol TextInputViewDelegate: AnyObject {
    func didBeginEditing(input: TextInputView)
    func didEndEditing(input: TextInputView)
    func didUpdateText(text: String?, input: TextInputView)
}

class TextInputView: UIControl {
    fileprivate let inputLabel = UILabel()
    private let iconImageView = UIImageView()
    internal let textField = UITextField()
    fileprivate let bottomBorder = UIView()
    private let stackView = UIStackView()
    fileprivate let bottomBorderHeightConstraint: NSLayoutConstraint
    weak var delegate: TextInputViewDelegate?
    
    fileprivate let inactiveBottomBorderHeight: CGFloat = 1
    fileprivate let activeBottomBorderHeight: CGFloat = 2
    private let stackViewHeight: CGFloat = 20
    
    var placeholder: String? {
        didSet {
            if let placeholder = self.placeholder {
                self.textField.attributedPlaceholder = NSAttributedString(string: placeholder,
                                                                          attributes: [.foregroundColor: UIColor.shp_secondary])
            }
            self.inputLabel.text = self.placeholder
        }
    }
    
    var text: String? {
        get {
            return self.textField.text
        }
        set {
            self.textField.text = newValue
        }
    }
    
    var image: UIImage? {
        get {
            return self.iconImageView.image
        }
        set {
            let templateImage = newValue?.withRenderingMode(.alwaysTemplate)
            self.iconImageView.image = templateImage
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        self.bottomBorderHeightConstraint = self.bottomBorder
            .heightAnchor
            .constraint(equalToConstant: self.inactiveBottomBorderHeight)
        super.init(coder: aDecoder)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.setupViews()
        self.setupConstraints()
    }
    
    internal func setupViews() {
        self.bottomBorder.backgroundColor = .shp_input
        self.bottomBorder.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(self.bottomBorder)
        
        self.stackView.axis = .horizontal
        self.stackView.distribution = .fillProportionally
        self.stackView.alignment = .fill
        self.stackView.spacing = HeightsAndWidths.Margins.Standard
        self.stackView.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(self.stackView)
        
        self.iconImageView.contentMode = .scaleAspectFit
        self.iconImageView.tintColor = .shp_shift
        self.stackView.addArrangedSubview(self.iconImageView)
        
        self.textField.font = .shp_subhead
        self.textField.textColor = .shp_primary
        self.textField.tintColor = .shp_shift
        self.textField.delegate = self
        self.textField.addTarget(self, action: #selector(self.didUpdateText), for: .editingChanged)
        self.stackView.addArrangedSubview(self.textField)
        
        self.inputLabel.font = .shp_captionInput
        self.inputLabel.textColor = .shp_secondary
        self.inputLabel.translatesAutoresizingMaskIntoConstraints = false
        self.inputLabel.alpha = 0
        self.addSubview(self.inputLabel)
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.becomeActive))
        self.addGestureRecognizer(tapGesture)
        
        self.textField.clearButtonMode = .whileEditing
    }
    
    fileprivate func setupConstraints() {
        NSLayoutConstraint.activate([
            self.bottomBorder.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            self.bottomBorder.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            self.bottomBorder.bottomAnchor.constraint(equalTo: self.bottomAnchor),
            self.bottomBorderHeightConstraint,
            
            self.stackView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            self.stackView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            self.bottomAnchor.constraint(equalTo: self.stackView.bottomAnchor, constant: HeightsAndWidths.Margins.Standard),
            self.stackView.topAnchor.constraint(equalTo: self.topAnchor, constant: self.stackViewHeight),
            
            self.iconImageView.widthAnchor.constraint(equalTo: self.iconImageView.heightAnchor),
            
            self.inputLabel.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            self.stackView.topAnchor.constraint(equalTo: self.inputLabel.bottomAnchor, constant: HeightsAndWidths.Margins.Small),
        ])
    }
    
    @objc
    internal func becomeActive() {
        self.textField.becomeFirstResponder()
    }
    
    func resignActive() {
        self.textField.resignFirstResponder()
    }
    
    @IBAction private func didUpdateText() {
        self.delegate?.didUpdateText(text: self.text, input: self)
    }
}

// MARK: UITextFieldDelegate

extension TextInputView: UITextFieldDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField) {
        self.delegate?.didBeginEditing(input: self)
        UIView.animate(withDuration: Animation.Duration.Standard) {
            self.inputLabel.alpha = 1
            self.textField.placeholder = nil
            self.bottomBorderHeightConstraint.constant = self.activeBottomBorderHeight
            self.bottomBorder.backgroundColor = .shp_inputActive
            self.layoutIfNeeded()
        }
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        self.delegate?.didEndEditing(input: self)
        UIView.animate(withDuration: Animation.Duration.Standard) {
            self.bottomBorderHeightConstraint.constant = self.inactiveBottomBorderHeight
            self.bottomBorder.backgroundColor = .shp_input
            if textField.text?.isEmpty == true {
                self.inputLabel.alpha = 0
                let placeholderText = self.placeholder
                self.placeholder = placeholderText
            }
            self.layoutIfNeeded()
        }
    }
}
