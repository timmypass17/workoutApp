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
    @NSManaged private var reps_: String?   // set to private cause we don't want to expose field to outside
    @NSManaged private var weight_: String? // always in lbs (real weight)
    @NSManaged public var exercise: Exercise?
    
    var reps: String {
        get {
            return reps_ ?? "0"
        }
        set {
            reps_ = newValue
        }
    }
    
    var weight: String {
        get {
            if Settings.shared.weightUnit == .lbs {
                return weight_ ?? "0"
            } else {
                // Convert lbs to kg
                return convertToKg(lbs: weight_ ?? "0")
            }
        }
        set {
            if Settings.shared.weightUnit == .lbs {
                weight_ = newValue
            } else {
                // Convert kg to lbs
                weight_ = convertToLbs(kg: newValue)
            }
        }
    }
    
    // Weight string formatted nicely
    var weightString: String {
        guard let doubleValue = Double(weight) else { return "" }
        let numberFormatter = NumberFormatter()
        numberFormatter.minimumFractionDigits = 0
        numberFormatter.maximumFractionDigits = doubleValue.truncatingRemainder(dividingBy: 1) == 0 ? 0 : 2
        return numberFormatter.string(from: NSNumber(value: doubleValue)) ?? ""
    }
    
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
        return "ExerciseSet(isComplete: \(isComplete), weight: \(weight), reps: \(reps))"
    }
}
