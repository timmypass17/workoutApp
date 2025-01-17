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
    
    private let workoutDao: WorkoutDaoProtocol
    
    init(workoutDao: WorkoutDaoProtocol) {
        self.workoutDao = workoutDao
    }
    
    func createTemplate(childContext: NSManagedObjectContext) -> Template {
        workoutDao.createTemplate(childContext: childContext)
    }
    
    func createWorkout(template: Template, childContext: NSManagedObjectContext) -> Workout {
        workoutDao.createWorkout(template: template, childContext: childContext)
    }
    
    func fetchTemplates() async -> [Template] {
        do {
            return try await workoutDao.fetchTemplates()
        } catch {
            return []
        }
    }
    
    func fetchLogs() async -> [Workout] {
        do {
            return try await workoutDao.fetchLogs()
        } catch {
            return []
        }
    }
    
    func fetchExerciseNames() async -> [String] {
        do {
            return try await workoutDao.fetchExerciseNames()
        } catch {
            return []
        }
    }
    
    func fetchExerciseSets(exerciseName: String, limit: Int? = nil, ascending: Bool = true) async -> [ExerciseSet] {
        do {
            return try await workoutDao.fetchExerciseSets(exerciseName: exerciseName, limit: limit, ascending: ascending)
        } catch {
            return []
        }
    }
    
    func fetchPR(exerciseName: String) async -> Double {
        do {
            return try await workoutDao.fetchPR(exerciseName: exerciseName)
        } catch {
            return 0.0
        }
    }
    
    // had to remove inout, so just make copy and modify that copy
    // itself cant use inout, but within it can use inout?
    func deleteTemplate(_ templates: [Template], at indexPath: IndexPath) async -> [Template] {
        do {
            var updatedTemplates = templates
            let templateToRemove = updatedTemplates.remove(at: indexPath.row)
            try await workoutDao.deleteTemplate(templateToRemove)
            try await workoutDao.updateTemplatesPositions(updatedTemplates)
            return updatedTemplates
        } catch {
            print("error deleting template: \(error)")
            return templates
        }
    }
    
    func deleteLog(_ logs: [Date: [Workout]], at indexPath: IndexPath) async -> [Date: [Workout]] {
        do {
            var updatedLogs = logs
            let months = logs.keys.sorted()
            let month = months[indexPath.section]
            let logToRemove = updatedLogs[month, default: []].remove(at: indexPath.row)
            try await workoutDao.deleteLog(logToRemove)
            return updatedLogs
        } catch {
            print("error deleting template: \(error)")
            return logs
        }
    }
    
    func reorderTemplates(_ templates: [Template], moveWorkoutAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) async -> [Template] {
        guard sourceIndexPath != destinationIndexPath else { return templates }
        var updatedTemplates = templates
        let workoutToMove = updatedTemplates.remove(at: sourceIndexPath.row)
        updatedTemplates.insert(workoutToMove, at: destinationIndexPath.row)
                
        do {
            try await workoutDao.updateTemplatesPositions(updatedTemplates)
            return updatedTemplates
        } catch {
            print("Error reordering templates: \(error)")
            return templates
        }
    }
    
    func loadExercises(from fileName: String) -> [String] {
        return workoutDao.loadExercises(from: fileName)
    }
    
}

// Core data testing:
// The solution is to create a Core Data stack subclass that uses an in-memory store rather than the current SQLite store. Because an in-memory store isn’t persisted to disk, when the test finishes executing, the in-memory store releases its data.
