//
//  LogTableViewCell.swift
//  WorkoutApp
//
//  Created by Timmy Nguyen on 1/17/24.
//

import UIKit

class LogViewCell: UITableViewCell {
    static let reuseIdentifier = "LogTableViewCell"
    
    private let weekdayLabel: UILabel = {
        let label = UILabel()
        label.font = .preferredFont(forTextStyle: .subheadline)
        label.numberOfLines = 1
        label.lineBreakMode = .byTruncatingTail
        label.textColor = .secondaryLabel
        return label
    }()
    
    private let dayLabel: UILabel = {
        let label = UILabel()
        label.font = .preferredFont(forTextStyle: .headline)
        label.numberOfLines = 1
        label.lineBreakMode = .byTruncatingTail
        return label
    }()
    
    private let workoutLabel: UILabel = {
        let label = UILabel()
        label.font = .preferredFont(forTextStyle: .headline)
        label.lineBreakMode = .byTruncatingTail
        label.numberOfLines = 1
        return label
    }()
    
    private let exercisesLabel: UILabel = {
        let label = UILabel()
        label.font = .preferredFont(forTextStyle: .subheadline)
        label.textColor = .secondaryLabel
        label.lineBreakMode = .byTruncatingTail
        label.numberOfLines = 3
        return label
    }()
    
    private let dateVStackView: UIStackView = {
        let vstack = UIStackView()
        vstack.axis = .vertical
        vstack.alignment = .center
        return vstack
    }()
    
    private let workoutVStackView: UIStackView = {
        let vstack = UIStackView()
        vstack.axis = .vertical
        return vstack
    }()
    
    private let containerHStackView: UIStackView = {
        let hstack = UIStackView()
        hstack.axis = .horizontal
        hstack.alignment = .top
        hstack.spacing = 8
        hstack.translatesAutoresizingMaskIntoConstraints = false
        return hstack
    }()
        
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        accessoryType = .disclosureIndicator

        dateVStackView.addArrangedSubview(weekdayLabel)
        dateVStackView.addArrangedSubview(dayLabel)

        workoutVStackView.addArrangedSubview(workoutLabel)
        workoutVStackView.addArrangedSubview(exercisesLabel)
        
        containerHStackView.addArrangedSubview(dateVStackView)
        containerHStackView.addArrangedSubview(workoutVStackView)
        
        contentView.addSubview(containerHStackView)
        
        NSLayoutConstraint.activate([
            dateVStackView.widthAnchor.constraint(equalToConstant: 50)
        ])
        
        NSLayoutConstraint.activate([
            containerHStackView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            containerHStackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8),
            containerHStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16), // extra to push dateview
            containerHStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -8),
        ])
                
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func update(workout: Workout) {
//        workout.printPrettyString()
        print("Update: \(workout.title) \(workout.createdAt_!.formatted(date: .abbreviated, time: .omitted))")
        guard let createdAt = workout.createdAt_ else { return }
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "EEE"
        weekdayLabel.text = dateFormatter.string(from: createdAt)
        dayLabel.text = "\(Calendar.current.component(.day, from: createdAt))"
        workoutLabel.text = workout.title
        exercisesLabel.text = workout.getExercises()
            .compactMap { exercise in
                guard let minReps = exercise.minReps,
                      let maxReps = exercise.maxReps
                else { return nil }
                                
                if minReps != maxReps {
                    return "\(exercise.getExerciseSets().count)x\(minReps)-\(maxReps) \(exercise.name)"
                } else {
                    return "\(exercise.getExerciseSets().count)x\(maxReps) \(exercise.name)"
                }
            }
            .joined(separator: "\n")
    }
}

