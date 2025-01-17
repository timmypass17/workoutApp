//
//  WorkoutDaoProtocol.swift
//  BuiltDiff
//
//  Created by Timmy Nguyen on 1/14/25.
//

import Foundation
import CoreData

// TODO: Test all these
protocol WorkoutDaoProtocol {
    func createTemplate(childContext: NSManagedObjectContext) -> Template
    func createWorkout(template: Template, childContext: NSManagedObjectContext) -> Workout
    func fetchTemplates() async throws -> [Template]
    func fetchLogs() async throws -> [Workout]
    func fetchExerciseNames() async throws -> [String]
    func fetchExerciseSets(exerciseName: String, limit: Int?, ascending: Bool) async throws -> [ExerciseSet]
    func fetchPR(exerciseName: String) async throws -> Double
    func deleteTemplate(_ template: Template) async throws
    func deleteLog(_ log: Workout) async throws
    func updateTemplatesPositions(_ templates: [Template]) async throws
}
