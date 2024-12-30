//
//  TemplateExerciseTableViewCell.swift
//  BuiltDiff
//
//  Created by Timmy Nguyen on 12/28/24.
//

import UIKit

class TemplateExerciseTableViewCell: UITableViewCell {
    
    static let reuseIdentifier = "TemplateExerciseTableViewCell"
    
    let nameLabel: UILabel = {
        let label = UILabel()
        return label
    }()
    
    let frequencyLabel: UILabel = {
        let label = UILabel()
        label.textColor = .secondaryLabel
        return label
    }()
    
    let container: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        container.addArrangedSubview(nameLabel)
        container.addArrangedSubview(frequencyLabel)
        
        contentView.addSubview(container)
        
        NSLayoutConstraint.activate([
            container.topAnchor.constraint(equalTo: contentView.layoutMarginsGuide.topAnchor),
            container.bottomAnchor.constraint(equalTo: contentView.layoutMarginsGuide.bottomAnchor),
            container.leadingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.leadingAnchor),
            container.trailingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.trailingAnchor)
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func update(templateExercise: TemplateExercise) {
        nameLabel.text = templateExercise.name
        frequencyLabel.text = "\(templateExercise.sets) x \(templateExercise.reps) reps"
    }
    
}
