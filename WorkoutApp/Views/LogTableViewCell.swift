//
//  LogTableViewCell.swift
//  WorkoutApp
//
//  Created by Timmy Nguyen on 1/17/24.
//

import UIKit

class LogTableViewCell: UITableViewCell {
    static let reuseIdentifier = "LogTableViewCell"
    
    private let weekdayLabel: UILabel = {
        let label = UILabel()
        label.font = .preferredFont(forTextStyle: .caption1)
        label.textColor = .secondaryLabel
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let dayLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let workoutLabel: UILabel = {
        let label = UILabel()
        label.lineBreakMode = .byTruncatingTail
        label.numberOfLines = 1
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let exercisesLabel: UILabel = {
        let label = UILabel()
        label.font = .preferredFont(forTextStyle: .caption1)
        label.textColor = .secondaryLabel
        label.lineBreakMode = .byTruncatingTail
        // Setting the max number of allowed lines in sub-title to 3
        label.numberOfLines = 3
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let dateVStackView: UIStackView = {
        let vstack = UIStackView()
        vstack.axis = .vertical
        vstack.alignment = .center
        vstack.translatesAutoresizingMaskIntoConstraints = false
        return vstack
    }()
    
    private let workoutVStackView: UIStackView = {
        let vstack = UIStackView()
        vstack.axis = .vertical
        vstack.translatesAutoresizingMaskIntoConstraints = false
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
            dateVStackView.widthAnchor.constraint(equalToConstant: 50),
            dateVStackView.leadingAnchor.constraint(equalTo: containerHStackView.leadingAnchor, constant: 8)
        ])
        
        NSLayoutConstraint.activate([
            containerHStackView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            containerHStackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8),
            containerHStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 8),
            containerHStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -8),
        ])
                
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func update(with workout: Workout) {
        guard let exercises = workout.exercises?.array as? [Exercise],
              let createdAt = workout.createdAt
        else { return }
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "EEE"
        weekdayLabel.text = dateFormatter.string(from: createdAt)
        dayLabel.text = "\(Calendar.current.component(.day, from: createdAt))"
        workoutLabel.text = workout.title
        exercisesLabel.text = exercises
            .map { 
                let bestExerciseSet = ($0.exerciseSets?.array as! [ExerciseSet]).max(by: { Float($0.weight)! < Float($1.weight)!  })!
                let title = bestExerciseSet.exercise?.title ?? ""
                let sets = $0.exerciseSets?.count ?? 0
                let reps = bestExerciseSet.reps ?? ""
                let weight = bestExerciseSet.weightString
                return "\(sets)x\(reps) \(title) - \(weight) \(Settings.shared.weightUnit.rawValue)"
            }
            .joined(separator: "\n")
    }
}

