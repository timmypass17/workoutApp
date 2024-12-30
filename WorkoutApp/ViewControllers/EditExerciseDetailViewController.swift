//
//  EditExerciseDetailViewController.swift
//  BuiltDiff
//
//  Created by Timmy Nguyen on 12/29/24.
//

import UIKit

protocol EditExerciseDetailViewControllerDelegate: AnyObject {
    func editExerciseDetailViewControllerDelegate(_ viewController: EditExerciseDetailViewController, didUpdateExercise exercise: String, sets: Int, reps: Int)
    func editExerciseDetailViewControllerDelegate(_ viewController: EditExerciseDetailViewController, didDismiss: Bool)
}

class EditExerciseDetailViewController: ExerciseDetailViewController {

    weak var delegate: EditExerciseDetailViewControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.rightBarButtonItem = UIBarButtonItem(systemItem: .save, primaryAction: didTapSaveButton())
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if navigationController?.isBeingDismissed ?? isBeingDismissed {
            delegate?.editExerciseDetailViewControllerDelegate(self, didDismiss: true)
        }
    }

    private func didTapSaveButton() -> UIAction {
        return UIAction { [weak self] _ in
            guard let self else { return }
            let selectedSets = Int(setsData[pickerView.selectedRow(inComponent: 0)])
            let selectedReps = Int(repsData[pickerView.selectedRow(inComponent: 1)])
            delegate?.editExerciseDetailViewControllerDelegate(self, didUpdateExercise: exercise, sets: selectedSets, reps: selectedReps)
            self.navigationController?.dismiss(animated: true)
        }
    }
}
