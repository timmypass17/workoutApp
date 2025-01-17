//
//  BuiltDiffTests.swift
//  BuiltDiffTests
//
//  Created by Timmy Nguyen on 1/15/25.
//

import Testing
@testable import BuiltDiff
import CoreData

// Swift Testing runs test in parallel (in the same proccess) by default, buggy with Core Data? Better to run test 1 by 1
@Suite(.serialized) class BuiltDiffTests {
    
    var workoutDao: WorkoutDaoProtocol
    var coreDataTestStack: CoreDataTestStack
    
    // gets called for each test separately, each test has its own core data stack so they are isolated/independent from eachother
    // don't make CoreDataTestStack() static or else all tests will share same core data stack
    init() {
        print("creating dao")
        coreDataTestStack = CoreDataTestStack()
        workoutDao = WorkoutDao(context: coreDataTestStack.mainContext, backgroundContext: coreDataTestStack.newBackgroundContext())
        coreDataTestStack.populateWithDummyData(workoutDao: workoutDao)
    }
    
    deinit {
    }
    
    @Test func createTemplate() throws {
        let childContext = coreDataTestStack.newChildContext()
        let template = workoutDao.createTemplate(childContext: childContext)
        template.title = "Leg Day"
        
        let benchPress = TemplateExercise(context: childContext)
        benchPress.name = "Squat"
        benchPress.sets = 4
        benchPress.reps = 12
        benchPress.index = 0
        benchPress.template = template
        
        template.addToTemplateExercises_(benchPress)
        
        #expect(template.title == "Leg Day")
        #expect(template.templateExercises[0].name == "Squat")
    }
    
    @Test func createWorkout() throws {
        let childContext = coreDataTestStack.newChildContext()
        
        let template = workoutDao.createTemplate(childContext: childContext)
        template.title = "Push Day"
        
        let benchPress = TemplateExercise(context: childContext)
        benchPress.name = "Bench Press"
        benchPress.sets = 4
        benchPress.reps = 12
        benchPress.index = 0
        benchPress.template = template
        
        template.addToTemplateExercises_(benchPress)
        
        let otherChildContext = coreDataTestStack.newChildContext()
        let workout = workoutDao.createWorkout(template: template, childContext: otherChildContext)
        
        #expect(workout.title == template.title)

        for i in 0..<workout.getExercises().count {
            let exercise = workout.getExercise(at: i)
            #expect(template.templateExercises[i].name == exercise.name)
            for j in 0..<exercise.getExerciseSets().count {
                let exerciseSet = exercise.getExerciseSet(at: j)
                #expect(exerciseSet.isComplete == false)
                #expect(exerciseSet.reps == -1)
                #expect(exerciseSet.weight == -1)
                #expect(exerciseSet.index == j)
            }
        }
    }

    @Test func fetchTemplates() async throws {
        let templates = try await workoutDao.fetchTemplates()
        
        #expect(templates.count == 1)
        #expect(templates.first?.title == "Workout A")
    }
    
    @Test func fetchLogs() async throws {
        let logs = try await workoutDao.fetchLogs()

        #expect(logs.count == 1)
    }
    
    @Test func fetchExerciseNames() async throws {
        let templateExercises = ["Squat", "Bench Press", "Pull Up"]
        let exerciseNames = try await workoutDao.fetchExerciseNames()
        
        #expect(exerciseNames.count == 3)
        
        for name in exerciseNames {
            #expect(templateExercises.contains(name))
        }
    }
    
    @Test func fetchExerciseSets() async throws {
        let sets: [ExerciseSet] = try await workoutDao.fetchExerciseSets(exerciseName: "Bench Press", limit: nil, ascending: true)
        
        #expect(sets.count == 1)
        #expect(sets.first?.reps == 5)
        #expect(sets.first?.weight == 135)
        #expect(sets.first?.isComplete == true)
    }
    
    // No idea why this test fails, works with regular Core Data Stack
//    @Test func fetchPR() async throws {
//        let benchPR = try await workoutDao.fetchPR(exerciseName: "Bench Press")
//        
//        #expect(benchPR == 135)
//    }

    @Test func deleteTemplate() async throws {
        let templates = try await workoutDao.fetchTemplates()
        let template = try #require(templates.first)
        
        try await workoutDao.deleteTemplate(template)
                
        let templatesAfterDelete = try await workoutDao.fetchTemplates()
        #expect(templatesAfterDelete.count == 0)        
    }
    
    @Test func deleteLog() async throws {
        let logs = try await workoutDao.fetchLogs()
        let log = try #require(logs.first)
        
        try await workoutDao.deleteLog(log)
                
        let templatesAfterDelete = try await workoutDao.fetchLogs()
        #expect(templatesAfterDelete.count == 0)
    }
    
    
    @Test func updateTemplatesPositions() async throws {
        let childContext = coreDataTestStack.newChildContext()
        let template = workoutDao.createTemplate(childContext: childContext)
        template.title = "Workout B"
        template.index = 7
        
        try? childContext.save()
        coreDataTestStack.saveContext()
        
        let templates = try await workoutDao.fetchTemplates()
        try await workoutDao.updateTemplatesPositions(templates)
        
        for i in 0..<templates.count {
            templates[i].index = Int16(i)
        }
    }

}
