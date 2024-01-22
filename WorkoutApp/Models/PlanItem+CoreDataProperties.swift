//
//  PlanItem+CoreDataProperties.swift
//  WorkoutApp
//
//  Created by Timmy Nguyen on 1/11/24.
//
//

import Foundation
import CoreData


extension PlanItem {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<PlanItem> {
        return NSFetchRequest<PlanItem>(entityName: "PlanItem")
    }

    @NSManaged public var reps: String?
    @NSManaged public var sets: String?
    @NSManaged public var title: String?
    @NSManaged public var weight: String?
    @NSManaged public var workoutPlan: WorkoutPlan?

}

extension PlanItem : Identifiable {

}
