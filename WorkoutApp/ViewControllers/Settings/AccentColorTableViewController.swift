//
//  AccentColorTableViewController.swift
//  WorkoutApp
//
//  Created by Timmy Nguyen on 2/23/24.
//

import UIKit

protocol AccentColorTableViewControllerDelegate: AnyObject {
    func accentColorTableViewController(_ controller: AccentColorTableViewController, didSelectAccentColor color: UIColor, colorName: String?)
}

class AccentColorTableViewController: UITableViewController {

    let colors: [AccentColor] = AccentColor.allCases
    weak var delegate: AccentColorTableViewControllerDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "ColorCell")
        tableView.register(CustomColorTableViewCell.self, forCellReuseIdentifier: CustomColorTableViewCell.reuseIdentifier)

        navigationItem.title = "Accent Color"
        navigationItem.largeTitleDisplayMode = .never
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 1
        }
        return colors.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row == 0 && indexPath.section == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: CustomColorTableViewCell.reuseIdentifier, for: indexPath) as! CustomColorTableViewCell
            cell.delegate = self
            cell.update(selectedColor: Settings.shared.selectedAccentColor)
            cell.selectionStyle = .none
            return cell
        }
        
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
        Settings.shared.customAccentColor = nil
        NotificationCenter.default.post(name: AccentColor.valueChangedNotification, object: nil)
        delegate?.accentColorTableViewController(self, didSelectAccentColor: selectedColor.color, colorName: selectedColor.rawValue.capitalized)
        tableView.reloadData()
    }
    
    override func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        return indexPath.section == 0 ? nil : indexPath
    }
}

enum AccentColor: String, CaseIterable, Codable {
    case blue, red, orange, yellow, green, purple, pink, mint, cyan, teal, indigo, brown, white
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
        case .white:
            return .white
        }
    }
}

extension AccentColorTableViewController: CustomColorTableViewCellDelegate {
    func customColorTableViewCell(_ cell: CustomColorTableViewCell, didSelectCustomColor color: UIColor) {
        cell.update(selectedColor: color)
        Settings.shared.accentColor = nil
        Settings.shared.customAccentColor = CodableUIColor(color: color)
        NotificationCenter.default.post(name: AccentColor.valueChangedNotification, object: nil)
        delegate?.accentColorTableViewController(self, didSelectAccentColor: color, colorName: nil)
        tableView.reloadSections(IndexSet(integer: 1), with: .automatic)
    }
}

