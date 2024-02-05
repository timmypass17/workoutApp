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
        
    class func copy(template: Workout) -> Workout {
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        let workout = Workout(context: context)
        workout.title = template.title
        workout.createdAt = .now
        
        for exerciseTemplate in template.getExercises() {
            let exercise = Exercise(context: context)
            exercise.title = exerciseTemplate.title
            exercise.workout = workout
            workout.addToExercises(exercise)
            for _ in exerciseTemplate.getExerciseSets() {
                let set = ExerciseSet(context: context)
                set.isComplete = false
                set.weight = ""
                set.reps = ""
                set.exercise = exercise
                exercise.addToExerciseSets(set)
            }
        }
        return workout
    }
}
