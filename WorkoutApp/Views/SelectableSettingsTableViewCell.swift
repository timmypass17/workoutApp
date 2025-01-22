//
//  SelectableSettingsTableViewCell.swift
//  BuiltDiff
//
//  Created by Timmy Nguyen on 1/22/25.
//

import UIKit

class SelectableSettingsTableViewCell: SettingsTableViewCell {
    
    static let reuseIdentifier = "SelectableSettingsTableViewCell"
    
    var secondaryLabel: UILabel = {
        let label = UILabel()
        label.textColor = .secondaryLabel
        label.numberOfLines = 1
        label.lineBreakMode = .byTruncatingTail
        return label
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        container.addArrangedSubview(secondaryLabel)
    }
    
    @MainActor required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func update(with model: SettingsTableViewController.Model) {
        super.update(with: model)
        secondaryLabel.text = model.secondary
        accessoryType = .disclosureIndicator
    }
    
}
