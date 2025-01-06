//
//  ExerciseData.swift
//  BuiltDiff
//
//  Created by Timmy Nguyen on 1/5/25.
//

import Foundation

class ExerciseData: ObservableObject {
    @Published var name: String
    @Published var exerciseSets: [ExerciseSet]
    @Published var bestLift: Double
    @Published var lastUpdated: Date
    @Published var latestLift: Double
    
    init(name: String, exerciseSets: [ExerciseSet], bestLift: Double, lastUpdated: Date, latestLift: Double) {
        self.name = name
        self.exerciseSets = exerciseSets
        self.bestLift = bestLift
        self.lastUpdated = lastUpdated
        self.latestLift = latestLift
    }
}
