//
//  SettingsTableViewController.swift
//  WorkoutApp
//
//  Created by Timmy Nguyen on 2/19/24.
//

import UIKit
import SafariServices
import MessageUI

class SettingsTableViewController: UITableViewController {
    
    struct Section {
        var title: String
        var data: [Model]
    }
    
    struct Model {
        let image: UIImage?
        let text: String
        var secondary: String?
        let backgroundColor: UIColor?
        
        init(image: UIImage, text: String, secondary: String? = nil, backgroundColor: UIColor?) {
            self.image = image
            self.text = text
            self.secondary = secondary
            self.backgroundColor = backgroundColor
        }
    }
    
    var sections = [
        Section(title: "General",
                data: [Model(image: UIImage(systemName: "dumbbell.fill")!, text: "Weight Units", secondary: Settings.shared.weightUnit.description, backgroundColor: .accentColor),
                       Model(image: UIImage(systemName: "alarm.fill")!, text: "Show Timer", backgroundColor: .accentColor),
                Model(image: UIImage(systemName: "figure.run")!, text: "Show \"Add Exercise\"", backgroundColor: .accentColor),
                       Model(image: UIImage(systemName: "iphone.radiowaves.left.and.right")!, text: "Haptic Feedback", backgroundColor: .accentColor),
                      ]),
        Section(title: "Appearance",
                data: [Model(image: UIImage(systemName: "moon.stars.fill")!, text: "Theme", secondary: Settings.shared.theme.description, backgroundColor: .systemIndigo),
                       Model(image: UIImage(systemName: "paintpalette.fill")!, text: "Accent Color", secondary: Settings.shared.accentColor.rawValue.capitalized, backgroundColor: .systemOrange)]),
        Section(title: "Help & Support",
                data: [Model(image: UIImage(systemName: "mail.fill")!, text: "Contact Us", backgroundColor: .systemGreen),
                       Model(image: UIImage(systemName: "ladybug.fill")!, text: "Bug Report", backgroundColor: .systemRed)]),
        Section(title: "Privacy",
                data: [Model(image: UIImage(systemName: "hand.raised.fill")!, text: "Privacy Policy", backgroundColor: .systemGray)])
    ]

    static let weightIndexPath = IndexPath(row: 0, section: 0)
    static let showTimerIndexPath = IndexPath(row: 1, section: 0)
    static let showExerciseIndexPath = IndexPath(row: 2, section: 0)
    static let hapticIndexPath = IndexPath(row: 3, section: 0)

    static let themeIndexpath = IndexPath(row: 0, section: 1)
    static let accentColorIndexpath = IndexPath(row: 1, section: 1)
    static let contactIndexPath = IndexPath(row: 0, section: 2)
    static let bugIndexPath = IndexPath(row: 1, section: 2)
    static let privacyIndexPath = IndexPath(row: 0, section: 3)
    
    private let email = "timmysappstuff@gmail.com"
    
    init() {
        super.init(style: .grouped)
    }
    
    required init?(coder: NSCoder) {
        
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "Settings"
        navigationController?.navigationBar.prefersLargeTitles = true
        tableView.register(SettingsTableViewCell.self, forCellReuseIdentifier: SettingsTableViewCell.identifier)
    }
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return sections.count
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sections[section].data.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SettingsCell", for: indexPath) as! SettingsTableViewCell
        let model = sections[indexPath.section].data[indexPath.row]
        cell.update(with: model)
        if indexPath == SettingsTableViewController.showTimerIndexPath || indexPath == SettingsTableViewController.showExerciseIndexPath || indexPath == SettingsTableViewController.hapticIndexPath {
            cell.addToggleView()
            cell.accessoryType = .none
            if indexPath == SettingsTableViewController.showTimerIndexPath {
                cell.toggleView.isOn = Settings.shared.showTimer
            } else if indexPath == SettingsTableViewController.showExerciseIndexPath {
                cell.toggleView.isOn = Settings.shared.showAddExercise
            } else if indexPath == SettingsTableViewController.hapticIndexPath {
                cell.toggleView.isOn = Settings.shared.enableHaptic
            }
        }
        cell.delegate = self
        return cell
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return sections[section].title
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
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
    func accentColorTableViewController(_ controller: AccentColorTableViewController, didSelectAccentColor color: AccentColor) {
        let colorIndexPath = SettingsTableViewController.accentColorIndexpath
        sections[colorIndexPath.section].data[colorIndexPath.row].secondary = color.rawValue.capitalized
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

extension SettingsTableViewController: SettingsTableViewCellDelegate {
    func settingsTableViewCell(_ sender: SettingsTableViewCell, toggleValueChanged: Bool) {
        guard let indexPath = tableView.indexPath(for: sender) else { return }
        if indexPath == SettingsTableViewController.showTimerIndexPath {
            Settings.shared.showTimer = toggleValueChanged
        } else if indexPath == SettingsTableViewController.showExerciseIndexPath {
            Settings.shared.showAddExercise = toggleValueChanged
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
