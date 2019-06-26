//  swiftlint:disable:this file_name
//  LabelSubclasses.swift
//  ILGHttpConstants
//
//  Created by Matthew Reed on 12/5/17.
//

import UIKit

class SHPLabel: UILabel {
    required init?(coder: NSCoder) {
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
        //Override as needed
    }
}

class HeadlineLabel: SHPLabel {
    override func commonInit() {
        super.commonInit()
        self.font = .shp_headline
        self.textColor = .shp_primary
    }
}

class TitleLabel: SHPLabel {
    override func commonInit() {
        super.commonInit()
        self.font = .shp_title
        self.textColor = .shp_primary
    }
}

class TitleTwoLabel: SHPLabel {
    override func commonInit() {
        super.commonInit()
        self.font = .shp_titleTwo
        self.textColor = .shp_primary
    }
}

class SubheadLabel: SHPLabel {
    override func commonInit() {
        super.commonInit()
        self.font = .shp_subhead
        self.textColor = .shp_tire
    }
}

class BodyLabel: SHPLabel {
    override func commonInit() {
        super.commonInit()
        self.font = .shp_body
        self.numberOfLines = 0
        self.textColor = .shp_secondary
    }
}

class CaptionInputLabel: SHPLabel {
    override func commonInit() {
        super.commonInit()
        self.font = .shp_captionInput
        self.textColor = .shp_cement
    }
}

class ErrorLabel: SHPLabel {
    override func commonInit() {
        super.commonInit()
        self.font = .shp_error
        self.textColor = .shp_inputError
    }
}

class CalloutLabel: SHPLabel {
    override func commonInit() {
        super.commonInit()
        self.font = .shp_body
        self.textColor = .shp_tire
        self.numberOfLines = 0
    }
}
