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
    @NSManaged public var weight: String?
    @NSManaged public var exercise: Exercise?

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
        return "ExerciseSet(isComplete: \(isComplete), weight: \(weight!), reps: \(reps!))"
    }
}
