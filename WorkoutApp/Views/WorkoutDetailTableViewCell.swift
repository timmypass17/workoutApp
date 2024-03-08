//
//  WorkoutDetailTableViewCell.swift
//  WorkoutApp
//
//  Created by Timmy Nguyen on 1/11/24.
//

import UIKit
import SwiftUI

protocol WorkoutDetailTableViewCellDelegate: AnyObject {
    func workoutDetailTableViewCell(_ cell: WorkoutDetailTableViewCell, didUpdateExerciseSet exerciseSet: ExerciseSet)
    // Had to separte func because user typing focus disappears when pressing checkmark (Due to reloadsection)
    func workoutDetailTableViewCell(_ cell: WorkoutDetailTableViewCell, didTapCheckmarkForSet exerciseSet: ExerciseSet)
    func workoutDetailTableViewCell(_ cell: WorkoutDetailTableViewCell, nextButtonTapped: Bool)
    func workoutDetailTableViewCell(_ cell: WorkoutDetailTableViewCell, previousButtonTapped: Bool)
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
        textField.keyboardType = .decimalPad
        textField.borderStyle = .roundedRect
        textField.textAlignment = .center
        return textField
    }()
    
    var repsTextField: UITextField = {
        let textField = UITextField()
        textField.keyboardType = .decimalPad
        textField.borderStyle = .roundedRect
        textField.textAlignment = .center
        return textField
    }()
    
    var toolbar: UIToolbar = {
        let bar = UIToolbar(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 44))
        let doneButton = UIBarButtonItem(barButtonSystemItem: .close, target: self, action: #selector(doneButtonTapped))
        let leftButton = UIBarButtonItem(image: UIImage(systemName: "chevron.left"), style: .plain, target: self, action: #selector(previousButtonTapped))
        let rightButton = UIBarButtonItem(image: UIImage(systemName: "chevron.right"), style: .plain, target: self, action: #selector(nextButtonTapped))
        let minusButton = UIBarButtonItem(image: UIImage(systemName: "minus"), style: .plain, target: self, action: #selector(decrement))
        let plusButton = UIBarButtonItem(image: UIImage(systemName: "plus"), style: .plain, target: self, action: #selector(increment))

        leftButton.tintColor = Settings.shared.accentColor.color
        rightButton.tintColor = Settings.shared.accentColor.color
        minusButton.tintColor = Settings.shared.accentColor.color
        plusButton.tintColor = Settings.shared.accentColor.color

        bar.items = [leftButton, .flexibleSpace(), rightButton, .flexibleSpace(), minusButton, .flexibleSpace(), plusButton, .flexibleSpace(), doneButton]
        bar.sizeToFit()
        return bar
    }()
    
    var container: UIStackView = {
        let hstack = UIStackView()
        hstack.axis = .horizontal
        hstack.spacing = 8
        hstack.distribution = .fill
        hstack.translatesAutoresizingMaskIntoConstraints = false
        return hstack
    }()
    

    weak var delegate: WorkoutDetailTableViewCellDelegate?
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
        
        weightTextField.inputAccessoryView = toolbar
        repsTextField.inputAccessoryView = toolbar
        
        let setTextFieldChangedAction = UIAction { [self] _ in
            set.weight = weightTextField.text ?? ""
            set.reps = repsTextField.text ?? ""
            if weightTextField.text == "" || repsTextField.text == "" {
                set.isComplete = false
                setButton.isSelected = false
            }
            delegate?.workoutDetailTableViewCell(self, didUpdateExerciseSet: set)
        }
        
        let checkmarkToggleAction = UIAction { [self] _ in
            set.isComplete = setButton.isSelected
            if weightTextField.text == "" {
                let weight = Float(weightTextField.placeholder ?? "0") ?? 0.0
                set.weight = String(format: "%g", weight)
            }
            if repsTextField.text == "" {
                let reps = Int(repsTextField.placeholder ?? "0") ?? 0
                set.reps = String(reps)
            }
            if Settings.shared.enableHaptic {
                let generator = UIImpactFeedbackGenerator(style: .heavy)
                generator.impactOccurred()
            }
            delegate?.workoutDetailTableViewCell(self, didTapCheckmarkForSet: set)
        }
        setButton.addAction(checkmarkToggleAction, for: .primaryActionTriggered)
        weightTextField.addAction(setTextFieldChangedAction, for: .editingChanged)
        repsTextField.addAction(setTextFieldChangedAction, for: .editingChanged)
        
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
    
    func update(with workout: Workout, for indexPath: IndexPath, previousWeights: [(String, String)]) {
        self.workout = workout
        let exercise = workout.getExercise(at: indexPath.section)
        self.set = exercise.getExerciseSet(at: indexPath.row)
        setButton.isSelected = set.isComplete
        weightTextField.text = set.weightString
        repsTextField.text = set.reps
        
        // Normal
        let indexOfCurrentSet = exercise.getExerciseSets().firstIndex { !$0.isComplete } ?? exercise.getExerciseSets().count
        let isCurrentSet = indexPath.row == indexOfCurrentSet
        var config = UIImage.SymbolConfiguration(pointSize: 30)
        let colors: [UIColor] = isCurrentSet ? [Color.ui.cellNo, Settings.shared.accentColor.color] : [.systemGray, .systemGray]
        config = config.applying(UIImage.SymbolConfiguration(paletteColors: colors))
        setButton.setImage(UIImage(systemName: "\(indexPath.row + 1).circle", withConfiguration: config), for: .normal)

        // Selected
        var selectedConfig = UIImage.SymbolConfiguration(pointSize: 30)
        selectedConfig = selectedConfig.applying(UIImage.SymbolConfiguration(paletteColors: [.white, Settings.shared.accentColor.color]))
        setButton.setImage(UIImage(systemName: "\(indexPath.row + 1).circle.fill", withConfiguration: selectedConfig), for: .selected)

        if previousWeights.count > 0 {
            // Use previous weight
            if indexPath.row < previousWeights.count {
                let (previousWeight, previousReps) = previousWeights[indexPath.row]
                previousLabel.text = previousWeight
                weightTextField.placeholder = previousWeight
                repsTextField.placeholder = previousReps
            }
            else {
                // Out of bounds, use last weight instead
                if let (previousWeight, previousReps) = previousWeights.last {
                    previousLabel.text = "-"
                    weightTextField.placeholder = previousWeight
                    repsTextField.placeholder = previousReps
                }
            }
        } else {
            // No previous weight, use default values
            previousLabel.text = "-"
            weightTextField.placeholder = Settings.shared.weightUnit == .lbs ? "135" : "60"
            repsTextField.placeholder = "5"
        }
    }
    
    @objc func doneButtonTapped() {
        endEditing(true)
    }
    
    @objc func previousButtonTapped() {
        delegate?.workoutDetailTableViewCell(self, previousButtonTapped: true)
    }
    
    @objc func nextButtonTapped() {
        delegate?.workoutDetailTableViewCell(self, nextButtonTapped: true)
    }
    
    @objc func increment() {
        if weightTextField.isFirstResponder {
            var weight: Float
            if set.weight == "" {
                weight = Float(weightTextField.placeholder ?? "0") ?? 0.0
            } else {
                weight = Float(set.weight ?? "0") ?? 0.0
            }
            weight += Settings.shared.weightIncrement
            set.weight = String(format: "%g", weight)
            weightTextField.text = String(format: "%g", weight)
        }
        else if repsTextField.isFirstResponder {
            var reps: Int
            if set.reps == "" {
                reps = Int(repsTextField.placeholder ?? "0") ?? 0
            } else {
                reps = Int(set.reps ?? "0") ?? 0
            }
            reps += 1
            set.reps = String(reps)
            repsTextField.text = String(reps)
        }
        if Settings.shared.enableHaptic {
            let generator = UIImpactFeedbackGenerator(style: .light)
            generator.impactOccurred()
        }
    }
    
    @objc func decrement() {
        if weightTextField.isFirstResponder {
            var weight: Float
            if set.weight == "" {
                weight = Float(weightTextField.placeholder ?? "0") ?? 0.0
            } else {
                weight = Float(set.weight ?? "0") ?? 0.0
            }
            weight = max(weight - Settings.shared.weightIncrement, 0)
            set.weight = String(format: "%g", weight)
            weightTextField.text = String(format: "%g", weight)
        }
        else if repsTextField.isFirstResponder {
            var reps: Int
            if set.reps == "" {
                reps = Int(repsTextField.placeholder ?? "0") ?? 0
            } else {
                reps = Int(set.reps ?? "0") ?? 0
            }
            reps = max(reps - 1, 0)
            set.reps = String(reps)
            repsTextField.text = String(reps)
        }
        if Settings.shared.enableHaptic {
            let generator = UIImpactFeedbackGenerator(style: .light)
            generator.impactOccurred()
        }
    }
}

#Preview {
    WorkoutDetailTableViewCell()
}
