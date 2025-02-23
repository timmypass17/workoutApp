//
//  WorkoutViewController.swift
//  BuiltDiff
//
//  Created by Timmy Nguyen on 12/25/24.
//

import UIKit
import CoreData

// TODO: Ensure localization works

class WorkoutViewController: UIViewController {
    
    private let tableView: UITableView = {
        let tableView = UITableView()
        tableView.translatesAutoresizingMaskIntoConstraints = false
        return tableView
    }()
    
    private var contentUnavailableView: UIView = {
        var configuration = UIContentUnavailableConfiguration.empty()
        configuration.text = "No Workouts Yet"
        configuration.secondaryText = "Your workouts will appear here once you add them."
        configuration.image = UIImage(systemName: "dumbbell")

        let view = UIContentUnavailableView(configuration: configuration)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.isHidden = true
        return view
    }()
    
    private var addButton: UIBarButtonItem!
    
//    private let context = CoreDataStack.shared.mainContext
    private let workoutService: WorkoutService
    
//    private var templates: [Template] = []
    
    // https://developer.apple.com/documentation/coredata/nsfetchedresultscontroller
    var fetchedResultsController: NSFetchedResultsController<Template>! // source of truth
    var changeIsUserDriven = false

    init(workoutService: WorkoutService) {
        self.workoutService = workoutService
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "Workout"
        navigationController?.navigationBar.prefersLargeTitles = true
        tableView.dataSource = self
        tableView.delegate = self
        tableView.dragDelegate = self
        tableView.dragInteractionEnabled = true
        tableView.register(WorkoutTableViewCell.self, forCellReuseIdentifier: WorkoutTableViewCell.reuseIdentifier)
        
        addButton = UIBarButtonItem(image: UIImage(systemName: "plus"), primaryAction: didTapAddButton())
        navigationItem.rightBarButtonItem = addButton
        
        view.addSubview(tableView)
        view.addSubview(contentUnavailableView)

        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            contentUnavailableView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            contentUnavailableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            contentUnavailableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
        ])
        
        NotificationCenter.default.addObserver(tableView,
                                               selector: #selector(UITableView.reloadData),
                                               name: AccentColor.valueChangedNotification, object: nil)
        
        let fetchRequest: NSFetchRequest<Template> = Template.fetchRequest()
        let sortDescriptor = NSSortDescriptor(key: "index", ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        fetchedResultsController = NSFetchedResultsController(
            fetchRequest: fetchRequest,
            managedObjectContext: CoreDataStack.shared.mainContext,
            sectionNameKeyPath: nil,    // to define sections
            cacheName: nil)

        fetchedResultsController.delegate = self
        
        // Perform a fetch.
        do {
            // actually fetches from cloudkit, when delete and reinstall app
            try fetchedResultsController?.performFetch()
            contentUnavailableView.isHidden = !(fetchedResultsController.fetchedObjects?.isEmpty ?? true)
        } catch {
            // Handle error appropriately. It's useful to use
            // `fatalError(_:file:line:)` during development.
            fatalError("Failed to perform fetch: \(error.localizedDescription)")
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if let selectedIndexPath = tableView.indexPathForSelectedRow {
            tableView.deselectRow(at: selectedIndexPath, animated: true)
        }
    }
    
    func updateUI() {
        tableView.reloadData()
    }
    
    private func didTapAddButton() -> UIAction {
        return UIAction { _ in
            let createWorkoutViewController = CreateTemplateViewController(workoutService: self.workoutService)
            createWorkoutViewController.delegate = self
            let vc = UINavigationController(rootViewController: createWorkoutViewController)
            self.present(vc, animated: true)
        }
    }
    
    func showDeleteAlert(indexPath: IndexPath) {
        let templateToRemove = fetchedResultsController.object(at: indexPath)
        
        let alert = UIAlertController(title: "Delete Template?", message: "Are you sure you want to delete \"\(templateToRemove.title)\"", preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.addAction(UIAlertAction(title: "Remove", style: .destructive) { [weak self] _ in
            guard let self else { return }
            // Remove object
            var templates = fetchedResultsController.fetchedObjects!
            templates.remove(at: indexPath.row) // we deleting local copy to make sure we get updated index paths (fetchedResultsController.fetchedObjects is unchanged)

            CoreDataStack.shared.mainContext.delete(templateToRemove)   // actually affects fetchedResultsController.fetchedObjects
            CoreDataStack.shared.saveContext() // delegate removes tableview cells
            
            // Update template positions
            for (index, template) in templates.enumerated() {
                template.index = Int16(index)
            }
            
            CoreDataStack.shared.saveContext() // delegate updates cells
            // don't delete and update at same time, confuses delegate (so i split saveContext() it 2 parts)
        })
        
        self.present(alert, animated: true, completion: nil)
    }
    
    func didTapEditWorkoutButton(at indexPath: IndexPath) -> UIAction {
        return UIAction(title: "Edit Workout", image: UIImage(systemName: "square.and.pencil")) { _ in
            let template = self.fetchedResultsController.object(at: indexPath)
            let editTemplateViewController = EditTemplateViewController(template: template, workoutService: self.workoutService)
            editTemplateViewController.delegate = self
            let vc = UINavigationController(rootViewController: editTemplateViewController)
            self.present(vc, animated: true)
        }
    }
}

extension WorkoutViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return fetchedResultsController.sections?.count ?? 0
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let sectionInfo = fetchedResultsController?.sections?[section] else {
            return 0
        }
        
        return sectionInfo.numberOfObjects
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: WorkoutTableViewCell.reuseIdentifier, for: indexPath) as! WorkoutTableViewCell
        let template = fetchedResultsController.object(at: indexPath)
        cell.update(template: template)
        return cell
    }

}

