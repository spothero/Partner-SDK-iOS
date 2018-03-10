//
//  PopoverViewController.swift
//  SpotHero_iOS_Partner_SDK
//
//  Created by Matthew Reed on 2/23/18.
//

import UIKit

class PopoverViewController: UIViewController {
    private let kind: CalloutView.Kind
    
    init(kind: CalloutView.Kind) {
        self.kind = kind
        super.init(nibName: nil, bundle: nil)
        self.modalPresentationStyle = .overCurrentContext
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("Use init(kind: CalloutView.Kind)")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.setupViews()
    }
    
    @IBAction private func dismissPopover() {
        UIView.animate(withDuration: Animation.Duration.Standard,
                       animations: {
                           self.view.alpha = 0.0
                       },
                       completion: {
                           _ in
                           self.dismiss(animated: false)
                       })
    }
    
    func setupViews() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.dismissPopover))
        tap.delegate = self
        self.view.addGestureRecognizer(tap)
        
        let popoverContainerView = UIView()
        popoverContainerView.layer.cornerRadius = HeightsAndWidths.standardCornerRadius
        popoverContainerView.layer.masksToBounds = true
        popoverContainerView.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(popoverContainerView)
        
        self.view.backgroundColor = UIColor(white: 0, alpha: 0.6)
        let popoverView = UIStackView()
        popoverView.axis = .vertical
        popoverView.distribution = .fillProportionally
        popoverView.translatesAutoresizingMaskIntoConstraints = false
        popoverContainerView.addSubview(popoverView)
        
        let titleView = UIView()
        titleView.backgroundColor = .shp_shift
        let titleLabel = TitleTwoLabel()
        titleLabel.numberOfLines = 0
        titleLabel.text = self.kind.title
        titleLabel.textColor = .white
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleView.addSubview(titleLabel)
        popoverView.addArrangedSubview(titleView)
        
        let contentView = UIView()
        contentView.backgroundColor = .white
        popoverView.addArrangedSubview(contentView)
        
        let contentLabel = BodyLabel()
        contentLabel.translatesAutoresizingMaskIntoConstraints = false
        contentLabel.textColor = .shp_tire
        contentLabel.text = self.kind.description
        contentView.addSubview(contentLabel)
        
        let closeButton = PrimaryButton()
        closeButton.setTitle(LocalizedStrings.Close, for: .normal)
        closeButton.translatesAutoresizingMaskIntoConstraints = false
        closeButton.addTarget(self,
                              action: #selector(self.dismissPopover),
                              for: .touchUpInside)
        contentView.addSubview(closeButton)
        
        let sideMargins: CGFloat = 50
        let buttonHeight: CGFloat = 40
        NSLayoutConstraint.activate([
            popoverContainerView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: sideMargins),
            popoverContainerView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -sideMargins),
            popoverContainerView.centerYAnchor.constraint(equalTo: self.view.centerYAnchor),
            
            popoverView.leadingAnchor.constraint(equalTo: popoverContainerView.leadingAnchor),
            popoverView.trailingAnchor.constraint(equalTo: popoverContainerView.trailingAnchor),
            popoverView.topAnchor.constraint(equalTo: popoverContainerView.topAnchor),
            popoverView.bottomAnchor.constraint(equalTo: popoverContainerView.bottomAnchor),
            
            titleLabel.leadingAnchor.constraint(equalTo: titleView.leadingAnchor, constant: HeightsAndWidths.Margins.Large),
            titleLabel.trailingAnchor.constraint(equalTo: titleView.trailingAnchor, constant: -HeightsAndWidths.Margins.Large),
            titleLabel.topAnchor.constraint(equalTo: titleView.topAnchor, constant: HeightsAndWidths.Margins.Large),
            titleLabel.bottomAnchor.constraint(equalTo: titleView.bottomAnchor, constant: -HeightsAndWidths.Margins.Large),
            
            contentLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: HeightsAndWidths.Margins.Large),
            contentLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -HeightsAndWidths.Margins.Large),
            contentLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: HeightsAndWidths.Margins.Large),
            
            closeButton.topAnchor.constraint(equalTo: contentLabel.bottomAnchor, constant: HeightsAndWidths.Margins.Large),
            closeButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -HeightsAndWidths.Margins.Large),
            closeButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: HeightsAndWidths.Margins.Large),
            closeButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -HeightsAndWidths.Margins.Large),
            closeButton.heightAnchor.constraint(equalToConstant: buttonHeight),
            ])
    }
}

//MARK: - UIGestureRecognizerDelegate

extension PopoverViewController: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        return touch.view === self.view
    }
}
