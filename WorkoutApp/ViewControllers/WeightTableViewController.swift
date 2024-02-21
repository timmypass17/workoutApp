//
//  WeightTableViewController.swift
//  WorkoutApp
//
//  Created by Timmy Nguyen on 2/20/24.
//

import UIKit

protocol WeightTableViewControllerDelegate: AnyObject {
    func weightTableViewController(_ viewController: WeightTableViewController, didSelectWeightType weightType: WeightType)
}

enum WeightType: String, CaseIterable, Codable {
    case lbs
    case kg
    
    static let valueChangedNotification = NSNotification.Name("weightTypeChangedNotification")
    
    var description: String {
        switch self {
        case .lbs:
            return "US/Imperial (lbs)"
        case .kg:
            return "Metric (kg)"
        }
    }
}

class WeightTableViewController: UITableViewController {
        
    weak var delegate: WeightTableViewControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "WeightTypeCell")
        navigationItem.title = "Weight Unit"
        navigationItem.largeTitleDisplayMode = .never
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return WeightType.allCases.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let weightType = WeightType.allCases[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "WeightTypeCell", for: indexPath)
        var config = cell.defaultContentConfiguration()
        config.text = weightType.description
        cell.contentConfiguration = config
        cell.accessoryType = Settings.shared.weightUnit == weightType ? .checkmark : .none
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let weightType = WeightType.allCases[indexPath.row]
        Settings.shared.weightUnit = weightType
        delegate?.weightTableViewController(self, didSelectWeightType: weightType)
        tableView.deselectRow(at: indexPath, animated: true)
        tableView.reloadData()
        NotificationCenter.default.post(name: WeightType.valueChangedNotification, object: nil)
    }
}
