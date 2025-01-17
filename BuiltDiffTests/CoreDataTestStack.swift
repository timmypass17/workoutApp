//
//  CoreDataTestStack.swift
//  BuiltDiffTests
//
//  Created by Timmy Nguyen on 1/15/25.
//

import CoreData
@testable import BuiltDiff

class CoreDataTestStack {
    
    init() {
        
    }
    
    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "BuiltDiff")
//        let description = container.persistentStoreDescriptions.first
//        description?.type = NSInMemoryStoreType // data isn't persisted to disk, tests are isolated, avoid side effects
        let description = NSPersistentStoreDescription()
        description.type = NSInMemoryStoreType
        container.persistentStoreDescriptions = [description]
        
        container.loadPersistentStores { storeDescription, error in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        }

        return container
    }()
    
    lazy var mainContext: NSManagedObjectContext = {
        return self.persistentContainer.viewContext
    }()
    
    func saveContext() {
        let context = mainContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }

    func newChildContext() -> NSManagedObjectContext {
        let childContext = NSManagedObjectContext(.privateQueue)
        childContext.parent = mainContext
        return childContext
    }

    func newBackgroundContext() -> NSManagedObjectContext {
        return persistentContainer.newBackgroundContext()
    }
    
    func populateWithDummyData(workoutDao: WorkoutDaoProtocol) {
        print("test mainContext: \(mainContext)")
        let template = workoutDao.createTemplate(childContext: mainContext)
        
        template.title = "Workout A"
        template.index = 0

        let templateExercises = ["Squat", "Bench Press", "Pull Up"]
        for i in 0..<templateExercises.count {
            let templateExercise = TemplateExercise(context: mainContext)
            templateExercise.name = templateExercises[i]
            templateExercise.sets = 5
            templateExercise.reps = 5
            templateExercise.index = Int16(i)
            templateExercise.template = template
        }

        let workout = workoutDao.createWorkout(template: template, childContext: mainContext)
        for exercise in workout.getExercises() {
            for set in exercise.getExerciseSets() {
                set.isComplete = true
                set.reps = 5
                set.weight = 135.0
            }
        }
        
        try? mainContext.save()
    }
}
