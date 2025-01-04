//
//  TemplateExercise+CoreDataProperties.swift
//  BuiltDiff
//
//  Created by Timmy Nguyen on 12/28/24.
//
//

import Foundation
import CoreData

// TODO: Replace core data fields as ints, so that we can get max easily. Check stackoverflow for ref
extension TemplateExercise {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<TemplateExercise> {
        return NSFetchRequest<TemplateExercise>(entityName: "TemplateExercise")
    }

    @NSManaged public var name_: String?
    @NSManaged public var sets: Int16
    @NSManaged public var reps: Int16
    @NSManaged public var index: Int16
    @NSManaged public var template: Template?

    var name: String {
        get {
            return name_ ?? ""
        }
        set {
            name_ = newValue
        }
    }
}

extension TemplateExercise : Identifiable {

}
