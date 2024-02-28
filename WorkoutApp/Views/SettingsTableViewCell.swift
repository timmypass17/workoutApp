//
//  SettingsTableViewCell.swift
//  WorkoutApp
//
//  Created by Timmy Nguyen on 2/19/24.
//

import UIKit

protocol SettingsTableViewCellDelegate: AnyObject {
    func settingsTableViewCell(_ sender: SettingsTableViewCell, toggleValueChanged: Bool)
}

class SettingsTableViewCell: UITableViewCell {
    static let identifier = "SettingsCell"
    
    private let iconContainer: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 8
        view.layer.cornerCurve = .continuous
        return view
    }()
    
    var iconImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.tintColor = .white
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        // Set image width & height
        NSLayoutConstraint.activate([
            imageView.widthAnchor.constraint(equalToConstant: 22),
            imageView.heightAnchor.constraint(equalToConstant: 22)
        ])
        return imageView
    }()
    
    var label: UILabel = {
        let label = UILabel()
        label.numberOfLines = 1
        label.lineBreakMode = .byTruncatingTail
        return label
    }()
    
    var secondaryLabel: UILabel = {
        let label = UILabel()
        label.textColor = .secondaryLabel
        label.numberOfLines = 1
        label.lineBreakMode = .byTruncatingTail
        return label
    }()
    
    var toggleView: UISwitch = {
        let toggle = UISwitch()
        toggle.addTarget(self, action: #selector(toggleValueChanged), for: .valueChanged)
        return toggle
    }()
    
    var container: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.spacing = 12
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    weak var delegate: SettingsTableViewCellDelegate?
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        iconContainer.addSubview(iconImageView)
        container.addArrangedSubview(iconContainer)
        container.addArrangedSubview(label)
        container.addArrangedSubview(secondaryLabel)
        
        contentView.addSubview(container)
                
        NSLayoutConstraint.activate([
            container.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            container.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8),
            container.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            container.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16)
        ])
        
        NSLayoutConstraint.activate([
            iconImageView.topAnchor.constraint(equalTo: iconContainer.topAnchor, constant: 4),
            iconImageView.bottomAnchor.constraint(equalTo: iconContainer.bottomAnchor, constant: -4),
            iconImageView.leadingAnchor.constraint(equalTo: iconContainer.leadingAnchor, constant: 4),
            iconImageView.trailingAnchor.constraint(equalTo: iconContainer.trailingAnchor, constant: -4)
        ])
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func update(with model: SettingsTableViewController.Model) {
        iconImageView.image = model.image
        iconContainer.backgroundColor = model.backgroundColor
        label.text = model.text
        secondaryLabel.text = model.secondary
        accessoryType = .disclosureIndicator
    }
    
    @objc func toggleValueChanged(sender: UISwitch) {
        delegate?.settingsTableViewCell(self, toggleValueChanged: sender.isOn)
    }
    
    func addToggleView() {
        container.addArrangedSubview(toggleView)
    }
}
