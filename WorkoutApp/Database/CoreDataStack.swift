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
    
    lazy var persistentContainer: NSPersistentCloudKitContainer = {
        let container = NSPersistentCloudKitContainer(name: "BuiltDiff")
        
        container.loadPersistentStores { storeDescription, error in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        }
//        container.viewContext.automaticallyMergesChangesFromParent = true
//        container.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        return container
    }()
    
    // Main context for use on the main thread
    lazy var mainContext: NSManagedObjectContext = {
        // To ensure that changes saved in a background or child context are automatically reflected in the main contex
        // - This reduces the need for manually merging changes after saving the child or background context.
        let context = persistentContainer.viewContext
        context.automaticallyMergesChangesFromParent = true
        return context // only use on main queue of your app
        // designed to be thread-safe for use on the main queue. It's primarily used for operations that interact with the UI, such as fetching data to display in views or updating UI-bound objects.
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
        
    // Child Context: A child context is a context that has a parent context
    // Use a child context for operations that you might want to discard or modify before committing them to the parent context (like editing a record temporarily)
    func newChildContext() -> NSManagedObjectContext {
        let childContext = NSManagedObjectContext(.privateQueue) // only access it through the perform(_:) and the performAndWait(_:) methods
        childContext.parent = mainContext
        return childContext
        
        // Changes made in a child context are not saved directly to the persistent store. Instead, they're "pushed" up to the parent context using save(), and the parent context also needs to save for changes to be persisted in the store.
    }
    
    // Background Context: The background context is a private queue context, but it’s not a child of the main context.
    // Use a background context for heavier operations that need to be committed directly to the persistent store, such as importing data or performing batch operations.
    func newBackgroundContext() -> NSManagedObjectContext {
        return persistentContainer.newBackgroundContext()   // private queue
        // no need for "double save" like child context
        // When you call backgroundContext.save(), the changes are immediately persisted to the persistent store.
        // You do not need to save the main context separately because the background context is not its child
    }
}

// Core Data Notes:
// Note: main context for reads, background context for writes
// 1. In general, avoid doing data processing on the main queue that’s not user-related. Data processing can be CPU-intensive, and if it’s performed on the main queue, it can result in unresponsiveness in the user interface
//  - e.g. If your application processes data, such as importing data into Core Data from JSON, create a private queue context and perform the import on the private context
// 2. Don’t pass managed object instances between queues. Doing so can result in corruption of the data and termination of the app. When it’s necessary to hand off a managed object reference from one queue to another, use NSManagedObjectID instances.

// When to Use Each
// Child Context:
//      Use for temporary or isolated changes that you want to push to a parent context before persisting.
//          - e.g. editing a draft entity that updates the UI in real-time (via mainContext).
// Private Context:
//      Use for large, long-running tasks that need to directly persist changes to the store without involving the mainContext.
//          - e.g. importing/exporting data
