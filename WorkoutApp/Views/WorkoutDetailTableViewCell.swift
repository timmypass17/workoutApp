//
//  WorkoutDetailTableViewCell.swift
//  WorkoutApp
//
//  Created by Timmy Nguyen on 1/11/24.
//

import UIKit

protocol WorkoutDetailTableViewCellDelegate: AnyObject {
    func workoutDetailTableViewCell(_ cell: WorkoutDetailTableViewCell, didUpdateExerciseSet exerciseSet: ExerciseSet)
}

class WorkoutDetailTableViewCell: UITableViewCell {
    static let reuseIdentifier = "WorkoutDetailCell"

    var exerciseSet: ExerciseSet!
    
    var setButton: UIButton = {
        let button = UIButton()
        var config = UIImage.SymbolConfiguration(pointSize: 30)
        config = config.applying(UIImage.SymbolConfiguration(paletteColors: [.systemBlue, .white]))
        button.setImage(UIImage(systemName: "circle", withConfiguration: config), for: .normal)
        button.changesSelectionAsPrimaryAction = true
        return button
    }()
    
    var previousLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        return label
    }()
    
    var weightTextField: UITextField = {
        let textField = UITextField()
        textField.borderStyle = .roundedRect
        textField.textAlignment = .center
        return textField
    }()
    
    var repsTextField: UITextField = {
        let textField = UITextField()
        textField.borderStyle = .roundedRect
        textField.textAlignment = .center
        return textField
    }()
    
    weak var delegate: WorkoutDetailTableViewCellDelegate?
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
        
        let exerciseSetChangedAction = UIAction { [self] _ in
            exerciseSet.isComplete = setButton.isSelected
            exerciseSet.weight = weightTextField.text
            exerciseSet.reps = repsTextField.text
            delegate?.workoutDetailTableViewCell(self, didUpdateExerciseSet: exerciseSet)
        }

        setButton.addAction(exerciseSetChangedAction, for: .primaryActionTriggered)
        weightTextField.addAction(exerciseSetChangedAction, for: .allEditingEvents)
        repsTextField.addAction(exerciseSetChangedAction, for: .allEditingEvents)
        

        let hstack = UIStackView(arrangedSubviews: [setButton, previousLabel, weightTextField, repsTextField])
//        hstack.distribution = .fillProportionally
        hstack.spacing = 8
        hstack.translatesAutoresizingMaskIntoConstraints = false
        
        contentView.addSubview(hstack)
        
        NSLayoutConstraint.activate([
            hstack.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            hstack.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8),
            hstack.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 8),
            hstack.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -8),
        ])
        
        // Percentage width (to stop textfield from expanding)
        NSLayoutConstraint.activate([
            previousLabel.widthAnchor.constraint(equalTo: contentView.widthAnchor, multiplier: 0.25),
            weightTextField.widthAnchor.constraint(equalTo: contentView.widthAnchor, multiplier: 0.25),
            repsTextField.widthAnchor.constraint(equalTo: contentView.widthAnchor, multiplier: 0.25),
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func update(with exerciseSet: ExerciseSet, for indexPath: IndexPath) {
        self.exerciseSet = exerciseSet
        guard let weight = exerciseSet.weight else { return }
        var config = UIImage.SymbolConfiguration(pointSize: 30)
        config = config.applying(UIImage.SymbolConfiguration(paletteColors: [.white, .systemBlue]))
        setButton.setImage(UIImage(systemName: "\(indexPath.row + 1).circle.fill", withConfiguration: config), for: .selected)
        
        weightTextField.text = weight
        repsTextField.text = exerciseSet.reps
        previousLabel.text = "-" // use previous weight
        
        weightTextField.placeholder = exerciseSet.weight // use previous weight
        repsTextField.placeholder = exerciseSet.reps
        
        setButton.isSelected = exerciseSet.isComplete
    }
    
}

#Preview {
    WorkoutDetailTableViewCell()
}
