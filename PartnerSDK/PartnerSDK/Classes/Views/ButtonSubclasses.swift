//  swiftlint:disable:this file_name
//  ButtonSubclasses.swift
//  SpotHero_iOS_Partner_SDK
//
//  Created by Matthew Reed on 12/12/17.
//

import Foundation
import UIKit

class SHPButton: UIButton {
    required init?(coder: NSCoder) { //swiftlint:disable:this missing_docs
        super.init(coder: coder)
        self.commonInit()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.commonInit()
    }
    
    convenience init() {
        self.init(frame: .zero)
        self.commonInit()
    }
    
    func commonInit() {
        self.titleLabel?.font = .shp_button
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.layer.cornerRadius = self.frame.height / 2.0
    }
}

class PrimaryButton: SHPButton {
    override func commonInit() {
        super.commonInit()
        self.backgroundColor = self.isEnabled ? .shp_primaryButtonBackground : .shp_primaryButtonDisabledBackground
        self.setTitleColor(.white, for: .normal)
    }
    
    override var isEnabled: Bool {
        didSet {
            self.backgroundColor = self.isEnabled ? .shp_primaryButtonBackground : .shp_primaryButtonDisabledBackground
        }
    }
}

class SecondaryButton: SHPButton {
    override func commonInit() {
        super.commonInit()
        self.backgroundColor = .white
        self.setTitleColor(.shp_secondaryButtonText, for: .normal)
        self.setTitleColor(.shp_secondaryButtonDisabledText, for: .disabled)
        self.layer.borderWidth = 1
        self.layer.borderColor = UIColor.shp_secondaryButtonBorder.cgColor
    }
}

class LinkButton: UIButton {
    required init?(coder: NSCoder) { //swiftlint:disable:this missing_docs
        super.init(coder: coder)
        self.commonInit()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.commonInit()
    }
    
    convenience init() {
        self.init(frame: .zero)
        self.commonInit()
    }
    
    func commonInit() {
        self.titleLabel?.font = .shp_link
        self.setTitleColor(.shp_link, for: .normal)
        self.contentHorizontalAlignment = .left
    }
}
