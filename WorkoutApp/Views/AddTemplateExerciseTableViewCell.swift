//
//  AddTemplateExerciseTableViewCell.swift
//  BuiltDiff
//
//  Created by Timmy Nguyen on 12/28/24.
//

import UIKit

class AddTemplateExerciseTableViewCell: UITableViewCell {
    static let reuseIdentifier = "AddTemplateExerciseTableViewCell"

    var titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Add Exercise"
        label.textColor = Settings.shared.accentColor.color
        return label
    }()
    
    var container: UIStackView = {
        let hstack = UIStackView()
        hstack.axis = .horizontal
        hstack.spacing = 4
        hstack.translatesAutoresizingMaskIntoConstraints = false
        return hstack
    }()

    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        container.addArrangedSubview(titleLabel)
        
        contentView.addSubview(container)
        
        NSLayoutConstraint.activate([
            container.topAnchor.constraint(equalTo: contentView.layoutMarginsGuide.topAnchor),
            container.bottomAnchor.constraint(equalTo: contentView.layoutMarginsGuide.bottomAnchor),
            container.leadingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.leadingAnchor),
            container.trailingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.trailingAnchor),
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
