//
//  Template+CoreDataProperties.swift
//  BuiltDiff
//
//  Created by Timmy Nguyen on 12/28/24.
//
//

import Foundation
import CoreData


extension Template {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Template> {
        return NSFetchRequest<Template>(entityName: "Template")
    }

    @NSManaged public var title_: String?
    @NSManaged public var index: Int16
    @NSManaged public var templateExercises_: NSOrderedSet?

    var title: String {
        get {
            return title_ ?? ""
        }
        set {
            title_ = newValue
        }
    }
    
    var templateExercises: [TemplateExercise] {
        return templateExercises_?.array as? [TemplateExercise] ?? []
    }
}

// MARK: Generated accessors for templateExercises_
extension Template {

    @objc(insertObject:inTemplateExercises_AtIndex:)
    @NSManaged public func insertIntoTemplateExercises_(_ value: TemplateExercise, at idx: Int)

    @objc(removeObjectFromTemplateExercises_AtIndex:)
    @NSManaged public func removeFromTemplateExercises_(at idx: Int)

    @objc(insertTemplateExercises_:atIndexes:)
    @NSManaged public func insertIntoTemplateExercises_(_ values: [TemplateExercise], at indexes: NSIndexSet)

    @objc(removeTemplateExercises_AtIndexes:)
    @NSManaged public func removeFromTemplateExercises_(at indexes: NSIndexSet)

    @objc(replaceObjectInTemplateExercises_AtIndex:withObject:)
    @NSManaged public func replaceTemplateExercises_(at idx: Int, with value: TemplateExercise)

    @objc(replaceTemplateExercises_AtIndexes:withTemplateExercises_:)
    @NSManaged public func replaceTemplateExercises_(at indexes: NSIndexSet, with values: [TemplateExercise])

    @objc(addTemplateExercises_Object:)
    @NSManaged public func addToTemplateExercises_(_ value: TemplateExercise)

    @objc(removeTemplateExercises_Object:)
    @NSManaged public func removeFromTemplateExercises_(_ value: TemplateExercise)

    @objc(addTemplateExercises_:)
    @NSManaged public func addToTemplateExercises_(_ values: NSOrderedSet)

    @objc(removeTemplateExercises_:)
    @NSManaged public func removeFromTemplateExercises_(_ values: NSOrderedSet)

}

extension Template : Identifiable {

}
