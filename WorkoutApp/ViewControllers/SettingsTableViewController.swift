//
//  SettingsTableViewController.swift
//  WorkoutApp
//
//  Created by Timmy Nguyen on 2/19/24.
//

import UIKit
import SafariServices
import MessageUI

class SettingsTableViewController: UIViewController {
    
    private let tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .grouped)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        return tableView
    }()
    
    struct Section {
        var title: String
        var data: [Model]
    }
    
    struct Model {
        let image: UIImage?
        let text: String
        var secondary: String?
        var backgroundColor: UIColor?
        let isOn: Bool?
        
        init(image: UIImage, text: String, secondary: String? = nil, backgroundColor: UIColor?, isOn: Bool? = nil) {
            self.image = image
            self.text = text
            self.secondary = secondary
            self.backgroundColor = backgroundColor
            self.isOn = isOn
        }
    }
    
    var sections = [
        Section(title: "General",
                data: [Model(image: UIImage(systemName: "dumbbell.fill")!, text: "Weight Units", secondary: Settings.shared.weightUnit.description, backgroundColor: Settings.shared.selectedAccentColor),
                       Model(image: UIImage(systemName: "alarm.fill")!, text: "Show Timer", backgroundColor: Settings.shared.selectedAccentColor, isOn: Settings.shared.showTimer),
                       Model(image: UIImage(systemName: "iphone.radiowaves.left.and.right")!, text: "Haptic Feedback", backgroundColor: Settings.shared.selectedAccentColor, isOn: Settings.shared.enableHaptic),
                      ]),
        Section(title: "Appearance",
                data: [Model(image: UIImage(systemName: "moon.stars.fill")!, text: "Theme", secondary: Settings.shared.theme.description, backgroundColor: .systemIndigo),
                       Model(image: UIImage(systemName: "paintpalette.fill")!, text: "Accent Color", secondary: Settings.shared.accentColor?.rawValue.capitalized ?? "Custom", backgroundColor: .systemOrange)]),
        Section(title: "Help & Support",
                data: [Model(image: UIImage(systemName: "mail.fill")!, text: "Contact Us", backgroundColor: .systemGreen),
                       Model(image: UIImage(systemName: "ladybug.fill")!, text: "Bug Report", backgroundColor: .systemRed)]),
        Section(title: "Privacy",
                data: [Model(image: UIImage(systemName: "hand.raised.fill")!, text: "Privacy Policy", backgroundColor: .systemGray)])
    ]

    static let weightIndexPath = IndexPath(row: 0, section: 0)
    static let showTimerIndexPath = IndexPath(row: 1, section: 0)
    static let hapticIndexPath = IndexPath(row: 2, section: 0)

    static let themeIndexpath = IndexPath(row: 0, section: 1)
    static let accentColorIndexpath = IndexPath(row: 1, section: 1)
    static let contactIndexPath = IndexPath(row: 0, section: 2)
    static let bugIndexPath = IndexPath(row: 1, section: 2)
    static let privacyIndexPath = IndexPath(row: 0, section: 3)
    
    private let email = "timmysappstuff@gmail.com"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "Settings"
        navigationController?.navigationBar.prefersLargeTitles = true
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(SelectableSettingsTableViewCell.self, forCellReuseIdentifier: SelectableSettingsTableViewCell.reuseIdentifier)
        tableView.register(ToggleableSettingsTableViewCell.self, forCellReuseIdentifier: ToggleableSettingsTableViewCell.reuseIdentifier)

        view.addSubview(tableView)

        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if let selectedIndexPath = tableView.indexPathForSelectedRow {
            tableView.deselectRow(at: selectedIndexPath, animated: true)
        }
    }
}

extension SettingsTableViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return sections.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sections[section].data.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath == SettingsTableViewController.showTimerIndexPath || indexPath == SettingsTableViewController.hapticIndexPath {
            let cell = tableView.dequeueReusableCell(withIdentifier: ToggleableSettingsTableViewCell.reuseIdentifier, for: indexPath) as! ToggleableSettingsTableViewCell
            cell.delegate = self
            let model = sections[indexPath.section].data[indexPath.row]
            cell.update(with: model)
            cell.toggleView.isOn = model.isOn ?? false
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: SelectableSettingsTableViewCell.reuseIdentifier, for: indexPath) as! SelectableSettingsTableViewCell
            let model = sections[indexPath.section].data[indexPath.row]
            cell.update(with: model)
            return cell
        }
//        let cell = tableView.dequeueReusableCell(withIdentifier: "SettingsCell", for: indexPath) as! SettingsTableViewCell
//        let model = sections[indexPath.section].data[indexPath.row]
//        cell.update(with: model)
        
        
//        if indexPath == SettingsTableViewController.showTimerIndexPath || indexPath == SettingsTableViewController.hapticIndexPath {
//            cell.addToggleView()
//            cell.selectionStyle = .none
//            cell.accessoryType = .none
//            if indexPath == SettingsTableViewController.showTimerIndexPath {
//                cell.toggleView.isOn = Settings.shared.showTimer
//            } else if indexPath == SettingsTableViewController.hapticIndexPath {
//                cell.toggleView.isOn = Settings.shared.enableHaptic
//            }
//        } else {
//            cell.selectionStyle = .default
//            cell.accessoryType = .disclosureIndicator
//        }
//        cell.delegate = self
//        return cell
    }
}

