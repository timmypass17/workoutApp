//
//  WorkoutPlan+CoreDataProperties.swift
//  WorkoutApp
//
//  Created by Timmy Nguyen on 1/11/24.
//
//

import Foundation
import CoreData


extension WorkoutPlan {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<WorkoutPlan> {
        return NSFetchRequest<WorkoutPlan>(entityName: "WorkoutPlan")
    }

    @NSManaged public var title: String?
    @NSManaged public var planItems: NSOrderedSet?

}

// MARK: Generated accessors for planItems
extension WorkoutPlan {

    @objc(insertObject:inPlanItemsAtIndex:)
    @NSManaged public func insertIntoPlanItems(_ value: PlanItem, at idx: Int)

    @objc(removeObjectFromPlanItemsAtIndex:)
    @NSManaged public func removeFromPlanItems(at idx: Int)

    @objc(insertPlanItems:atIndexes:)
    @NSManaged public func insertIntoPlanItems(_ values: [PlanItem], at indexes: NSIndexSet)

    @objc(removePlanItemsAtIndexes:)
    @NSManaged public func removeFromPlanItems(at indexes: NSIndexSet)

    @objc(replaceObjectInPlanItemsAtIndex:withObject:)
    @NSManaged public func replacePlanItems(at idx: Int, with value: PlanItem)

    @objc(replacePlanItemsAtIndexes:withPlanItems:)
    @NSManaged public func replacePlanItems(at indexes: NSIndexSet, with values: [PlanItem])

    @objc(addPlanItemsObject:)
    @NSManaged public func addToPlanItems(_ value: PlanItem)

    @objc(removePlanItemsObject:)
    @NSManaged public func removeFromPlanItems(_ value: PlanItem)

    @objc(addPlanItems:)
    @NSManaged public func addToPlanItems(_ values: NSOrderedSet)

    @objc(removePlanItems:)
    @NSManaged public func removeFromPlanItems(_ values: NSOrderedSet)

}

extension WorkoutPlan : Identifiable {

}
