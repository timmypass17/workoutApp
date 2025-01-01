//
//  StartWorkoutModel.swift
//  BuiltDiff
//
//  Created by Timmy Nguyen on 1/1/25.
//

import Foundation
import CoreData
import UIKit

// note: core data object's gets deallocated if context is deallocated?

struct StartWorkoutModel: WorkoutModel {
    var workout: Workout
    var childContext: NSManagedObjectContext = CoreDataStack.shared.newBackgroundContext()
    
    var primaryButtonText: String = "Finish"
        
    init(template: Template) {
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
    
    func didTapPrimaryButton(_ viewController: UIViewController) -> UIAction {
        return UIAction { _ in
            if self.workout.isFinished {
                self.showFinishAlert(viewController, title: "Workout Complete!", message: "Are you ready to finish your workout?")
            } else {
                self.showFinishAlert(viewController, title: "Finish Workout?", message: "Some weight or reps fields are still empty. Are you sure you want to finish your workout?")
            }
        }
    }
    
    func showFinishAlert(_ viewController: UIViewController, title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.addAction(UIAlertAction(title: "Confirm", style: .default) { _ in
            self.didTapConfirmButton()
        })
        
        viewController.present(alert, animated: true, completion: nil)
    }
    
    func didTapConfirmButton() {
        do {
            try childContext.save()
        } catch {
            print("Error saving reordered items: \(error)")
        }

        CoreDataStack.shared.saveContext()

//        delegate?.workoutDetailTableViewController(self, didFinishWorkout: workout)
//        progressDelegate?.workoutDetailTableViewController(self, didFinishWorkout: workout)
//        Settings.shared.logBadgeValue += 1
//        NotificationCenter.default.post(name: Settings.logBadgeValueChangedNotification, object: nil)
//        navigationController?.popViewController(animated: true)
    }
}
