//
//  LicensePlateStateViewController.swift
//  SpotHero_iOS_Partner_SDK
//
//  Created by Reed.Hogan on 6/5/19.
//  Copyright © 2019 SpotHero, Inc. All rights reserved.
//

import UIKit

protocol StateSelectionDelegate: AnyObject {
    func stateSelected(_ state: String)
}

class LicensePlateStateViewController: UIViewController {
    
    private static let StoryboardIdentifier = String(describing: LicensePlateStateViewController.self)
    private static let cellIdentifier = "LicensePlateCell"
    
    static func fromStoryboard() -> LicensePlateStateViewController {
        return Storyboard.main.viewController(from: self.StoryboardIdentifier)
    }
    
    @IBOutlet private var titleLabel: UILabel!
    
    weak var delegate: StateSelectionDelegate?
    
    /// A dictionary where each key is an uppercased letter of the alphabet, and the values are all states that begin with that letter
    private lazy var groupedStates: [String: [State]] = {
        return Dictionary(grouping: State.allStates) { state in
            return state.name.first?.uppercased() ?? ""
        }
    }()
    
    private lazy var sectionTitles = self.groupedStates.keys.sorted()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.titleLabel.text = LocalizedStrings.LicensePlateStateTitle
    }
    
    @IBAction private func closeButtonTapped() {
        self.dismiss(animated: true)
    }
}

// MARK: - UITableViewDelegate

extension LicensePlateStateViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let state = self.state(for: indexPath) else {
            return
        }
        self.delegate?.stateSelected(state.name)
        self.dismiss(animated: true)
    }
}

// MARK: - UITableViewDataSource

extension LicensePlateStateViewController: UITableViewDataSource {
    
    private func sectionTitle(for section: Int) -> String? {
        guard self.sectionTitles.indices.contains(section) else {
            return nil
        }
        return self.sectionTitles[section]
    }
    
    private func statesForSection(_ section: Int) -> [State] {
        guard let sectionTitle = self.sectionTitle(for: section) else {
            return []
        }
        return self.groupedStates[sectionTitle] ?? []
    }
    
    private func state(for indexPath: IndexPath) -> State? {
        let statesForSection = self.statesForSection(indexPath.section)
        guard statesForSection.indices.contains(indexPath.item) else {
            return nil
        }
        return statesForSection[indexPath.item]
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return self.groupedStates.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.statesForSection(section).count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let state = self.state(for: indexPath) else {
            return UITableViewCell(frame: .zero)
        }
        let cell: UITableViewCell
        if let dequeuedCell = tableView.dequeueReusableCell(withIdentifier: LicensePlateStateViewController.cellIdentifier) {
            cell = dequeuedCell
        } else {
            cell = UITableViewCell(style: .default, reuseIdentifier: LicensePlateStateViewController.cellIdentifier)
        }
        cell.textLabel?.text = state.name
        cell.textLabel?.textColor = .shp_tire
        return cell
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return self.sectionTitle(for: section)
    }
}
