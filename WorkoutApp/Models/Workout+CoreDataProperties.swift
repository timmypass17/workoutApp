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

    @NSManaged public var createdAt: Date?
    @NSManaged public var title: String?
    @NSManaged public var exercises: NSOrderedSet?

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
        let exercises = self.exercises?.array as! [Exercise]
        for (i, exercise) in exercises.enumerated() {
            print("\(i). \(exercise.getPrettyString())")
            let sets = exercise.exerciseSets?.array as! [ExerciseSet]
            for (j, set) in sets.enumerated() {
                print("\t\(j). \(set.getPrettyString())")
            }
        }
    }
    
    func getPrettyString() -> String {
        return "Workout(title: \(title!), createdAt: \(createdAt))"
    }
    
    class func copy(_ workout: Workout) -> Workout {
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        let workoutCopy = Workout(context: context)
        workoutCopy.title = workout.title
        workoutCopy.createdAt = .now
        
        for exercise in workout.exercises?.array as! [Exercise] {
            let exerciseCopy = Exercise(context: context)
            exerciseCopy.title = exercise.title
            exerciseCopy.workout = workoutCopy
            workoutCopy.addToExercises(exerciseCopy)
            for set in exercise.exerciseSets?.array as! [ExerciseSet] {
                let setCopy = ExerciseSet(context: context)
                setCopy.isComplete = false
                setCopy.weight = set.weight
                setCopy.reps = set.reps
                setCopy.exercise = exerciseCopy
                exerciseCopy.addToExerciseSets(setCopy)
            }
        }
        return workoutCopy
    }
}
