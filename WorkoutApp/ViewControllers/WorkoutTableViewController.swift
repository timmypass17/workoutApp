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
        updateView()
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
            deleteWorkout(workout: workoutPlans[indexPath.row])
            workoutPlans.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .automatic)
        }
    }
    
    func updateView() {
        // Register the custom cell class
        tableView.register(WorkoutTableViewCell.self, forCellReuseIdentifier: WorkoutTableViewCell.reuseIdentifier)
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.title = "Workout"
        setupAddButton()
    }
    
    func setupAddButton() {
        let addWorkoutAction = UIAction { _ in
            let alert = UIAlertController(title: "Create New Workout", message: "Enter a name below", preferredStyle: .alert)
            
            alert.addTextField { textField in
                textField.placeholder = "Ex. Workout A"
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

    func deleteWorkout(workout: Workout) {
        // Changed relationship delete rule to "Cascade" (delete Workout A, deletes exercises and sets too)
        // When working with parent child context, there could be different contexts so u need to make sure u are deleting in same context that the object was created with (either child or main context)
        if let workoutContext = workout.managedObjectContext {
            workoutContext.delete(workout)
            do {
                try workoutContext.save()
            } catch {
                print("Failed to delete workout plan: \(error)")
            }
        }
        
    }
    
    override func tableView(_ tableView: UITableView, contextMenuConfigurationForRowAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
        return UIContextMenuConfiguration(identifier: nil, previewProvider: nil, actionProvider: { suggestedActions in
            let editAction =  UIAction(title: "Edit Workout", image: UIImage(systemName: "arrow.up.square")) { _ in
                // TODO: Show edit workout view
            }

            let deleteAction = UIAction(title: "Delete Workout", image: UIImage(systemName: "trash"), attributes: .destructive) { _ in
                // TODO: delete
                // self.performDelete(indexPath)
            }
            return UIMenu(title: "", children: [editAction, deleteAction])
        })
    }
}

extension WorkoutTableViewController: WorkoutDetailTableViewControllerDelegate {
    func workoutDetailTableViewController(_ viewController: WorkoutDetailTableViewController, didCreateWorkout workout: Workout) {
        workoutPlans.append(workout)
        tableView.reloadData()
    }
    
    func workoutDetailTableViewController(_ viewController: WorkoutDetailTableViewController, didFinishWorkout workout: Workout) {
        return
    }
    
    func workoutDetailTableViewController(_ viewController: WorkoutDetailTableViewController, didUpdateLog workout: Workout) {
        return
    }
}

#Preview {
    UINavigationController(rootViewController: WorkoutTableViewController(workoutService: WorkoutService()))
}

extension Notification.Name {
    static let workoutPlanUpdated = Notification.Name("WorkoutPlanUpdatedNotification")
}
