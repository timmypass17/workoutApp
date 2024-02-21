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

    @NSManaged public var isComplete: Bool
    @NSManaged public var reps: String?
    @NSManaged public var weight_: String? // always in lbs
    @NSManaged public var exercise: Exercise?
    
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
    
    var weightString: String {
        guard let doubleValue = Double(weight) else { return "" }
        let numberFormatter = NumberFormatter()
        numberFormatter.minimumFractionDigits = 0
        numberFormatter.maximumFractionDigits = doubleValue.truncatingRemainder(dividingBy: 1) == 0 ? 0 : 2
        return numberFormatter.string(from: NSNumber(value: doubleValue)) ?? ""
    }
    
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
    func previousSet(for rowAt: Int) -> ExerciseSet? {
        guard let exerciseName = exercise?.title else { return nil }
        
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        let fetchRequest: NSFetchRequest<ExerciseSet> = ExerciseSet.fetchRequest()

        // Filter set by name AND is not a template
        let predicate = NSPredicate(format: "exercise.title == %@ AND exercise.workout.createdAt != nil", exerciseName)
        fetchRequest.predicate = predicate

        // Sort descriptor to sort by workout's createdAt in descending order
        let sortDescriptor = NSSortDescriptor(key: "exercise.workout.createdAt", ascending: false)
        fetchRequest.sortDescriptors = [sortDescriptor]

        // Limit the result to fetch only the latest ExerciseSet
        fetchRequest.fetchLimit = 1
        
        do {
            let results: [ExerciseSet] = try context.fetch(fetchRequest)
            if let latestSet = results.first {
                // Handle the latest ExerciseSet with the exercise name "Bench Press"
//                print(latestSet)
                return latestSet
            } else {
//                print("No set found \(exerciseName)")
            }
            
        } catch {
            print("Error fetching ExerciseSets: \(error.localizedDescription)")
        }
        
        return nil
    }
    
    func getPrettyString() -> String {
        return "ExerciseSet(isComplete: \(isComplete), weight: \(weight), reps: \(reps!))"
    }
}
