//
//  ViewController.swift
//  WorkoutApp
//
//  Created by Timmy Nguyen on 12/31/23.
//

import UIKit

class WorkoutTableViewController: UITableViewController {
    
    var workoutPlans: [WorkoutPlan] = []
    var addButton: UIBarButtonItem!
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("Workout viewDidLoad()")
        
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
        let workoutDetailViewController = WorkoutDetailTableViewController(workoutPlan: workoutPlan)
        
        if let logTableViewController = (tabBarController?.viewControllers?[1] as? UINavigationController)?.viewControllers[0] as? LogTableViewController {
            print("Got log vc")
            workoutDetailViewController.delegate = logTableViewController
        }
        navigationController?.pushViewController(workoutDetailViewController, animated: true)
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if (editingStyle == .delete) {
            deleteWorkoutPlan(workoutPlan: workoutPlans[indexPath.row])
            workoutPlans.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .automatic)
        }
    }
    
    func updateView() {
        // Register the custom cell class
        tableView.register(WorkoutTableViewCell.self, forCellReuseIdentifier: WorkoutTableViewCell.reuseIdentifier)
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.title = "Workout"
        workoutPlans = getWorkoutPlans()
        setupAddButton()
    }
    
    func setupAddButton() {
        let action = UIAction { _ in
            let addWorkoutTableViewController = AddWorkoutTableViewController()
            addWorkoutTableViewController.delegate = self
            self.present(UINavigationController(rootViewController: addWorkoutTableViewController), animated: true, completion: nil)
        }
        addButton = UIBarButtonItem(title: "Add Workout", image: UIImage(systemName: "plus"), primaryAction: action)
        navigationItem.rightBarButtonItem = addButton
    }
    
    func getWorkoutPlans() -> [WorkoutPlan] {
        do {
            return try context.fetch(WorkoutPlan.fetchRequest())
        } catch {
            print("Failed to get workout plans: \(error)")
            return []
        }
    }
    
    func deleteWorkoutPlan(workoutPlan: WorkoutPlan) {
        context.delete(workoutPlan)
        
        do {
            try context.save()
        } catch {
            print("Failed to delete workout plan: \(error)")
        }
    }
    
    //    func updateWorkoutPlan(workoutPlan: WorkoutPlan, updatedTitle: String, updatedExercises: NSSet) {
    //        workoutPlan.title = updatedTitle
    //        workoutPlan.addToExercises(updatedExercises)
    //
    //        do {
    //            try context.save()
    //        } catch {
    //            print("Failed to update workout plan: \(error)")
    //        }
    //    }
    
    
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

extension WorkoutTableViewController: AddWorkoutTableViewControllerDelegate {
    
    func addWorkoutTableViewController(_ viewController: AddWorkoutTableViewController, didSaveWorkoutPlan workoutPlan: WorkoutPlan) {
        workoutPlans.append(workoutPlan)
        tableView.reloadData()
    }
    
}

#Preview {
    UINavigationController(rootViewController: WorkoutTableViewController())
}

extension Notification.Name {
    static let workoutPlanUpdated = Notification.Name("WorkoutPlanUpdatedNotification")
}
