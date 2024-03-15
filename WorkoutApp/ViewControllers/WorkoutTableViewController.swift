//
//  ViewController.swift
//  WorkoutApp
//
//  Created by Timmy Nguyen on 12/31/23.
//

import UIKit

class WorkoutTableViewController: UITableViewController {
    
    var workoutPlans: [Workout] = []
    var addButton: UIBarButtonItem!
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    let workoutService: WorkoutService
    
    init(workoutService: WorkoutService) {
        self.workoutService = workoutService
        workoutPlans = workoutService.fetchWorkoutPlans()
        super.init(style: .plain)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(tableView!,
                                               selector: #selector(UITableView.reloadData),
                                               name: AccentColor.valueChangedNotification, object: nil)
        
        updateUI()
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return workoutPlans.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: WorkoutTableViewCell.reuseIdentifier, for: indexPath) as! WorkoutTableViewCell
        let workout = workoutPlans[indexPath.row]
        cell.update(with: workout)
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let workoutPlan = workoutPlans[indexPath.row]
        let workoutDetailViewController = WorkoutDetailTableViewController(.startWorkout(workoutPlan))
        
        if let logTableViewController = (tabBarController?.viewControllers?[1] as? UINavigationController)?.viewControllers[0] as? LogTableViewController {
            workoutDetailViewController.delegate = logTableViewController
        }
        if let progressTableViewController = (tabBarController?.viewControllers?[2] as? UINavigationController)?.viewControllers[0] as? ProgressTableViewController {
            workoutDetailViewController.progressDelegate = progressTableViewController
        }
        
        navigationController?.pushViewController(workoutDetailViewController, animated: true)
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if (editingStyle == .delete) {
            // Changed relationship delete rule to "Cascade" (delete Workout A, deletes exercises and sets too)
            // When working with parent child context, there could be different contexts so u need to make sure u are deleting in same context that the object was created with (either child or main context)
            let workoutToDelete = workoutPlans[indexPath.row]
            if let workoutContext = workoutToDelete.managedObjectContext {
                workoutContext.delete(workoutToDelete)
                do {
                    try workoutContext.save()
                } catch {
                    print("Failed to delete workout plan: \(error)")
                }
            }
            workoutPlans.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .automatic)
            tableView.backgroundView?.isHidden = workoutPlans.isEmpty ? false : true
        }
    }
    
    override func tableView(_ tableView: UITableView, contextMenuConfigurationForRowAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
        return UIContextMenuConfiguration(identifier: nil, previewProvider: nil, actionProvider: { suggestedActions in
            let editAction =  UIAction(title: "Edit Workout", image: UIImage(systemName: "arrow.up.square")) { [self] _ in
                let template = workoutPlans[indexPath.row]
                let workoutDetailTableViewController = WorkoutDetailTableViewController(.updateWorkout(template))
                workoutDetailTableViewController.delegate = self
                navigationController?.pushViewController(workoutDetailTableViewController, animated: true)
            }

            let deleteAction = UIAction(title: "Delete Workout", image: UIImage(systemName: "trash"), attributes: .destructive) { _ in
                // TODO: Delete workout plan. Add alert confirming deletion
                // TODO: Fix decimal formatting when using kg (and incrementing by 2.5)
                // self.performDelete(indexPath)
            }
            return UIMenu(title: "", children: [editAction, deleteAction])
        })
    }

    func updateUI() {
        navigationItem.title = "Workout"
        navigationController?.navigationBar.prefersLargeTitles = true
        tableView.register(WorkoutTableViewCell.self, forCellReuseIdentifier: WorkoutTableViewCell.reuseIdentifier)
        tableView.backgroundView = EmptyLabel(text: "Tap the '+' button to create your first workout template!")
        tableView.backgroundView?.isHidden = workoutPlans.isEmpty ? false : true
        setupAddButton()
        tableView.dragDelegate = self
        tableView.dragInteractionEnabled = true
        tableView.reloadData()
    }
    
    func setupAddButton() {
        let addWorkoutAction = UIAction { _ in
            let alert = UIAlertController(title: "Create Workout Template", message: "Enter name below", preferredStyle: .alert)
            
            alert.addTextField { textField in
                textField.placeholder = "Ex. Push Day"
                textField.autocapitalizationType = .sentences
                let textChangedAction = UIAction { _ in
                    alert.actions[1].isEnabled = textField.text!.count > 0
                }
                textField.addAction(textChangedAction, for: .allEditingEvents)
            }
            
            let createAction = UIAlertAction(title: "Create", style: .default, handler: { [self] _ in
                guard let title = alert.textFields?[0].text else { return }
                let workoutDetailTableViewController = WorkoutDetailTableViewController(.createWorkout(title))
                workoutDetailTableViewController.delegate = self
                self.navigationController?.pushViewController(workoutDetailTableViewController, animated: true)
            })
            
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
            alert.addAction(createAction)
            
            
            self.present(alert, animated: true, completion: nil)
        }
        
        addButton = UIBarButtonItem(title: "Add Workout", image: UIImage(systemName: "plus"), primaryAction: addWorkoutAction)
        navigationItem.rightBarButtonItem = addButton
    }
}
//
extension WorkoutTableViewController: UITableViewDragDelegate {
    func tableView(_ tableView: UITableView, itemsForBeginning session: UIDragSession, at indexPath: IndexPath) -> [UIDragItem] {
        let dragItem = UIDragItem(itemProvider: NSItemProvider())
        dragItem.localObject = workoutPlans[indexPath.row]
        return [dragItem]
    }
    
    override func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        guard sourceIndexPath != destinationIndexPath else { return  }
        
        let mover = workoutPlans.remove(at: sourceIndexPath.row)
        workoutPlans.insert(mover, at: destinationIndexPath.row)
        
        // Save new ordering positions
        for (index, workout) in workoutPlans.enumerated() {
            workout.index = Int16(index)
        }
        
        do {
            try context.save()
            print("save: \(context)")
        } catch {
            print("Error saving reordering: \(error)")
        }
    }
}

extension WorkoutTableViewController: WorkoutDetailTableViewControllerDelegate {
    func workoutDetailTableViewController(_ viewController: WorkoutDetailTableViewController, didCreateWorkout workout: Workout) {
        workout.index = Int16(workoutPlans.count)
        do {
            if let workoutContext = workout.managedObjectContext {
                try workoutContext.save()
            }
        } catch {
            print("Error saving index: \(error)")
        }
        workoutPlans.append(workout)
        updateUI()
    }
    
    func workoutDetailTableViewController(_ viewController: WorkoutDetailTableViewController, didUpdateWorkout workout: Workout) {
        print("didUpdateWorkout")
        workout.printPrettyString()
        workoutPlans = workoutService.fetchWorkoutPlans()
        updateUI()
    }
    
    func workoutDetailTableViewController(_ viewController: WorkoutDetailTableViewController, didFinishWorkout workout: Workout) {
        return
    }
    
    func workoutDetailTableViewController(_ viewController: WorkoutDetailTableViewController, didUpdateLog workout: Workout) {
        return
    }
}
