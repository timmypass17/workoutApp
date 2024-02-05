//
//  WorkoutService.swift
//  WorkoutApp
//
//  Created by Timmy Nguyen on 1/25/24.
//

import Foundation
import CoreData
import UIKit

class WorkoutService {
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext

    func fetchWorkoutPlans() -> [Workout] {
        let request: NSFetchRequest<Workout> = Workout.fetchRequest()
        let predicate = NSPredicate(format: "createdAt == nil")
        request.predicate = predicate
        
        do {
            let workoutPlans = try context.fetch(request)
            print("Loaded \(workoutPlans.count) workouts")
            return workoutPlans
        } catch {
            print("Error fetching workouts: \(error.localizedDescription)")
        }
        return []
    }
    
    func fetchLoggedWorkouts() -> [Workout] {
        let request: NSFetchRequest<Workout> = Workout.fetchRequest()
        let predicate = NSPredicate(format: "createdAt != nil")
        request.predicate = predicate
        let sortDescriptor = NSSortDescriptor(key: "createdAt", ascending: false)
        request.sortDescriptors = [sortDescriptor]
        
        do {
            let workoutPlans = try context.fetch(request)
            print("Loaded \(workoutPlans.count) logs")
            return workoutPlans
        } catch {
            print("Error fetching logs: \(error.localizedDescription)")
        }
        return []
    }
}
