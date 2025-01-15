//
//  WorkoutDaoProtocol.swift
//  BuiltDiff
//
//  Created by Timmy Nguyen on 1/14/25.
//

import Foundation

protocol WorkoutDaoProtocol {
    func fetchTemplates() -> [Template]
    func fetchLogs() -> [Workout]
    func fetchExerciseNames() -> [String]
    func fetchExerciseSets(exerciseName: String, limit: Int?, ascending: Bool) -> [ExerciseSet]
    func fetchPR(exerciseName: String) -> Double
    func deleteTemplate(_ template: Template)
    func deleteLog(_ log: Workout)
    func updateTemplatesPositions(_ templates: inout [Template])
}
