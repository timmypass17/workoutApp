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

    weak var delegate: StartWorkoutViewControllerDelegate?

    init(template: Template) {
        super.init(nibName: nil, bundle: nil)
        workout = Workout(context: childContext)
        workout.title = template.title
        workout.createdAt = .now
        
        for templateExercise in template.templateExercises {
            let exercise = Exercise(context: childContext)
            exercise.name = templateExercise.name
            exercise.workout = workout
            
            for i in 0..<templateExercise.sets {
                let exerciseSet = ExerciseSet(context: childContext)
                exerciseSet.isComplete = false
                exerciseSet.reps = ""
                exerciseSet.weight = ""
                exerciseSet.index = Int16(i)
                exerciseSet.exercise = exercise
                exercise.addToExerciseSets(exerciseSet)
            }
            
            workout.addToExercises(exercise)
        }
    }
    
    @MainActor required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Finish", primaryAction: didTapFinishButton())
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
        do {
            try childContext.save()
        } catch {
            print("Error saving reordered items: \(error)")
        }

        CoreDataStack.shared.saveContext()

        delegate?.startWorkoutViewController(self, didFinishWorkout: workout)
        progressDelegate?.workoutDetailTableViewController(self, didFinishWorkout: workout)
        Settings.shared.logBadgeValue += 1
        NotificationCenter.default.post(name: Settings.logBadgeValueChangedNotification, object: nil)
        navigationController?.popViewController(animated: true)
    }
}
