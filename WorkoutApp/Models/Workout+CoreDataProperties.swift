//
//  Workout+CoreDataProperties.swift
//  WorkoutApp
//
//  Created by Timmy Nguyen on 1/11/24.
//
//

import Foundation
import CoreData


extension Workout {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Workout> {
        return NSFetchRequest<Workout>(entityName: "Workout")
    }

    @NSManaged public var title: String?
    @NSManaged public var createdAt: Date?
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
}
