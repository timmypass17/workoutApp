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

protocol ExerciseHeaderViewDelegate: AnyObject {
    func exerciseHeaderView(_ sender: ExerciseHeaderView, didRenameExercise name: String, viewForHeaderInSection section: Int)
}

class ExerciseHeaderView: UIView {

    var titleLabel: UILabel = {
        let label = PaddedLabel()
        label.textAlignment = .left
        label.font = UIFont.systemFont(ofSize: 24, weight: .bold)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    var editButton: UIButton = {
        let button = UIButton()
        var config = UIButton.Configuration.plain()
        config.image = UIImage(systemName: "square.and.pencil")
        config.contentInsets = NSDirectionalEdgeInsets(top: 0, leading:0 , bottom: 0, trailing: 0)
        button.configuration = config
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    var setLabel: UILabel = {
        let label = UILabel()
        label.text = "Set"
        label.textAlignment = .center
        label.textColor = .secondaryLabel
        return label
    }()
    
    var previousLabel: UILabel = {
        let label = UILabel()
        label.text = "Previous"
        label.textAlignment = .center
        label.textColor = .secondaryLabel
        return label
    }()
    
    var weightLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.textColor = .secondaryLabel
        label.text = Settings.shared.weightUnit.rawValue
        return label
    }()
    
    var repsLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.textColor = .secondaryLabel
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
    
    var titleView: UIView = {
        let view = UIView()
        return view
    }()
    
    var title: String
    let section: Int
    weak var delegate: ExerciseHeaderViewDelegate?
    
    init(title: String, section: Int) {
        self.title = title
        self.section = section
        super.init(frame: .zero)
        titleLabel.text = title
        editButton.addTarget(self, action: #selector(editButtonTapped), for: .primaryActionTriggered)
        
        titleView.addSubview(titleLabel)
        titleView.addSubview(editButton)

        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: titleView.topAnchor),
            titleLabel.bottomAnchor.constraint(equalTo: titleView.bottomAnchor),
            titleLabel.leadingAnchor.constraint(equalTo: titleView.leadingAnchor)
        ])
        
        NSLayoutConstraint.activate([
            editButton.topAnchor.constraint(equalTo: titleView.topAnchor),
            editButton.bottomAnchor.constraint(equalTo: titleView.bottomAnchor),
            editButton.leadingAnchor.constraint(equalTo: titleLabel.trailingAnchor, constant: 8)
        ])
        
        hstack.addArrangedSubview(setLabel)
        hstack.addArrangedSubview(previousLabel)
        hstack.addArrangedSubview(weightLabel)
        hstack.addArrangedSubview(repsLabel)
        
        vstack.addArrangedSubview(titleView)
        vstack.addArrangedSubview(hstack)
        
        addSubview(vstack)
                
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
    
    @objc func editButtonTapped() {
        let alert = UIAlertController(title: "Rename Exercise", message: "Enter new exercise below", preferredStyle: .alert)
        
        alert.addTextField { textField in
            textField.placeholder = "Ex. Bench Press"
            textField.autocapitalizationType = .sentences
            let textChangedAction = UIAction { _ in
                alert.actions[1].isEnabled = textField.text!.count > 0
            }
            textField.addAction(textChangedAction, for: .allEditingEvents)
        }
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.addAction(UIAlertAction(title: "Save", style: .default, handler: { _ in
            guard let exercise = alert.textFields?[0].text else { return }
            self.title = exercise
            self.delegate?.exerciseHeaderView(self, didRenameExercise: exercise, viewForHeaderInSection: self.section)
        }))
        
        self.window?.rootViewController?.present(alert, animated: true, completion: nil)
    }
    
}
