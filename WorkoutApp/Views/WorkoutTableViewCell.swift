//
//  WorkoutTableViewCell.swift
//  WorkoutApp
//
//  Created by Timmy Nguyen on 12/31/23.
//

import UIKit

class WorkoutTableViewCell: UITableViewCell {
    static let reuseIdentifier = "WorkoutCell"
    
    var titleLabel: UILabel!
    var descriptionLabel: UILabel!
    var iconImageView: UIImageView!

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        accessoryType = .disclosureIndicator
        setupView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func update(template: Template) {
        titleLabel.text = template.title // "\(template.title) \(template.index)"
        let firstLetter =  template.title.first?.lowercased() ?? "a"
        var config = UIImage.SymbolConfiguration(pointSize: 35)
        config = config.applying(UIImage.SymbolConfiguration(paletteColors: [.white, Settings.shared.accentColor.color]))
        iconImageView.image = UIImage(systemName: "\(firstLetter).circle.fill", withConfiguration: config)
        descriptionLabel.text = template.templateExercises.map { $0.name }.joined(separator: ", ")
    }

//    func update(with workout: Workout) {
//        let exercises = workout.getExercises()
//        let title = workout.title
//        titleLabel.text = title
//        let firstLetter = title.first?.lowercased() ?? "a"
//        var config = UIImage.SymbolConfiguration(pointSize: 35)
//        config = config.applying(UIImage.SymbolConfiguration(paletteColors: [.white, Settings.shared.accentColor.color]))
//        iconImageView.image = UIImage(systemName: "\(firstLetter).circle.fill", withConfiguration: config)
//        descriptionLabel.text = exercises.map { $0.name }.joined(separator: ", ")
//    }
    
    private func setupView() {
        setupTitleLabel()
        setupDescriptionLabel()
        setupIconImageView()
        
        let vstack = UIStackView(arrangedSubviews: [titleLabel, descriptionLabel])
        vstack.translatesAutoresizingMaskIntoConstraints = false
        vstack.axis = .vertical
        
        let hstack = UIStackView(arrangedSubviews: [iconImageView, vstack])
        hstack.translatesAutoresizingMaskIntoConstraints = false
        hstack.axis = .horizontal
        hstack.alignment = .center
        hstack.spacing = 8

        contentView.addSubview(hstack)
        
        NSLayoutConstraint.activate([
            hstack.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            hstack.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8),
            hstack.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            hstack.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
        ])
    }
    
    private func setupTitleLabel() {
        titleLabel = UILabel()
        titleLabel.font = .preferredFont(forTextStyle: .headline)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.numberOfLines = 1
    }
    
    private func setupDescriptionLabel() {
        descriptionLabel = UILabel()
        descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        descriptionLabel.text = "Exercise A, Exercise B, Exercise C"
        descriptionLabel.font = UIFont.preferredFont(forTextStyle: .subheadline)
        descriptionLabel.textColor = .secondaryLabel
        descriptionLabel.numberOfLines = 1
    }
    
    private func setupIconImageView() {
        iconImageView = UIImageView(image: UIImage(systemName: "a.circle.fill"))
        iconImageView.translatesAutoresizingMaskIntoConstraints = false
        iconImageView.contentMode = .scaleAspectFit
        iconImageView.setContentHuggingPriority(.required, for: .horizontal)
        iconImageView.setContentCompressionResistancePriority(.required, for: .horizontal)
    }
}

#Preview("WorkoutTableViewCell") {
    let cell = WorkoutTableViewCell()
    cell.titleLabel.text = "Workout A"
    return cell
}
