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
    
    func fetchTemplates() -> [Template] {
        return workoutDao.fetchTemplates()
    }
    
    func fetchLogs() -> [Workout] {
        return workoutDao.fetchLogs()
    }
    
    func fetchExerciseSets(exerciseName: String, limit: Int? = nil, ascending: Bool = true) -> [ExerciseSet] {
        return workoutDao.fetchExerciseSets(exerciseName: exerciseName, limit: limit, ascending: ascending)
    }
    
    func fetchPR(exerciseName: String) -> Double {
        return workoutDao.fetchPR(exerciseName: exerciseName)
    }
    
    func fetchExerciseNames() -> [String] {
        return workoutDao.fetchExerciseNames()
    }
    
    func deleteTemplate(_ templates: inout [Template], at indexPath: IndexPath) {
        let templateToRemove = templates.remove(at: indexPath.row)
        workoutDao.deleteTemplate(templateToRemove)
        workoutDao.updateTemplatesPositions(&templates)
    }
    
    func deleteLog(_ logs: inout [Date: [Workout]], at indexPath: IndexPath) {
        let months = logs.keys.sorted()
        let month = months[indexPath.section]
        let logToRemove = logs[month, default: []].remove(at: indexPath.row)
        
        workoutDao.deleteLog(logToRemove)
    }
    
    func reorderTemplates(_ templates: inout [Template], moveWorkoutAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        guard sourceIndexPath != destinationIndexPath else { return }
        
        let workoutToMove = templates.remove(at: sourceIndexPath.row)
        templates.insert(workoutToMove, at: destinationIndexPath.row)
        
        workoutDao.updateTemplatesPositions(&templates)
    }
}
