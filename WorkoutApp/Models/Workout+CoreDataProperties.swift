//
//  Workout+CoreDataProperties.swift
//  WorkoutApp
//
//  Created by Timmy Nguyen on 1/22/24.
//
//

import Foundation
import CoreData
import UIKit


extension Workout {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Workout> {
        return NSFetchRequest<Workout>(entityName: "Workout")
    }

    @NSManaged public var createdAt: Date? // Should be optional (templates do not have dates, distinct value)
    @NSManaged private var title_: String?
    @NSManaged public var index: Int16  // used to sort a list of workout
    @NSManaged public var exercises: NSOrderedSet? // ordered means the exercises are in the order u added them in.

    var title: String {
        get {
            return title_ ?? ""
        }
        set {
            title_ = newValue
        }
    }

    func getExercises() -> [Exercise] {
        return exercises?.array as? [Exercise] ?? []
    }
    
    func getExercise(at index: Int) -> Exercise {
        return getExercises()[index]
    }
}

// MARK: Generated accessors for exercises
extension Workout {

    @objc(insertObject:inExercisesAtIndex:)
    @NSManaged public func insertIntoExercises(_ value: Exercise, at idx: Int)

    @objc(removeObjectFromExercisesAtIndex:)
    @NSManaged public func removeFromExercises(at idx: Int)

    @objc(insertExercises:atIndexes:)
    @NSManaged public func insertIntoExercises(_ values: [Exercise], at indexes: NSIndexSet)

    @objc(removeExercisesAtIndexes:)
    @NSManaged public func removeFromExercises(at indexes: NSIndexSet)

    @objc(replaceObjectInExercisesAtIndex:withObject:)
    @NSManaged public func replaceExercises(at idx: Int, with value: Exercise)

    @objc(replaceExercisesAtIndexes:withExercises:)
    @NSManaged public func replaceExercises(at indexes: NSIndexSet, with values: [Exercise])

    @objc(addExercisesObject:)
    @NSManaged public func addToExercises(_ value: Exercise)

    @objc(removeExercisesObject:)
    @NSManaged public func removeFromExercises(_ value: Exercise)

    @objc(addExercises:)
    @NSManaged public func addToExercises(_ values: NSOrderedSet)

    @objc(removeExercises:)
    @NSManaged public func removeFromExercises(_ values: NSOrderedSet)

}

extension Workout : Identifiable {
    
    func printPrettyString() {
        print(Array(repeating: "-", count: 60).joined())
        print(getPrettyString())
        let exercises = self.getExercises()
        for (_, exercise) in exercises.enumerated() {
            let sets = exercise.getExerciseSets()
            for (j, set) in sets.enumerated() {
                print("\t\(j). \(set.getPrettyString())")
            }
        }
    }
    
    func getPrettyString() -> String {
        return "Workout(title: \(title), createdAt: \(createdAt))"
    }

    class func copy(workout: Workout, with context: NSManagedObjectContext) -> Workout {
        let workoutCopy = Workout(context: context)
        workoutCopy.title = workout.title
        workoutCopy.createdAt = workout.createdAt
        workoutCopy.index = workout.index
        
        for exercise in workout.getExercises() {
            let exerciseCopy = Exercise(context: context)
            exerciseCopy.title = exercise.title
            exerciseCopy.workout = workoutCopy
            workoutCopy.addToExercises(exerciseCopy)
            for set in exercise.getExerciseSets() {
                let setCopy = ExerciseSet(context: context)
                setCopy.isComplete = set.isComplete
                setCopy.weight = set.weight
                setCopy.reps = set.reps
                setCopy.exercise = exerciseCopy
                exerciseCopy.addToExerciseSets(setCopy)
            }
        }
        return workoutCopy
    }
    
//    class func copy(workout: Workout, with context: NSManagedObjectContext) -> Workout {
//        let isStartingNewWorkout = workout.createdAt == nil // copying template
//        let workoutCopy = Workout(context: context)
//        workoutCopy.title = workout.title
//        workoutCopy.createdAt = isStartingNewWorkout ? .now : workout.createdAt
//        workoutCopy.index = workout.index
//        
//        for exercise in workout.getExercises() {
//            let exerciseCopy = Exercise(context: context)
//            exerciseCopy.title = exercise.title
//            exerciseCopy.workout = workoutCopy
//            workoutCopy.addToExercises(exerciseCopy)
//            for set in exercise.getExerciseSets() {
//                let setCopy = ExerciseSet(context: context)
//                setCopy.isComplete = isStartingNewWorkout ? false : set.isComplete
//                setCopy.weight = isStartingNewWorkout ? "" : set.weight
//                setCopy.reps = isStartingNewWorkout ? "" : set.reps
//                setCopy.exercise = exerciseCopy
//                exerciseCopy.addToExerciseSets(setCopy)
//            }
//        }
//        return workoutCopy
//    }

}
