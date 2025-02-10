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
    
    // computed property (transient property works wierd with child-parent)
    @objc var createdMonthID : String? {
        guard let createdAt_ else { return nil }
        return Workout.monthID(from: createdAt_)
    }
    
    var title: String {
        get {
            return title_ ?? ""
        }
        set {
            title_ = newValue
        }
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
    
    // Convert a publishMonthString, or the section name of the main table view, to a date.
    // Use the same calendar and time zone to decode the transient value.
    //
    class func date(from publishMonthString: String) -> Date? {
    
        guard let numericSection = Int(publishMonthString) else {
            return nil
        }
        var dateComponents = DateComponents()
        dateComponents.calendar = Calendar(identifier: .gregorian)

        let year = numericSection / 1000
        let month = numericSection - year * 1000
        dateComponents.year = year
        dateComponents.month = month
        
        return dateComponents.calendar?.date(from: dateComponents)
    }
    
    class func monthID(from date: Date) -> String? {
        let calendar = Calendar(identifier: .gregorian)
        let components = calendar.dateComponents([.year, .month], from: date)
        if let year = components.year, let month = components.month {
            return "\(year * 1000 + month)"
        }
        return nil
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
        return ""
//        return "Workout(title: \"\(title)\", createdAt: \(createdAt_.formatted(date: .abbreviated, time: .omitted)))"
    }

    class func copy(workout: Workout, with context: NSManagedObjectContext) -> Workout {
        let workoutCopy = Workout(context: context)
        workoutCopy.title = workout.title
        workoutCopy.createdAt_ = workout.createdAt_
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