extension WorkoutViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let template = fetchedResultsController.object(at: indexPath)
        
        let startWorkoutViewController = StartWorkoutViewController(template: template, workoutService: workoutService)
        
        let logTableViewController = (tabBarController?.viewControllers?[1] as? UINavigationController)?.viewControllers[0] as! LogViewController

        let progressTableViewController = (tabBarController?.viewControllers?[2] as? UINavigationController)?.viewControllers[0] as! ProgressViewController
        startWorkoutViewController.progressDelegate = progressTableViewController

        navigationController?.pushViewController(startWorkoutViewController, animated: true)
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if (editingStyle == .delete) {
            // Changed relationship delete rule to "Cascade" (delete Workout A, deletes exercises and sets too)
            // When working with parent child context, there could be different contexts so u need to make sure u are deleting in same context that the object was created with (either child or main context)
            showDeleteAlert(indexPath: indexPath)
        }
    }
    
    func tableView(_ tableView: UITableView, contextMenuConfigurationForRowAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
        return UIContextMenuConfiguration(identifier: nil, previewProvider: nil, actionProvider: { suggestedActions in
            let deleteAction = UIAction(title: "Delete Workout", image: UIImage(systemName: "trash"), attributes: .destructive) { _ in
                self.showDeleteAlert(indexPath: indexPath)
            }
            return UIMenu(title: "", children: [self.didTapEditWorkoutButton(at: indexPath), deleteAction])
        })
    }
    
}


extension WorkoutViewController: UITableViewDragDelegate {
    func tableView(_ tableView: UITableView, itemsForBeginning session: UIDragSession, at indexPath: IndexPath) -> [UIDragItem] {
        let dragItem = UIDragItem(itemProvider: NSItemProvider())
        let template = fetchedResultsController.object(at: indexPath)
        dragItem.localObject = template
        return [dragItem]
    }
    
    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        guard sourceIndexPath != destinationIndexPath else { return  }
        changeIsUserDriven = true
        defer { changeIsUserDriven = false }
        
        var templates = fetchedResultsController.fetchedObjects!
        
