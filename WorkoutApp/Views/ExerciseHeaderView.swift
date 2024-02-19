//
//  ExerciseFooterView.swift
//  WorkoutApp
//
//  Created by Timmy Nguyen on 2/15/24.
//

import UIKit

class ExerciseHeaderView: UIView {

    var titleLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .left
//        label.backgroundColor = .blue
        label.font = UIFont.systemFont(ofSize: 20, weight: .semibold)
        return label
    }()
    
    var setLabel: UILabel = {
        let label = UILabel()
        label.text = "Set"
        label.textAlignment = .center
//        label.backgroundColor = .red
        return label
    }()
    
    var previousLabel: UILabel = {
        let label = UILabel()
        label.text = "Previous"
        label.textAlignment = .center
//        label.backgroundColor = .orange
        return label
    }()
    
    var weightLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
//        label.backgroundColor = .yellow
        label.text = "lbs"
        return label
    }()
    
    var repsLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
//        label.backgroundColor = .green
        label.text = "Reps"
        return label
    }()
    
    var hstack: UIStackView = {
        let hstack = UIStackView()
        hstack.axis = .horizontal
        hstack.spacing = 8
        hstack.distribution = .fill
        hstack.translatesAutoresizingMaskIntoConstraints = false
        return hstack
    }()
    
    var vstack: UIStackView = {
        let vstack = UIStackView()
        vstack.axis = .vertical
        vstack.translatesAutoresizingMaskIntoConstraints = false
//        vstack.backgroundColor = .gray
        return vstack
    }()
    
    init(title: String) {
        super.init(frame: .zero)
        titleLabel.text = title
        hstack.addArrangedSubview(setLabel)
        hstack.addArrangedSubview(previousLabel)
        hstack.addArrangedSubview(weightLabel)
        hstack.addArrangedSubview(repsLabel)
        
        vstack.addArrangedSubview(titleLabel)
        vstack.addArrangedSubview(hstack)
        
        addSubview(vstack)
        
//        backgroundColor = .white
        
        NSLayoutConstraint.activate([
            vstack.topAnchor.constraint(equalTo: topAnchor, constant: 8),
            vstack.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -8),
            vstack.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 8),
            vstack.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -8),
        ])
        
        // Percentage width (to stop textfield from expanding)
        NSLayoutConstraint.activate([
            previousLabel.widthAnchor.constraint(equalTo: widthAnchor, multiplier: 0.25),
            weightLabel.widthAnchor.constraint(equalTo: widthAnchor, multiplier: 0.25),
            repsLabel.widthAnchor.constraint(equalTo: widthAnchor, multiplier: 0.25),
        ])
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
