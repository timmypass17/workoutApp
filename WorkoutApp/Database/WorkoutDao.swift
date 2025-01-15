//
//  WorkoutDao.swift
//  BuiltDiff
//
//  Created by Timmy Nguyen on 1/14/25.
//

import Foundation
import CoreData

// read on main context, write on background context
class WorkoutDao: WorkoutDaoProtocol {
    
    private let context: NSManagedObjectContext // main context

    init(context: NSManagedObjectContext) {
        self.context = context
    }
    
    func fetchTemplates() async throws -> [Template] {
        let request: NSFetchRequest<Template> = Template.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(key: "index", ascending: true)]
        
        let templates = try await context.perform {
            let results = try self.context.fetch(request)
            print("Fetched \(results.count) templates")
            return results
        }
        
        return templates
    }
    
    func fetchLogs() async throws -> [Workout] {
        let request: NSFetchRequest<Workout> = Workout.fetchRequest()
        let sortDescriptor = NSSortDescriptor(key: "createdAt_", ascending: false)
        request.sortDescriptors = [sortDescriptor]
        
        let logs = try await context.perform {
            let logs = try self.context.fetch(request)
            print("Fetched \(logs.count) logs")
            return logs
        }
        
        return logs
    }
    
    func fetchExerciseNames() async throws -> [String] {
        // TODO: fetch from templateExercises instead? much smaller data set
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Exercise")
        request.propertiesToFetch = ["name_"] // Fetch only the 'name_' property
        request.resultType = .dictionaryResultType
        request.returnsDistinctResults = true // Ensure only unique names are returned
        
        let exerciseNames = try await context.perform {
            let results = try self.context.fetch(request) as? [[String: Any]]
            let uniqueNames = results?.compactMap { $0["name_"] as? String } ?? []
            print("Fetched \(uniqueNames.count) exercises")
            return uniqueNames.sorted()
        }
        
        return exerciseNames
    }
    
    func fetchExerciseSets(exerciseName: String, limit: Int? = nil, ascending: Bool = true) async throws -> [ExerciseSet] {
        let request: NSFetchRequest<Exercise> = Exercise.fetchRequest()
        let predicate = NSPredicate(format: "name_ == %@", exerciseName)
        let sortDescriptor = NSSortDescriptor(key: "workout.createdAt_", ascending: ascending)
        request.predicate = predicate
        request.sortDescriptors = [sortDescriptor]
        
        if let limit {
            request.fetchLimit = limit
        }
        
        let exerciseSets = try await context.perform {
            let exercises: [Exercise] = try self.context.fetch(request)
            return exercises.compactMap { $0.bestSet }
        }
        
        return exerciseSets
    }
    
    func fetchPR(exerciseName: String) async throws -> Double {
        let request = NSFetchRequest<NSDictionary>(entityName: "ExerciseSet")
        request.predicate = NSPredicate(format: "exercise.name_ == %@", exerciseName)
        request.resultType = .dictionaryResultType
        
        // weights are stored as string, so transform string as double
        let expressionDescription = NSExpressionDescription()
        expressionDescription.name = "maxWeight"
        expressionDescription.expression = NSExpression(forFunction: "max:", arguments: [NSExpression(forKeyPath: "weight")])
        expressionDescription.expressionResultType = .doubleAttributeType
        
        request.propertiesToFetch = [expressionDescription]
        
        let bestLift = try await context.perform {
            guard let result = try self.context.fetch(request).first,
                  let maxWeight = result["maxWeight"] as? Double
            else {
                return 0.0
            }
            return maxWeight
        }
        
        return bestLift
    }
    
    // existingObject vs object
    func deleteTemplate(_ template: Template) async throws {
        let backgroundContext = CoreDataStack.shared.newBackgroundContext()
        
        try await backgroundContext.perform {
            // Fetch the object in the background context
            let objectInContext = try backgroundContext.existingObject(with: template.objectID)
            backgroundContext.delete(objectInContext)
            
            try backgroundContext.save()
        }
    }
    
    func deleteLog(_ log: Workout) async throws {
        let backgroundContext = CoreDataStack.shared.newBackgroundContext()

        try await backgroundContext.perform {
            let objectInContext = try backgroundContext.existingObject(with: log.objectID)
            backgroundContext.delete(objectInContext)
            
            try backgroundContext.save()
        }
    }
    
    func updateTemplatesPositions(_ templates: [Template]) async throws {
        let backgroundContext = CoreDataStack.shared.newBackgroundContext()
        
        try await backgroundContext.perform {
            for (index, template) in templates.enumerated() {
                let objectInContext = try backgroundContext.existingObject(with: template.objectID) as! Template
                objectInContext.index = Int16(index)
            }
            
            try backgroundContext.save()
        }
    }
    
}

// note: Core Data objects are tied to the context they belong to. Cant modify objects in different context.
//          - Fetch Objects in the Target Context using existingObject(with:) or object(with:)
// Core Data objects are not thread-safe, so it’s essential to use the appropriate context and threading practices to avoid crashes or inconsistent data. Using perform {} or performAndWait {} ensures that all Core Data operations are executed on the correct thread associated with the NSManagedObjectContext
// Why use perform {}? - used to ensure thread safety. Core Data contexts are not thread-safe.You cannot access or mutate objects in a context from a thread other than the one it was created on. The perform method schedules the block of code to execute on the queue associated with the context, ensuring thread safety. Operations like fetching, saving, or modifying managed objects must be done within the context's queue to avoid undefined behavior or crashes.

