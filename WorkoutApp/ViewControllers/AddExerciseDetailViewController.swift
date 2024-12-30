//
//  AddExerciseDetailViewController.swift
//  BuiltDiff
//
//  Created by Timmy Nguyen on 12/29/24.
//

import UIKit

protocol AddExerciseDetailViewControllerDelegate: AnyObject {
    func addExerciseDetailViewControllerDelegate(_ viewController: AddExerciseDetailViewController, didAddExercise exercise: String, sets: Int, reps: Int)
    func addExerciseDetailViewControllerDelegate(_ viewController: AddExerciseDetailViewController, didDismiss: Bool)
}

class AddExerciseDetailViewController: ExerciseDetailViewController {

    weak var delegate: AddExerciseDetailViewControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Add", primaryAction: didTapAddButton())
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if navigationController?.isBeingDismissed ?? isBeingDismissed {
            delegate?.addExerciseDetailViewControllerDelegate(self, didDismiss: true)
        }
    }
    
    private func didTapAddButton() -> UIAction {
        return UIAction { [weak self] _ in
            guard let self else { return }
            let selectedSets = Int(setsData[pickerView.selectedRow(inComponent: 0)])
            let selectedReps = Int(repsData[pickerView.selectedRow(inComponent: 1)])
            delegate?.addExerciseDetailViewControllerDelegate(self, didAddExercise: exercise, sets: selectedSets, reps: selectedReps)
            self.navigationController?.dismiss(animated: true)
        }
    }
}
