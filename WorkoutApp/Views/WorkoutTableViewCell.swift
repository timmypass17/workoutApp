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
    
    func update(with workoutPlan: WorkoutPlan) {
        guard let title = workoutPlan.title,
              let exercises = workoutPlan.planItems?.array as? [PlanItem]
        else { return }
        titleLabel.text = title
        let firstLetter = title.first!.lowercased()
        iconImageView.image = UIImage(systemName: "\(firstLetter).circle.fill")
//        descriptionLabel.text = exercises[0].title
        descriptionLabel.text = exercises.map { $0.title! }.joined(separator: ", ")
    }
    
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
        hstack.alignment = .leading
        hstack.spacing = 8

        contentView.addSubview(hstack)
        
        NSLayoutConstraint.activate([
            hstack.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            hstack.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8),
            hstack.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 8),
            hstack.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -8),
        ])
    }
    
    private func setupTitleLabel() {
        titleLabel = UILabel()
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.numberOfLines = 1
    }
    
    private func setupDescriptionLabel() {
        descriptionLabel = UILabel()
        descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        descriptionLabel.text = "Exercise A, Exercise B, Exercise C"
        descriptionLabel.font = UIFont.preferredFont(forTextStyle: .caption1)
        descriptionLabel.textColor = .secondaryLabel
        descriptionLabel.numberOfLines = 1
    }
    
    private func setupIconImageView() {
        iconImageView = UIImageView(image: UIImage(systemName: "a.circle.fill"))
        iconImageView.translatesAutoresizingMaskIntoConstraints = false
        iconImageView.contentMode = .scaleAspectFit
        NSLayoutConstraint.activate([
            iconImageView.widthAnchor.constraint(equalToConstant: 35),
            iconImageView.heightAnchor.constraint(equalToConstant: 35)
        ])
    }
}

#Preview("WorkoutTableViewCell") {
    let cell = WorkoutTableViewCell()
    cell.titleLabel.text = "Workout A"
    return cell
}
