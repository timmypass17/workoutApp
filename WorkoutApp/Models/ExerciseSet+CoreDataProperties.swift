//
//  ExerciseSet+CoreDataProperties.swift
//  WorkoutApp
//
//  Created by Timmy Nguyen on 1/15/24.
//
//

import Foundation
import CoreData


extension ExerciseSet {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<ExerciseSet> {
        return NSFetchRequest<ExerciseSet>(entityName: "ExerciseSet")
    }

    @NSManaged public var weight: String?
    @NSManaged public var reps: String?
    @NSManaged public var isComplete: Bool
    @NSManaged public var exercise: Exercise?

}

extension ExerciseSet : Identifiable {

}
