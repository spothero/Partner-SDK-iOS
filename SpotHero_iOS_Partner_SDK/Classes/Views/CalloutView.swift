//
//  CalloutView.swift
//  SpotHero_iOS_Partner_SDK
//
//  Created by Matthew Reed on 2/20/18.
//

import UIKit

protocol CalloutViewDelegate: class {
    func didTapInfoButton(calloutView: CalloutView)
}

class CalloutView: UIView {
    let iconImageView = UIImageView()
    let label = CalloutLabel()
    let infoButton = UIButton(type: .detailDisclosure)
    let kind: Kind
    
    weak var delegate: CalloutViewDelegate?
    
    enum Kind {
        case
        oversized(description: String),
        autoextension(oldTime: String, newTime: String),
        earlybird(startTime: String, endTime: String, description: String)
        
        var image: UIImage? {
            let prefix = "icon-"
            switch self {
            case .oversized:
                return UIImage(shp_named: prefix + "oversized")
            case .autoextension:
                return UIImage(shp_named: prefix + "autoextension")
            case .earlybird:
                return UIImage(shp_named: prefix + "earlybird")
            }
        }
        
        var text: String {
            switch self {
            case .oversized:
                return LocalizedStrings.Oversized
            case .autoextension:
                return LocalizedStrings.AutoExtension
            case .earlybird(let startTime, let endTime, _):
                return String(format: LocalizedStrings.EarlybirdFormat,
                              startTime,
                              endTime)
            }
        }
        
        var title: String {
            switch self {
            case .oversized:
                return LocalizedStrings.OversizedTitle
            case .autoextension:
                return LocalizedStrings.AutoExtensionTitle
            case .earlybird:
                return LocalizedStrings.EarlybirdTitle
            }
        }
        
        var description: String {
            switch self {
            case .oversized(let description):
                return description
            case .autoextension(let oldTime, let newTime):
                return String(format: LocalizedStrings.AutoExtensionFormat,
                              oldTime,
                              newTime)
            case .earlybird(_, _, let description):
                return description
            }
        }
    }

    init(kind: Kind) {
        self.kind = kind
        super.init(frame: CGRect.zero)
        self.setupViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("Use init(kind: CalloutView.Kind)")
    }
    
    private func setupViews() {
        self.iconImageView.image = self.kind.image
        self.iconImageView.contentMode = .scaleAspectFit
        self.label.text = self.kind.text
        self.infoButton.addTarget(self,
                                  action: #selector(self.infoButtonTapped),
                                  for: .touchUpInside)
        
        self.addSubview(self.iconImageView)
        self.addSubview(self.label)
        self.addSubview(self.infoButton)
        
        self.subviews.forEach { $0.translatesAutoresizingMaskIntoConstraints = false }
        
        //From magic numbers designs
        let height: CGFloat = 56
        let imageWidth: CGFloat = 18
        
        NSLayoutConstraint.activate([
            self.heightAnchor.constraint(equalToConstant: height),
            
            self.iconImageView.heightAnchor.constraint(equalToConstant: imageWidth),
            self.iconImageView.widthAnchor.constraint(equalToConstant: imageWidth),
            self.iconImageView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: HeightsAndWidths.Margins.Large),
            self.iconImageView.centerYAnchor.constraint(equalTo: self.centerYAnchor),
            
            self.label.leadingAnchor.constraint(equalTo: self.iconImageView.trailingAnchor, constant: HeightsAndWidths.Margins.Standard),
            self.label.centerYAnchor.constraint(equalTo: self.centerYAnchor),
            
            self.infoButton.heightAnchor.constraint(equalToConstant: imageWidth),
            self.infoButton.widthAnchor.constraint(equalToConstant: imageWidth),
            self.infoButton.leadingAnchor.constraint(equalTo: self.label.trailingAnchor, constant: HeightsAndWidths.Margins.Standard),
            self.infoButton.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -HeightsAndWidths.Margins.Large),
            self.infoButton.centerYAnchor.constraint(equalTo: self.centerYAnchor),
            ])
        
        self.layer.cornerRadius = height / 2
        self.backgroundColor = .shp_gravel
    }
    
    @IBAction private func infoButtonTapped() {
        self.delegate?.didTapInfoButton(calloutView: self)
    }
}
