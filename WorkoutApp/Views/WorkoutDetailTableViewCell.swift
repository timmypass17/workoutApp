//
//  WorkoutDetailTableViewCell.swift
//  WorkoutApp
//
//  Created by Timmy Nguyen on 1/11/24.
//

import UIKit

protocol WorkoutDetailTableViewCellDelegate: AnyObject {
    func workoutDetailTableViewCell(_ cell: WorkoutDetailTableViewCell, didUpdateExerciseSet exerciseSet: ExerciseSet)
    // Had to separte func because user typing focus disappears when pressing checkmark (Due to reloadsection)
    func workoutDetailTableViewCell(_ cell: WorkoutDetailTableViewCell, didTapCheckmarkForSet exerciseSet: ExerciseSet)
}

class WorkoutDetailTableViewCell: UITableViewCell {
    static let reuseIdentifier = "WorkoutDetailCell"

    var workout: Workout!
    var set: ExerciseSet!
    
    var setButton: UIButton = {
        let button = UIButton()
        button.changesSelectionAsPrimaryAction = true   // make button togglable
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
    
    var container: UIStackView = {
        let hstack = UIStackView()
        hstack.axis = .horizontal
        hstack.spacing = 8
        hstack.translatesAutoresizingMaskIntoConstraints = false
        return hstack
    }()
    
    weak var delegate: WorkoutDetailTableViewCellDelegate?
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
        
        let exerciseSetChangedAction = UIAction { [self] _ in
            set.weight = weightTextField.text
            set.reps = repsTextField.text
            delegate?.workoutDetailTableViewCell(self, didUpdateExerciseSet: set)
        }
        let checkmarkToggleAction = UIAction { [self] _ in
            set.isComplete = setButton.isSelected
            delegate?.workoutDetailTableViewCell(self, didTapCheckmarkForSet: set)
        }
        setButton.addAction(checkmarkToggleAction, for: .primaryActionTriggered)
        weightTextField.addAction(exerciseSetChangedAction, for: .editingChanged)
        repsTextField.addAction(exerciseSetChangedAction, for: .editingChanged)
        
        container.addArrangedSubview(setButton)
        container.addArrangedSubview(previousLabel)
        container.addArrangedSubview(weightTextField)
        container.addArrangedSubview(repsTextField)
        contentView.addSubview(container)
        
        NSLayoutConstraint.activate([
            container.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            container.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8),
            container.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 8),
            container.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -8),
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
    
    func update(with workout: Workout, for indexPath: IndexPath, previousExercise: Exercise?) {
        self.workout = workout
        let exercises = workout.getExercise(at: indexPath.section)
        self.set = exercises.getExerciseSet(at: indexPath.row)
        guard let weight = set.weight else { return }
        
        let indexOfCurrentSet = exercises.getExerciseSets().firstIndex { !$0.isComplete } ?? exercises.getExerciseSets().count
        let isCurrentSet = indexPath.row == indexOfCurrentSet
        let isPrevious = indexPath.row == indexOfCurrentSet - 1
        
        // Normal
        var config = UIImage.SymbolConfiguration(pointSize: 30)
        setButton.isEnabled = isPrevious || isCurrentSet
        var colors: [UIColor] = isCurrentSet ? [.white, .systemBlue] : [.white, .white]
        config = config.applying(UIImage.SymbolConfiguration(paletteColors: colors))
        setButton.setImage(UIImage(systemName: "\(indexPath.row + 1).circle", withConfiguration: config), for: .normal)

        // Selected
        var selectedConfig = UIImage.SymbolConfiguration(pointSize: 30)
        selectedConfig = selectedConfig.applying(UIImage.SymbolConfiguration(paletteColors: [.white, .systemBlue]))
        setButton.setImage(UIImage(systemName: "\(indexPath.row + 1).circle.fill", withConfiguration: selectedConfig), for: .selected)
        
        // Selected + Disabled
        var selectedDisabledConfig = UIImage.SymbolConfiguration(pointSize: 30)
        selectedDisabledConfig = selectedDisabledConfig.applying(UIImage.SymbolConfiguration(paletteColors: [.white, .systemBlue]))
        setButton.setImage(UIImage(systemName: "\(indexPath.row + 1).circle.fill", withConfiguration: selectedDisabledConfig), for: [.disabled, .selected])

        weightTextField.text = weight
        repsTextField.text = set.reps
        
        if let previousExercise {
            if indexPath.row < previousExercise.exerciseSets!.count {
//                print("\(indexPath) has previous exercise")
                let previousSet = previousExercise.getExerciseSet(at: indexPath.row)
                previousLabel.text = previousSet.weight
                weightTextField.placeholder = previousSet.weight // use previous weight
                repsTextField.placeholder = previousSet.reps
            } else {
                // Use latest set in current
//                print("\(indexPath) use previous weight, no previous for this index")
            }
        } else {
            let placeholderWeight = "-1" // 135
            let placeholderReps = "-1" // 5
            previousLabel.text = "-"
            weightTextField.placeholder = placeholderWeight
            repsTextField.placeholder = placeholderReps
        }
        
        setButton.isSelected = set.isComplete
    }
    
}

#Preview {
    WorkoutDetailTableViewCell()
}
