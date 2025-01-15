//
//  WorkoutDao.swift
//  BuiltDiff
//
//  Created by Timmy Nguyen on 1/14/25.
//

import Foundation
import CoreData

class WorkoutDao: WorkoutDaoProtocol {
    
    private let context: NSManagedObjectContext

    init(context: NSManagedObjectContext) {
        self.context = context
    }
    
    func fetchTemplates() -> [Template] {
        let request: NSFetchRequest<Template> = Template.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(key: "index", ascending: true)]
        
        do {
            let templates = try context.fetch(request)
            print("Fetched \(templates.count) templates")
            return templates
        } catch {
            print("Error fetching workouts: \(error.localizedDescription)")
            return []
        }
    }
    
    func fetchLogs() -> [Workout] {
        let request: NSFetchRequest<Workout> = Workout.fetchRequest()
        let sortDescriptor = NSSortDescriptor(key: "createdAt_", ascending: false)
        request.sortDescriptors = [sortDescriptor]
        
        do {
            let logs = try context.fetch(request)
            print("Fetched \(logs.count) logs")
            return logs
        } catch {
            print("Error fetching logs: \(error.localizedDescription)")
            return []
        }
    }
    
    func fetchExerciseNames() -> [String] {
        // TODO: fetch from templateExercises instead? much smaller data set
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Exercise")
        request.propertiesToFetch = ["name_"] // Fetch only the 'name_' property
        request.resultType = .dictionaryResultType
        request.returnsDistinctResults = true // Ensure only unique names are returned
        
        do {
            let results = try context.fetch(request) as? [[String: Any]]
            let uniqueNames = results?.compactMap { $0["name_"] as? String } ?? []
            print("Fetched \(uniqueNames.count) exercises")
            return uniqueNames.sorted()
        } catch {
            print("Failed to fetch unique exercise names: \(error.localizedDescription)")
            return []
        }
    }
    
    func fetchExerciseSets(exerciseName: String, limit: Int? = nil, ascending: Bool = true) -> [ExerciseSet] {
        let request: NSFetchRequest<Exercise> = Exercise.fetchRequest()
        let predicate = NSPredicate(format: "name_ == %@", exerciseName)
        let sortDescriptor = NSSortDescriptor(key: "workout.createdAt_", ascending: ascending)
        request.predicate = predicate
        request.sortDescriptors = [sortDescriptor]
        
        if let limit {
            request.fetchLimit = limit
        }
        
        do {
            let exercises: [Exercise] = try context.fetch(request)
            return exercises.compactMap { $0.bestSet }
        } catch {
            print("Failed to fetch unique exercise names: \(error.localizedDescription)")
            return []
        }
    }
    
    func fetchPR(exerciseName: String) -> Double {
        let request = NSFetchRequest<NSDictionary>(entityName: "ExerciseSet")
        request.predicate = NSPredicate(format: "exercise.name_ == %@", exerciseName)
        request.resultType = .dictionaryResultType
        
        // weights are stored as string, so transform string as double
        let expressionDescription = NSExpressionDescription()
        expressionDescription.name = "maxWeight"
        expressionDescription.expression = NSExpression(forFunction: "max:", arguments: [NSExpression(forKeyPath: "weight")])
        expressionDescription.expressionResultType = .doubleAttributeType
        
        request.propertiesToFetch = [expressionDescription]
        
        do {
            if let result = try context.fetch(request).first,
               let maxWeight = result["maxWeight"] as? Double {
                return maxWeight
            }
        } catch {
            print("Error fetching max weight: \(error)")
        }
        
        return 0
    }

    
    func deleteTemplate(_ template: Template) {
        let objectInTargetContext = context.object(with: template.objectID)
        context.delete(objectInTargetContext)

        do {
            try context.save()
        } catch {
            print("Failed to delete template: \(error)")
        }
    }
    
    func deleteLog(_ log: Workout) {
        let objectInTargetContext = context.object(with: log.objectID)
        context.delete(objectInTargetContext)

        do {
            try context.save()
            print("Deleted log successfully")
        } catch {
            print("Failed to delete workout: \(error)")
        }
    }
    
    func deleteLog(_ logs: inout [Date: [Workout]], at indexPath: IndexPath) {
        let months = logs.keys.sorted()
        let month = months[indexPath.section]
        let logToRemove = logs[month, default: []].remove(at: indexPath.row)
        
        // Can't delete objects in different context.
        let objectInTargetContext = context.object(with: logToRemove.objectID)
        context.delete(objectInTargetContext)

        do {
            try context.save()
            print("Deleted log successfully")
        } catch {
            print("Failed to delete workout: \(error)")
        }
    }
    
    func deleteWorkout(_ workout: Workout) {
        let objectInTargetContext = context.object(with: workout.objectID)
        context.delete(objectInTargetContext)
        
        do {
            try context.save()
        } catch {
            print("Failed to delete workout: \(error)")
        }
    }
    
    func updateTemplatesPositions(_ templates: inout [Template]) {
        for (index, template) in templates.enumerated() {
            template.index = Int16(index)
        }

        do {
            // TODO: Use CoreDataStack.shared.save()?
            try context.save()
        } catch {
            print("Failed to reorder template: \(error)")
        }
    }
    
}
