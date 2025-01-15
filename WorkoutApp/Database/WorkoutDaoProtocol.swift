//
//  WorkoutDaoProtocol.swift
//  BuiltDiff
//
//  Created by Timmy Nguyen on 1/14/25.
//

import Foundation

protocol WorkoutDaoProtocol {
    func fetchTemplates() async throws -> [Template] 
    func fetchLogs() async throws -> [Workout]
    func fetchExerciseNames() async throws -> [String]
    func fetchExerciseSets(exerciseName: String, limit: Int?, ascending: Bool) async throws -> [ExerciseSet]
    func fetchPR(exerciseName: String) async throws -> Double
    func deleteTemplate(_ template: Template) async throws
    func deleteLog(_ log: Workout) async throws
    func updateTemplatesPositions(_ templates: [Template]) async throws
}
