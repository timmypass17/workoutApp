//
//  LogSectionHeaderView.swift
//  WorkoutApp
//
//  Created by Timmy Nguyen on 1/18/24.
//

import UIKit

class LogSectionHeaderView: UIView {

    private let monthYearLabel: UILabel = {
        let label = UILabel()
        label.font = .preferredFont(forTextStyle: .caption1)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let workoutCountLabel: UILabel = {
        let label = UILabel()
        label.font = .preferredFont(forTextStyle: .caption1)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let container: UIStackView = {
        let hstack = UIStackView()
        hstack.axis = .horizontal
        hstack.translatesAutoresizingMaskIntoConstraints = false
        return hstack
    }()

    init(title: String, workoutCount: Int) {
        super.init(frame: .zero)
        monthYearLabel.text = title.uppercased()
        workoutCountLabel.text = workoutCount > 1 ? "\(workoutCount) Workouts" : "\(workoutCount) Workout"
        
        container.addArrangedSubview(monthYearLabel)
        container.addArrangedSubview(workoutCountLabel)
        
        addSubview(container)
        
        NSLayoutConstraint.activate([
            container.topAnchor.constraint(equalTo: topAnchor, constant: 4),
            container.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -4),
            container.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            container.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16)
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
