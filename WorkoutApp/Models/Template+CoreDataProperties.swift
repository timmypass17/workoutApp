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

    @NSManaged public var index: Int16
    @NSManaged public var title_: String?
    @NSManaged public var templateExercises_: NSSet?

    var title: String {
        get {
            return title_ ?? ""
        }
        set {
            title_ = newValue
        }
    }
    
    var templateExercises: [TemplateExercise] {
        return (templateExercises_?.allObjects as? [TemplateExercise] ?? []).sorted { $0.index < $1.index }
    }
}

// MARK: Generated accessors for templateExercises_
extension Template {

    @objc(addTemplateExercises_Object:)
    @NSManaged public func addToTemplateExercises_(_ value: TemplateExercise)

    @objc(removeTemplateExercises_Object:)
    @NSManaged public func removeFromTemplateExercises_(_ value: TemplateExercise)

    @objc(addTemplateExercises_:)
    @NSManaged public func addToTemplateExercises_(_ values: NSSet)

    @objc(removeTemplateExercises_:)
    @NSManaged public func removeFromTemplateExercises_(_ values: NSSet)

}

extension Template : Identifiable {

}
