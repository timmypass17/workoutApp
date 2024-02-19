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
            set.weight = weightTextField.text
            set.reps = repsTextField.text
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
    
    func update(with workout: Workout, for indexPath: IndexPath, previousExercise: Exercise?) {
        self.workout = workout
        let exercise = workout.getExercise(at: indexPath.section)
        self.set = exercise.getExerciseSet(at: indexPath.row)
        setButton.isSelected = set.isComplete
        weightTextField.text = set.weight
        repsTextField.text = set.reps
        
        // Normal
        let indexOfCurrentSet = exercise.getExerciseSets().firstIndex { !$0.isComplete } ?? exercise.getExerciseSets().count
        let isCurrentSet = indexPath.row == indexOfCurrentSet
        var config = UIImage.SymbolConfiguration(pointSize: 30)
        let colors: [UIColor] = isCurrentSet ? [.white, .systemBlue] : [.gray, .gray]
        config = config.applying(UIImage.SymbolConfiguration(paletteColors: colors))
        setButton.setImage(UIImage(systemName: "\(indexPath.row + 1).circle", withConfiguration: config), for: .normal)

        // Selected
        var selectedConfig = UIImage.SymbolConfiguration(pointSize: 30)
        selectedConfig = selectedConfig.applying(UIImage.SymbolConfiguration(paletteColors: [.white, .systemBlue]))
        setButton.setImage(UIImage(systemName: "\(indexPath.row + 1).circle.fill", withConfiguration: selectedConfig), for: .selected)

        if let previousExercise {
            let setCount = previousExercise.exerciseSets!.count
            let pos = min(indexPath.row, setCount - 1)  // only use index that are within previousExercise count
            let previousSet = previousExercise.getExerciseSet(at: pos)
            previousLabel.text = indexPath.row < setCount ? previousSet.weight : "-"
            weightTextField.placeholder = previousSet.weight
            repsTextField.placeholder = previousSet.reps
        } else {
            previousLabel.text = "-"
            weightTextField.placeholder = "135"
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
            weight += 5
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
    }
    
    @objc func decrement() {
        if weightTextField.isFirstResponder {
            var weight: Float
            if set.weight == "" {
                weight = Float(weightTextField.placeholder ?? "0") ?? 0.0
            } else {
                weight = Float(set.weight ?? "0") ?? 0.0
            }
            weight = max(weight - 5, 0)
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
    }
}

#Preview {
    WorkoutDetailTableViewCell()
}
