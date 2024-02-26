//
//  ExerciseFooterView.swift
//  WorkoutApp
//
//  Created by Timmy Nguyen on 2/15/24.
//

import UIKit

class PaddedLabel: UILabel {
    let top: CGFloat
    let left: CGFloat
    let bottom: CGFloat
    let right: CGFloat

    init(top: CGFloat = 0, left: CGFloat = 0, bottom: CGFloat = 0, right: CGFloat = 0) {
        self.top = top
        self.left = left
        self.bottom = bottom
        self.right = right
        super.init(frame: .zero)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func drawText(in rect: CGRect) {
        let insets = UIEdgeInsets(top: top, left: left, bottom: bottom, right: right)
        super.drawText(in: rect.inset(by: insets))
    }
}

class ExerciseHeaderView: UIView {

    var titleLabel: UILabel = {
        let label = PaddedLabel()
        label.textAlignment = .left
//        label.backgroundColor = .blue
        label.font = UIFont.systemFont(ofSize: 24, weight: .bold)
//        label.font = UIFont.
        return label
    }()
    
    var setLabel: UILabel = {
        let label = UILabel()
        label.text = "Set"
        label.textAlignment = .center
        label.textColor = .secondaryLabel
//        label.backgroundColor = .red
        return label
    }()
    
    var previousLabel: UILabel = {
        let label = UILabel()
        label.text = "Previous"
        label.textAlignment = .center
        label.textColor = .secondaryLabel
//        label.backgroundColor = .orange
        return label
    }()
    
    var weightLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.textColor = .secondaryLabel
//        label.backgroundColor = .yellow
        label.text = "lbs"
        return label
    }()
    
    var repsLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.textColor = .secondaryLabel
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
        vstack.spacing = 8
        vstack.translatesAutoresizingMaskIntoConstraints = false
//        vstack.backgroundColor = .purple
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
        
//        backgroundColor = .gray
        
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