        // https://developer.apple.com/documentation/coredata/nsfetchedresultscontrollerdelegate#1661452
        // moving row -> side effect of causing the fetched results controller to also notice the change and try to update (use flag to ignore update)
        // why ignore update by nsfetchedresultcontroller? the table view is already in the appropriate state because of the user’s action.
        let removedObject = templates.remove(at: sourceIndexPath.row)
        templates.insert(removedObject, at: destinationIndexPath.row)
        
        for (index, template) in templates.enumerated() {
            template.index = Int16(index)
        }
        
        CoreDataStack.shared.saveContext()
        // controller delegates called here (ignored by changeIsUserDriven)
        // changeIsUserDriven = false (by defer)
        
//        drag
//        move
//        changeIsUserDriven: true
//        save to core data
//        controller changeIsUserDriven: true
//        controller changeIsUserDriven: true
//        controller changeIsUserDriven: true
//        changeIsUserDriven: true
    }
    
}

extension WorkoutViewController: CreateTemplateViewControllerDelegate {
    func createTemplateViewController(_ viewController: CreateTemplateViewController, didCreateTemplate template: Template) {
        template.index = Int16(fetchedResultsController.fetchedObjects?.count ?? 0)
        
        // Important: Make sure u finish modifying child object before saving or else additional changes wont be persisted to core data when saving main context
        // Have to save here because needed to update index. Or maybe pass index ahead of time
        do {
            try viewController.childContext.save()
        } catch {
            print("Error creating template: \(error)")
        }
        
        CoreDataStack.shared.saveContext()
    }
}

extension WorkoutViewController: EditTemplateViewControllerDelegate {
    func editTemplateViewController(_ viewController: EditTemplateViewController, didUpdateTemplate template: Template) {
        
        for (index, templateExercise) in template.templateExercises.enumerated() {
            templateExercise.index = Int16(index)
            print("\(templateExercise.name) \(templateExercise.index)")
        }
        
        do {
            try viewController.childContext.save()
        } catch {
            print("Error updating template: \(error)")
        }
        
        CoreDataStack.shared.saveContext()
    }
}

// do stuff when changes in context happen
extension WorkoutViewController: NSFetchedResultsControllerDelegate {
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<any NSFetchRequestResult>) {
        tableView.beginUpdates()
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<any NSFetchRequestResult>) {
        tableView.endUpdates()
        contentUnavailableView.isHidden = !(controller.fetchedObjects?.isEmpty ?? true)
    }
    
    // Find out when the fetched results controller adds, removes, moves, or updates a fetched object.
    func controller(_ controller: NSFetchedResultsController<any NSFetchRequestResult>,
                    didChange anObject: Any,
                    at indexPath: IndexPath?,
                    for type: NSFetchedResultsChangeType,
                    newIndexPath: IndexPath?) {
        
        guard changeIsUserDriven == false else { return }

        switch type {
        case .insert:
            guard let newIndexPath else { return }
            // Insert a new row with fade animation when the fetched results
            // controller adds or moves an object to the specified index path.
            print("Insert row: \(newIndexPath)")
            tableView.insertRows(at: [newIndexPath], with: .fade)
        case .delete:
            guard let indexPath else { return }
            // Delete the row with animation at the old index path when the fetched
            // results controller deletes or moves the associated object.
            print("Delete row: \(indexPath)")
            tableView.deleteRows(at: [indexPath], with: .fade)
        case .update:
            guard let indexPath else { return }
            // Update the cell as the specified indexPath.
            print("Update row: \(indexPath)")
            if let cell = tableView.cellForRow(at: indexPath) as? WorkoutTableViewCell {
                let template = fetchedResultsController.object(at: indexPath)
                cell.update(template: template)
            }
        case .move:
            guard let indexPath, let newIndexPath else { return }
            print("Move row: \(indexPath) to \(newIndexPath)")
            // Move a row from the specified index path to the new index path.
            tableView.moveRow(at: indexPath, to: newIndexPath)
        @unknown default:
            break
        }
    }
}
