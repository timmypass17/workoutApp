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

    @NSManaged public var createdAt_: Date?
    @NSManaged private var title_: String?
    @NSManaged public var index: Int16  // used to sort a list of workout
    @NSManaged public var exercises: NSSet? // Cloud Kit doesn't support ordered relationships

    var title: String {
        get {
            return title_ ?? ""
        }
        set {
            title_ = newValue
        }
    }
    
    var createdAt: Date {
        get {
            return createdAt_ ?? .now
        }
        set {
            createdAt_ = newValue
        }
    }
    
    var monthKey:  Date {
        let components = Calendar.current.dateComponents([.year, .month], from: createdAt)
        return Calendar.current.date(from: components)!
    }

    func getExercises() -> [Exercise] {
        return (exercises?.allObjects as? [Exercise] ?? []).sorted { $0.index < $1.index }
    }
    
    func getExercise(at index: Int) -> Exercise {
        return getExercises()[index]
    }
    
    var isFinished: Bool {
        let exercises = getExercises()
        for exercise in exercises {
            let sets = exercise.getExerciseSets()
            for set in sets {
                if set.weight < 0 || set.reps < 0 {
                    return false
                }
            }
        }
        
        return true
    }
}

// MARK: Generated accessors for exercises
extension Workout {

    @objc(addExercisesObject:)
    @NSManaged public func addToExercises(_ value: Exercise)

    @objc(removeExercisesObject:)
    @NSManaged public func removeFromExercises(_ value: Exercise)

    @objc(addExercises:)
    @NSManaged public func addToExercises(_ values: NSSet)

    @objc(removeExercises:)
    @NSManaged public func removeFromExercises(_ values: NSSet)

}

extension Workout : Identifiable {
    
    func printPrettyString() {
        print(Array(repeating: "-", count: 60).joined())
        print(getPrettyString())
        let exercises = self.getExercises()
        for (_, exercise) in exercises.enumerated() {
            let sets = exercise.getExerciseSets()
            print("\t\(exercise.getPrettyString())")
            for (j, set) in sets.enumerated() {
                print("\t\t\(set.getPrettyString())")
            }
        }
    }
    
    func getPrettyString() -> String {
        return "Workout(title: \"\(title)\", createdAt: \(createdAt.formatted(date: .abbreviated, time: .omitted)))"
    }

    class func copy(workout: Workout, with context: NSManagedObjectContext) -> Workout {
        let workoutCopy = Workout(context: context)
        workoutCopy.title = workout.title
        workoutCopy.createdAt = workout.createdAt
        workoutCopy.index = workout.index
        
        for exercise in workout.getExercises() {
            let exerciseCopy = Exercise(context: context)
            exerciseCopy.name = exercise.name
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

}
