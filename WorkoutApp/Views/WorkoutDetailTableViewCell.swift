//
//  WorkoutDetailTableViewCell.swift
//  WorkoutApp
//
//  Created by Timmy Nguyen on 1/11/24.
//

import UIKit
import SwiftUI

protocol WorkoutDetailTableViewCellDelegate: AnyObject {
    func workoutDetailTableViewCell(_ cell: WorkoutDetailTableViewCell, didTapSetButton: Bool)
    func workoutDetailTableViewCell(_ cell: WorkoutDetailTableViewCell, weightTextDidChange weightText: String)
    func workoutDetailTableViewCell(_ cell: WorkoutDetailTableViewCell, repsTextDidChange repsText: String)
    func workoutDetailTableViewCell(_ cell: WorkoutDetailTableViewCell, didTapNextButton: Bool)
    func workoutDetailTableViewCell(_ cell: WorkoutDetailTableViewCell, didTapPreviousButton: Bool)
    func workoutDetailTableViewCell(_ cell: WorkoutDetailTableViewCell, didTapIncrementWeightButton: Bool)
    func workoutDetailTableViewCell(_ cell: WorkoutDetailTableViewCell, didTapDecrementWeightButton: Bool)
    func workoutDetailTableViewCell(_ cell: WorkoutDetailTableViewCell, didTapIncrementRepsButton: Bool)
    func workoutDetailTableViewCell(_ cell: WorkoutDetailTableViewCell, didTapDecrementRepsButton: Bool)
}

class WorkoutDetailTableViewCell: UITableViewCell {
    static let reuseIdentifier = "WorkoutDetailCell"
    
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

        setupToolbar()
        
        setButton.addAction(didTapCheckmark(), for: .primaryActionTriggered)
        weightTextField.addAction(weightTextFieldDidChange(), for: .editingChanged)
        repsTextField.addAction(repsTextFieldDidChange(), for: .editingChanged)
        
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
    
    private func setupToolbar() {
        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        
        
        let configuration = UIImage.SymbolConfiguration(pointSize: 20)
            .applying(UIImage.SymbolConfiguration(hierarchicalColor: .label))
        let closeImage = UIImage(systemName: "xmark.circle.fill", withConfiguration: configuration)
        
        let closeButton = UIBarButtonItem(image: closeImage, primaryAction: didTapCloseButton())
        let previousButton = UIBarButtonItem(image: UIImage(systemName: "chevron.left"), primaryAction: didTapPreviousButton())
        let nextButton = UIBarButtonItem(image: UIImage(systemName: "chevron.right"), primaryAction: didTapNextButton())
        let decrementButton = UIBarButtonItem(image: UIImage(systemName: "minus"), primaryAction: didTapDecrementButton())
        let incrementButton = UIBarButtonItem(image: UIImage(systemName: "plus"), primaryAction: didTapIncrementButton())

        let buttons = [previousButton, nextButton, decrementButton, incrementButton]
        buttons.forEach { $0.tintColor = Settings.shared.selectedAccentColor }

        toolbar.items = [
            previousButton,
            .flexibleSpace(),
            nextButton,
            .flexibleSpace(),
            decrementButton,
            .flexibleSpace(),
            incrementButton,
            .flexibleSpace(),
            closeButton
        ]

        weightTextField.inputAccessoryView = toolbar
        repsTextField.inputAccessoryView = toolbar
    }
    
    func update(exerciseSet: ExerciseSet, templateExercise: TemplateExercise? = nil) {
        updateSetButton(exerciseSet: exerciseSet)
        
        let weightUnit = Settings.shared.weightUnit
        let weightString = weightUnit == .lbs ? exerciseSet.weight.lbsString : exerciseSet.weight.kgString
        weightTextField.text = exerciseSet.weight >= 0 ? weightString : ""
        repsTextField.text = exerciseSet.reps >= 0 ? exerciseSet.reps.description : ""
        
        // Use previous set (or template) for placeholders
        if let previousSet = exerciseSet.previousSet {
            let previousWeightString = weightUnit == .lbs ? previousSet.weight.lbsString : previousSet.weight.kgString
            previousLabel.text = previousWeightString
            weightTextField.placeholder = previousWeightString
            repsTextField.placeholder = templateExercise?.reps.description ?? previousSet.reps.description
        } else {
            previousLabel.text = "-"
            weightTextField.placeholder = weightUnit == .lbs ? "45" : "20"
            repsTextField.placeholder = templateExercise?.reps.description ?? ""    // should never be empty
        }
    }
    
