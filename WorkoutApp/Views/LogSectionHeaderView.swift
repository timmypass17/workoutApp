//
//  LogSectionHeaderView.swift
//  WorkoutApp
//
//  Created by Timmy Nguyen on 1/18/24.
//

import UIKit

class LogSectionHeaderView: UITableViewHeaderFooterView {

    static let reuseIdentifier = "LogSectionHeaderView"
    
    private let monthYearLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.preferredFont(forTextStyle: .footnote)
        label.textColor = .secondaryLabel
        return label
    }()
    
    let workoutCountLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.preferredFont(forTextStyle: .footnote)
        label.textColor = .secondaryLabel
        return label
    }()

    private let container: UIStackView = {
        let hstack = UIStackView()
        hstack.axis = .horizontal
        hstack.translatesAutoresizingMaskIntoConstraints = false
        return hstack
    }()

    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        
        container.addArrangedSubview(monthYearLabel)
        container.addArrangedSubview(workoutCountLabel)
        
        contentView.addSubview(container)
        
        NSLayoutConstraint.activate([
            container.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 4),
            container.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -4),
            container.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            container.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16)
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func update(dateMonth: Date, workoutCount: Int) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMMM yyyy"
        let dateMonthString = dateFormatter.string(from: dateMonth)
        
        monthYearLabel.text = dateMonthString.uppercased()
        workoutCountLabel.text = workoutCount > 1 ? "\(workoutCount) Workouts" : "\(workoutCount) Workout"
    }
}
