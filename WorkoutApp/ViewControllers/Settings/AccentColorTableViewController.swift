//
//  AccentColorTableViewController.swift
//  WorkoutApp
//
//  Created by Timmy Nguyen on 2/23/24.
//

import UIKit

protocol AccentColorTableViewControllerDelegate: AnyObject {
    func accentColorTableViewController(_ controller: AccentColorTableViewController, didSelectAccentColor color: AccentColor)
}

class AccentColorTableViewController: UITableViewController {

    let colors: [AccentColor] = AccentColor.allCases
    weak var delegate: AccentColorTableViewControllerDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "ColorCell")
        navigationItem.title = "Accent Color"
        navigationItem.largeTitleDisplayMode = .never
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return colors.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ColorCell", for: indexPath)
        let color = colors[indexPath.row]
        
        var content = cell.defaultContentConfiguration()
        content.text = color.rawValue.capitalized
        cell.contentConfiguration = content
        cell.accessoryType = color == Settings.shared.accentColor ? .checkmark : .none
        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let selectedColor = colors[indexPath.row]
        Settings.shared.accentColor = selectedColor
        NotificationCenter.default.post(name: AccentColor.valueChangedNotification, object: nil)
        delegate?.accentColorTableViewController(self, didSelectAccentColor: selectedColor)
        tableView.reloadData()
    }
}

enum AccentColor: String, CaseIterable, Codable {
    case blue, red, orange, yellow, green, purple, pink, mint, cyan, teal, indigo, brown
    static let valueChangedNotification = Notification.Name("AccentColor.valueChanged")

    var color: UIColor {
        switch self {
        case .red:
            return .systemRed
        case .orange:
            return .systemOrange
        case .yellow:
            return .systemYellow
        case .green:
            return .systemGreen
        case .blue:
            return .systemBlue
        case .purple:
            return .systemPurple
        case .pink:
            return .systemPink
        case .mint:
            return .systemMint
        case .cyan:
            return .systemCyan
        case .teal:
            return .systemTeal
        case .indigo:
            return .systemIndigo
        case .brown:
            return .systemBrown
        }
    }
}