    func updateSetButton(exerciseSet: ExerciseSet) {
        setButton.isSelected = exerciseSet.isComplete
        let currentSetNumberColor: UIColor = traitCollection.userInterfaceStyle == .light ? (Settings.shared.selectedAccentColor).withAlphaComponent(0.75) : .white
        let currentSetBorderColor: UIColor = traitCollection.userInterfaceStyle == .light ? Settings.shared.selectedAccentColor.withAlphaComponent(0.75) : Settings.shared.selectedAccentColor
        let currentSetcolors: [UIColor] = [currentSetNumberColor, currentSetBorderColor]
        let unselectedColors: [UIColor] = [Color.ui.unselectedSetNumber, Color.ui.unselectedSetNumber]
        let selectedColors: [UIColor] = [.white, Settings.shared.selectedAccentColor]
        
        var config = UIImage.SymbolConfiguration(pointSize: 30)
        config = config.applying(UIImage.SymbolConfiguration(paletteColors: exerciseSet.isCurrentSet ? currentSetcolors : unselectedColors))
        setButton.setImage(UIImage(systemName: "\(exerciseSet.index + 1).circle", withConfiguration: config), for: .normal)

        var selectedConfig = UIImage.SymbolConfiguration(pointSize: 30)
        selectedConfig = selectedConfig.applying(UIImage.SymbolConfiguration(paletteColors: selectedColors))
        setButton.setImage(UIImage(systemName: "\(exerciseSet.index + 1).circle.fill", withConfiguration: selectedConfig), for: .selected)

    }
    
    func didTapCheckmark() -> UIAction {
        return UIAction { [self] _ in
            delegate?.workoutDetailTableViewCell(self, didTapSetButton: setButton.isSelected)
        }
    }
    
    func weightTextFieldDidChange() -> UIAction {
        return UIAction { _ in
            self.delegate?.workoutDetailTableViewCell(self, weightTextDidChange: self.weightTextField.text ?? "")
        }
    }
    
    func repsTextFieldDidChange() -> UIAction {
        return UIAction { _ in
            self.delegate?.workoutDetailTableViewCell(self, repsTextDidChange: self.repsTextField.text ?? "")
        }
    }
        
    func didTapCloseButton() -> UIAction {
        return UIAction { _ in
            if Settings.shared.enableHaptic {
                let generator = UIImpactFeedbackGenerator(style: .light)
                generator.impactOccurred()
            }
            
            self.endEditing(true)
        }
    }
        
    func didTapPreviousButton() -> UIAction {
        return UIAction { _ in
            if Settings.shared.enableHaptic {
                let generator = UIImpactFeedbackGenerator(style: .light)
                generator.impactOccurred()
            }
            
            self.delegate?.workoutDetailTableViewCell(self, didTapPreviousButton: true)
        }
    }
    
    func didTapNextButton() -> UIAction {
        return UIAction { _ in
            if Settings.shared.enableHaptic {
                let generator = UIImpactFeedbackGenerator(style: .light)
                generator.impactOccurred()
            }
            
            self.delegate?.workoutDetailTableViewCell(self, didTapNextButton: true)
        }
    }
    
    func didTapDecrementButton() -> UIAction {
        return UIAction { _ in
            if Settings.shared.enableHaptic {
                let generator = UIImpactFeedbackGenerator(style: .light)
                generator.impactOccurred()
            }
            
            if self.weightTextField.isFirstResponder {
                self.delegate?.workoutDetailTableViewCell(self, didTapDecrementWeightButton: true)
            } else if self.repsTextField.isFirstResponder {
                self.delegate?.workoutDetailTableViewCell(self, didTapDecrementRepsButton: true)
            }
        }
    }
    
    func didTapIncrementButton() -> UIAction {
        return UIAction { _ in
            if Settings.shared.enableHaptic {
                let generator = UIImpactFeedbackGenerator(style: .light)
                generator.impactOccurred()
            }
            
            if self.weightTextField.isFirstResponder {
                self.delegate?.workoutDetailTableViewCell(self, didTapIncrementWeightButton: true)
            } else if self.repsTextField.isFirstResponder {
                self.delegate?.workoutDetailTableViewCell(self, didTapIncrementRepsButton: true)
            }
        }
    }
}

#Preview {
    WorkoutDetailTableViewCell()
}

extension Double {
    /// Rounds the double to decimal places value
    func rounded(toPlaces places:Int) -> Double {
        let divisor = pow(10.0, Double(places))
        return (self * divisor).rounded() / divisor
    }
}
