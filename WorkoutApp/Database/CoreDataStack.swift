//
//  CoreDataStack.swift
//  BuiltDiff
//
//  Created by Timmy Nguyen on 12/25/24.
//

import Foundation
import CoreData

class CoreDataStack {
    
    static let shared = CoreDataStack()
    
    private init() {
        // Prevents direct initialization. To enforce a single instance of the class
    }
    
    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "BuiltDiff")
        container.loadPersistentStores { storeDescription, error in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        }
        return container
    }()
    
    // Main context for use on the main thread
    lazy var mainContext: NSManagedObjectContext = {
        // To ensure that changes saved in a background or child context are automatically reflected in the main contex
        // - This reduces the need for manually merging changes after saving the child or background context.
        //  context.automaticallyMergesChangesFromParent = true
        return self.persistentContainer.viewContext
    }()
    
    // Save changes in the main context
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
    
    // work on temporary changes in isolation and commit them to the parent
    func newChildContext() -> NSManagedObjectContext {
        let childContext = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
        childContext.parent = mainContext
        return childContext
    }
    
}