extension SettingsTableViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return sections[section].title
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath == SettingsTableViewController.weightIndexPath {
            let weightTableViewController = WeightTableViewController(style: .grouped)
            weightTableViewController.delegate = self
            navigationController?.pushViewController(weightTableViewController, animated: true)
        } else if indexPath == SettingsTableViewController.themeIndexpath {
            let themeTableViewController = ThemeTableViewController(style: .grouped)
            themeTableViewController.delegate = self
            navigationController?.pushViewController(themeTableViewController, animated: true)
        } else if indexPath == SettingsTableViewController.accentColorIndexpath {
            let accentColorTableViewController = AccentColorTableViewController(style: .grouped)
            accentColorTableViewController.delegate = self
            navigationController?.pushViewController(accentColorTableViewController, animated: true)
        } else if indexPath == SettingsTableViewController.contactIndexPath {
            guard MFMailComposeViewController.canSendMail() else {
                showMailErrorAlert()
                return
            }
            
            let mailComposer = MFMailComposeViewController()
            mailComposer.mailComposeDelegate = self
            mailComposer.setToRecipients([email])
            mailComposer.setSubject("[BuiltDiff] Contact Us")
            
            present(mailComposer, animated: true)
        } else if indexPath == SettingsTableViewController.bugIndexPath {
            guard MFMailComposeViewController.canSendMail() else {
                showMailErrorAlert()
                return
            }
            
            let mailComposer = MFMailComposeViewController()
            mailComposer.mailComposeDelegate = self
            
            mailComposer.setToRecipients([email])
            mailComposer.setSubject("[BuiltDiff] Bug Report")
            
            present(mailComposer, animated: true)
        } else if indexPath == SettingsTableViewController.privacyIndexPath {
            let privacyTableViewController = PrivacyTableViewController(style: .insetGrouped)
            navigationController?.pushViewController(privacyTableViewController, animated: true)
        }
    }
}

extension SettingsTableViewController: WeightTableViewControllerDelegate {
    func weightTableViewController(_ viewController: WeightTableViewController, didSelectWeightType weightType: WeightType) {
        let weightIndexPath = SettingsTableViewController.weightIndexPath
        sections[weightIndexPath.section].data[weightIndexPath.row].secondary = weightType.description
        tableView.reloadRows(at: [weightIndexPath], with: .automatic)
    }
}

extension SettingsTableViewController: ThemeTableViewControllerDelegate {
    func themeTableViewController(_ controller: ThemeTableViewController, didSelectTheme theme: UIUserInterfaceStyle) {
        let themeIndexPath = SettingsTableViewController.themeIndexpath
        sections[themeIndexPath.section].data[themeIndexPath.row].secondary = theme.description
        tableView.reloadRows(at: [themeIndexPath], with: .automatic)
    }
}

extension SettingsTableViewController: AccentColorTableViewControllerDelegate {
    func accentColorTableViewController(_ controller: AccentColorTableViewController, didSelectAccentColor color: UIColor, colorName: String?) {
        let colorIndexPath = SettingsTableViewController.accentColorIndexpath
        for j in 0..<sections[0].data.count {
            sections[0].data[j].backgroundColor = color
        }
        sections[colorIndexPath.section].data[colorIndexPath.row].secondary = colorName ?? "Custom"
        
        tableView.reloadSections(IndexSet(integer: 0), with: .automatic)
        tableView.reloadRows(at: [colorIndexPath], with: .automatic)
    }
}

extension SettingsTableViewController: MFMailComposeViewControllerDelegate {
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        dismiss(animated: true)
        if let selectedIndexPath = tableView.indexPathForSelectedRow {
            tableView.deselectRow(at: selectedIndexPath, animated: true)
        }
    }
    
    func showMailErrorAlert() {
        let alert = UIAlertController(
            title: "No Email Account Found",
            message: "There is no email account associated to this device. If you have any questions, please feel free to reach out to us at \(email)",
            preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: "Default action"), style: .default, handler: { _ in }))
        self.present(alert, animated: true, completion: nil)
    }
}

extension SettingsTableViewController: ToggleableSettingsTableViewCellDelegate {
    func toggleableSettingsTableViewCell(_ sender: ToggleableSettingsTableViewCell, toggleValueChanged: Bool) {
        guard let indexPath = tableView.indexPath(for: sender) else { return }
        if indexPath == SettingsTableViewController.showTimerIndexPath {
            Settings.shared.showTimer = toggleValueChanged
        } else if indexPath == SettingsTableViewController.hapticIndexPath {
            Settings.shared.enableHaptic = toggleValueChanged
        }
    }
}

/**
 2 Ways to to pass messages between objects
 1. Delegates (protocol)
 - used for 1 to 1 communication (phone call)
 - can communicate between one another
 2. Notification
 - 1 to many communication (radio station, multible people can listen)
 - Can only broadcast message, can't communication back and forth between listener (unless
 
 Reference: https://stackoverflow.com/questions/5325226/what-is-the-difference-between-delegate-and-notification
 */
