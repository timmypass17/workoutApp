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
    @NSManaged public var exerciseSets: NSOrderedSet?
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


    func getExerciseSets() -> [ExerciseSet] {
        return exerciseSets?.array as? [ExerciseSet] ?? []
    }
    
    func getExerciseSet(at index: Int) -> ExerciseSet {
        return getExerciseSets()[index]
    }
    
//    func getPreviousExerciseDone() -> Exercise? {
//        let context = CoreDataStack.shared.mainContext
//        let request: NSFetchRequest<Exercise> = Exercise.fetchRequest()
//        let predicate = NSPredicate(format: "title_ == %@", name)
//        let sortDescriptor = NSSortDescriptor(key: "workout.createdAt_", ascending: false)
//        request.predicate = predicate
//        request.sortDescriptors = [sortDescriptor]
//        request.fetchLimit = 1
//        request.includesPendingChanges = false // don't include unsaved changes
//        
//        do {
//            let exercise: Exercise? = try context.fetch(request).first
//            return exercise
//        } catch {
//            print("Error fetching previous exercise: \(error.localizedDescription)")
//        }
//        return nil
//    }
}

// MARK: Generated accessors for exerciseSets
extension Exercise {

    @objc(insertObject:inExerciseSetsAtIndex:)
    @NSManaged public func insertIntoExerciseSets(_ value: ExerciseSet, at idx: Int)

    @objc(removeObjectFromExerciseSetsAtIndex:)
    @NSManaged public func removeFromExerciseSets(at idx: Int)

    @objc(insertExerciseSets:atIndexes:)
    @NSManaged public func insertIntoExerciseSets(_ values: [ExerciseSet], at indexes: NSIndexSet)

    @objc(removeExerciseSetsAtIndexes:)
    @NSManaged public func removeFromExerciseSets(at indexes: NSIndexSet)

    @objc(replaceObjectInExerciseSetsAtIndex:withObject:)
    @NSManaged public func replaceExerciseSets(at idx: Int, with value: ExerciseSet)

    @objc(replaceExerciseSetsAtIndexes:withExerciseSets:)
    @NSManaged public func replaceExerciseSets(at indexes: NSIndexSet, with values: [ExerciseSet])

    @objc(addExerciseSetsObject:)
    @NSManaged public func addToExerciseSets(_ value: ExerciseSet)

    @objc(removeExerciseSetsObject:)
    @NSManaged public func removeFromExerciseSets(_ value: ExerciseSet)

    @objc(addExerciseSets:)
    @NSManaged public func addToExerciseSets(_ values: NSOrderedSet)

    @objc(removeExerciseSets:)
    @NSManaged public func removeFromExerciseSets(_ values: NSOrderedSet)

}

extension Exercise : Identifiable {
    func getPrettyString() -> String {
        return "Exercise(title: \"\(name)\")"
    }
}
