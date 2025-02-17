//
//  StartWorkoutViewController.swift
//  BuiltDiff
//
//  Created by Timmy Nguyen on 1/1/25.
//

import UIKit

protocol StartWorkoutViewControllerDelegate: AnyObject {
    func startWorkoutViewController(_ viewController: StartWorkoutViewController, didFinishWorkout workout: Workout)
}

class StartWorkoutViewController: WorkoutDetailViewController {

    weak var progressDelegate: StartWorkoutViewControllerDelegate?  // progress handles

    init(template: Template, workoutService: WorkoutService) {
        super.init(workoutService: workoutService)
        workout = workoutService.createWorkout(template: template, childContext: childContext)
        self.template = template
    }
    
    @MainActor required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.rightBarButtonItems = [UIBarButtonItem(title: "Finish", primaryAction: didTapFinishButton())]
        
        if Settings.shared.showTimer {
            let timeElapsedButton = TimeElapsedBarButton()
            navigationItem.rightBarButtonItems?.append(timeElapsedButton)
        }
    }

    func didTapFinishButton() -> UIAction {
        return UIAction { _ in
            if self.workout.isFinished {
                self.showFinishAlert(title: "Workout Complete!", message: "Are you ready to finish your workout?")
            } else {
                self.showFinishAlert(title: "Finish Workout?", message: "Some weight or reps fields are still empty. Are you sure you want to finish your workout?")
            }
        }
    }
    
    func showFinishAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.addAction(UIAlertAction(title: "Confirm", style: .default) { _ in
            self.didTapConfirmButton()
        })
        
        
        present(alert, animated: true, completion: nil)
    }
    
    func didTapConfirmButton() {
        for exercise in workout.getExercises() {
            for set in exercise.getExerciseSets() {
                if set.weight < 0 {
                    set.weight = 0
                }
                if set.reps < 0 {
                    set.reps = 0
                }
                set.isComplete = true
            }
        }
        
        do {
            try childContext.save()
        } catch {
            print("Error saving reordered items: \(error)")
        }

        CoreDataStack.shared.saveContext()

        progressDelegate?.startWorkoutViewController(self, didFinishWorkout: workout)
        Settings.shared.logBadgeValue += 1
        NotificationCenter.default.post(name: Settings.logBadgeValueChangedNotification, object: nil)
        navigationController?.popViewController(animated: true)
    }
}
