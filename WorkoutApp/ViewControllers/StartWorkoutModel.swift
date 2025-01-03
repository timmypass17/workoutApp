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

//class StartWorkoutModel: WorkoutModel {
//    
//    var workout: Workout
//    var childContext: NSManagedObjectContext = CoreDataStack.shared.newBackgroundContext()
//    var viewController: WorkoutDetailViewController?
//    
//    var primaryButtonText: String = "Finish"
//    
//    init(template: Template) {
//        workout = Workout(context: childContext)
//        workout.title = template.title
//        workout.createdAt = .now
//        
//        for templateExercise in template.templateExercises {
//            let exercise = Exercise(context: childContext)
//            exercise.name = templateExercise.name
//            exercise.workout = workout
//            
//            for i in 0..<templateExercise.sets {
//                let exerciseSet = ExerciseSet(context: childContext)
//                exerciseSet.isComplete = false
//                exerciseSet.reps = ""
//                exerciseSet.weight = ""
//                exerciseSet.index = Int16(i)
//                exerciseSet.exercise = exercise
//                exercise.addToExerciseSets(exerciseSet)
//            }
//            
//            workout.addToExercises(exercise)
//        }
//    }
//    
//    func workoutModel(_ viewController: WorkoutDetailViewController, didTapPrimaryButton workout: Workout) {
//        if self.workout.isFinished {
//            self.showFinishAlert(title: "Workout Complete!", message: "Are you ready to finish your workout?", viewController, workout: workout)
//        } else {
//            self.showFinishAlert(title: "Finish Workout?", message: "Some weight or reps fields are still empty. Are you sure you want to finish your workout?", viewController, workout: workout)
//        }
//    }
//    
//    func showFinishAlert(title: String, message: String, _ viewController: WorkoutDetailViewController, workout: Workout) {
//        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
//        
//        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
//        alert.addAction(UIAlertAction(title: "Confirm", style: .default) { _ in
//            self.didTapConfirmButton(viewController, workout: workout)
//        })
//        
//        viewController.present(alert, animated: true, completion: nil)
//    }
//    
//    func didTapConfirmButton(_ viewController: WorkoutDetailViewController, workout: Workout) {
//        do {
//            try childContext.save()
//        } catch {
//            print("Error saving reordered items: \(error)")
//        }
//
//        CoreDataStack.shared.saveContext()
//
//        viewController.delegate.didTap
// //        progressDelegate?.workoutDetailTableViewController(self, didFinishWorkout: workout)
//        Settings.shared.logBadgeValue += 1
//        NotificationCenter.default.post(name: Settings.logBadgeValueChangedNotification, object: nil)
//        viewController?.navigationController?.popViewController(animated: true)
//    }
//}
