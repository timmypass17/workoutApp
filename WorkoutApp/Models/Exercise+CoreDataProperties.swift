//
//  Exercise+CoreDataProperties.swift
//  WorkoutApp
//
//  Created by Timmy Nguyen on 1/22/24.
//
//

import Foundation
import CoreData
import UIKit


extension Exercise {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Exercise> {
        return NSFetchRequest<Exercise>(entityName: "Exercise")
    }

    @NSManaged private var name_: String?
    @NSManaged public var index: Int16
    @NSManaged public var exerciseSets: NSSet?
    @NSManaged public var workout: Workout?
    
    var name: String {
        get {
            return name_ ?? ""
        }
        set {
            name_ = newValue
        }
    }
    
    var minReps: Int? {
        let reps = getExerciseSets()
            .compactMap { Int($0.reps) }
        return reps.min() ?? 0
    }
    
    var maxReps: Int? {
        let reps = getExerciseSets()
            .compactMap { Int($0.reps) }
        return reps.max() ?? 0
    }
    
    var bestSet: ExerciseSet? {
        return getExerciseSets().max { $0.weight < $1.weight }
    }

    func getExerciseSets() -> [ExerciseSet] {
        return (exerciseSets?.allObjects as? [ExerciseSet] ?? []).sorted { $0.index < $1.index }
    }
    
    func getExerciseSet(at index: Int) -> ExerciseSet {
        return getExerciseSets()[index]
    }
    
}

// MARK: Generated accessors for exerciseSets
extension Exercise {
    
    @objc(addExerciseSetsObject:)
    @NSManaged public func addToExerciseSets(_ value: ExerciseSet)

    @objc(removeExerciseSetsObject:)
    @NSManaged public func removeFromExerciseSets(_ value: ExerciseSet)

    @objc(addExerciseSets:)
    @NSManaged public func addToExerciseSets(_ values: NSSet)

    @objc(removeExerciseSets:)
    @NSManaged public func removeFromExerciseSets(_ values: NSSet)

}

extension Exercise : Identifiable {
    func getPrettyString() -> String {
        return "Exercise(title: \"\(name)\")"
    }
}
