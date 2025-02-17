//
//  ExerciseSet+CoreDataProperties.swift
//  WorkoutApp
//
//  Created by Timmy Nguyen on 1/22/24.
//
//

import Foundation
import CoreData
import UIKit


extension ExerciseSet {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<ExerciseSet> {
        return NSFetchRequest<ExerciseSet>(entityName: "ExerciseSet")
    }

    @NSManaged public var isComplete: Bool  // Bool have default value, no need for extra setters/getters
    @NSManaged public var reps: Int16
    @NSManaged public var weight: Double // always in lbs (real weight)
    @NSManaged public var exercise: Exercise?
    @NSManaged public var index: Int16  // used to sort a list of workout

    var isCurrentSet: Bool {
        guard let exerciseSets = exercise?.getExerciseSets(),
              let currentSet = exerciseSets.first(where: { !$0.isComplete }) else {
            return false
        }

        return self == currentSet
    }
    
    var weightString: String {
        return formatWeight(weight)
    }
    
    var repsString: String {
        return "\(reps)"
    }
    
//    var reps: String {
//        get {
//            return reps_ ?? "0"
//        }
//        set {
//            reps_ = newValue
//        }
//    }
    
//    var weight: String {
//        get {
//            if Settings.shared.weightUnit == .lbs {
//                return weight_ ?? "0"
//            } else {
//                // Convert lbs to kg
//                return convertToKg(lbs: weight_ ?? "0")
//            }
//        }
//        set {
//            if Settings.shared.weightUnit == .lbs {
//                weight_ = newValue
//            } else {
//                // Convert kg to lbs
//                weight_ = convertToLbs(kg: newValue)
//            }
//        }
//    }
    
    var previousSet: ExerciseSet? {
        let context = CoreDataStack.shared.mainContext
        let request: NSFetchRequest<Exercise> = Exercise.fetchRequest()
        let predicate = NSPredicate(format: "name_ == %@", exercise?.name ?? "")
        let sortDescriptor = NSSortDescriptor(key: "workout.createdAt_", ascending: false)
        request.predicate = predicate
        request.sortDescriptors = [sortDescriptor]
        request.fetchLimit = 1
//        request.includesPendingChanges = false // don't include unsaved changes
        
        do {
            guard let exercise: Exercise = try context.fetch(request).first else { return nil }
            let sets = exercise.getExerciseSets()
            if index < sets.count {
                return sets[Int(index)]
            } else {
                return sets.last
            }
        } catch {
            print("Error fetching previous exercise: \(error.localizedDescription)")
        }
        return nil
    }
    
    // Weight string formatted nicely
//    var weightString: String {
//        return ""
//        guard let doubleValue = Double(weight) else { return "" }
//        let numberFormatter = NumberFormatter()
//        numberFormatter.minimumFractionDigits = 0
//        numberFormatter.maximumFractionDigits = doubleValue.truncatingRemainder(dividingBy: 1) == 0 ? 0 : 2
//        return numberFormatter.string(from: NSNumber(value: doubleValue)) ?? ""
//    }
    
    // Move this methods to Weight class or something (single responsibility)
    private func convertToKg(lbs: String) -> String {
        guard let lbs = Float(lbs) else { return "" }
        let kg = lbs * 0.45359237
        return String(kg)
    }
    
    private func convertToLbs(kg: String) -> String {
        guard let kg = Float(kg) else { return "" }
        let lbs = kg * 2.20462
        return String(lbs)
    }
}

extension ExerciseSet : Identifiable {
    func getPrettyString() -> String {
        return "ExerciseSet(index: \(index), isComplete: \(isComplete), weight: \(weight), reps: \(reps))"
    }
}

func formatWeight(_ weight: Double, maxFractionDigits: Int = 2) -> String {
    let isWholeNumber = weight.truncatingRemainder(dividingBy: 1) == 0
    let numberFormatter = NumberFormatter()
    numberFormatter.minimumFractionDigits = 0
    numberFormatter.maximumFractionDigits = isWholeNumber ? 0 : maxFractionDigits
    
    return numberFormatter.string(from: NSNumber(value: weight)) ?? ""
}
