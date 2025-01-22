//
//  ToggleableSettingsTableViewCell.swift
//  BuiltDiff
//
//  Created by Timmy Nguyen on 1/22/25.
//

import UIKit

protocol ToggleableSettingsTableViewCellDelegate: AnyObject {
    func toggleableSettingsTableViewCell(_ sender: ToggleableSettingsTableViewCell, toggleValueChanged: Bool)
}

class ToggleableSettingsTableViewCell: SettingsTableViewCell {

    static let reuseIdentifier = "ToggleableSettingsTableViewCell"

    var toggleView: UISwitch = {
        let toggle = UISwitch()
        toggle.addTarget(self, action: #selector(toggleValueChanged), for: .valueChanged)
        return toggle
    }()
    
    weak var delegate: ToggleableSettingsTableViewCellDelegate?
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        container.addArrangedSubview(toggleView)
        selectionStyle = .none
    }
    
    @MainActor required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc func toggleValueChanged(sender: UISwitch) {
        delegate?.toggleableSettingsTableViewCell(self, toggleValueChanged: sender.isOn)
    }
}
