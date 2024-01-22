//
//  AddWorkoutTableViewController.swift
//  WorkoutApp
//
//  Created by Timmy Nguyen on 1/1/24.
//

import UIKit
import CoreData

protocol AddWorkoutTableViewControllerDelegate: AnyObject {
    func addWorkoutTableViewController(_ viewController: AddWorkoutTableViewController, didSaveWorkoutPlan workoutPlan: WorkoutPlan)
}

class AddWorkoutTableViewController: UITableViewController {
    
    var workoutPlan: WorkoutPlan!

    weak var delegate: AddWorkoutTableViewControllerDelegate?
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    enum Section: Int {
        case name
        case exercises
    }
    
    var saveButton: UIBarButtonItem = {
        let button = UIBarButtonItem(systemItem: .save)
        button.isEnabled = false
        return button
    }()
    
    var cancelButton: UIBarButtonItem = {
        let button = UIBarButtonItem(systemItem: .cancel)
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "New Workout"
        
        // Initalize empty workout (don't add it to context, yet)
        workoutPlan = WorkoutPlan(entity: WorkoutPlan.entity(), insertInto: nil)
        workoutPlan.title = ""
        
        let newExercise = PlanItem(entity: PlanItem.entity(), insertInto: nil)
        newExercise.title = ""
        newExercise.sets = ""
        newExercise.reps = ""
        newExercise.weight = ""
        workoutPlan.insertIntoPlanItems(newExercise, at: workoutPlan.planItems!.count)
        
        let saveAction = UIAction { [self] _ in
            do {
                // Add objects to context to be saved
                context.insert(workoutPlan)
                workoutPlan.planItems?.forEach { context.insert($0 as! PlanItem) }
                workoutPlan.planItems?.forEach { ($0 as! PlanItem).workoutPlan = workoutPlan }
                
                try context.save()
                
                delegate?.addWorkoutTableViewController(self, didSaveWorkoutPlan: workoutPlan)
            } catch {
                print("Failed to save workout plan: \(error)")
            }
            self.navigationController?.dismiss(animated: true)
        }
        let cancelAction = UIAction { _ in
            self.navigationController?.dismiss(animated: true)
        }
        
        saveButton.primaryAction = saveAction
        cancelButton.primaryAction = cancelAction
        
        navigationItem.rightBarButtonItem = saveButton
        navigationItem.leftBarButtonItem = cancelButton
        
        tableView.register(WorkoutTitleTableViewCell.self, forCellReuseIdentifier: WorkoutTitleTableViewCell.reuseIdentifier)
        tableView.register(AddExerciseTableViewCell.self, forCellReuseIdentifier: AddExerciseTableViewCell.reuseIdentifier)
        tableView.register(AddItemTableViewCell.self, forCellReuseIdentifier: AddItemTableViewCell.reuseIdentifier)
        
        tableView.isEditing = true
    }
    
    func fetchExercises(for workoutPlan: WorkoutPlan) -> [PlanItem] {
        let request = PlanItem.fetchRequest()

        // Set up a predicate to filter by the person
        let predicate = NSPredicate(format: "workoutPlan == %@", workoutPlan)
        request.predicate = predicate

        do {
            let exercises = try context.fetch(request)
            return exercises
        } catch {
            print("Error fetching todos: \(error)")
            return []
        }
    }
    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let section = Section(rawValue: section) else { return 0 }
        switch section {
        case .name:
            return 1
        case .exercises:
            return (workoutPlan.planItems?.count ?? 0) + 1
        }
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let section = Section(rawValue: indexPath.section)!
        switch section {
        case .name:
            let cell = tableView.dequeueReusableCell(withIdentifier: WorkoutTitleTableViewCell.reuseIdentifier, for: indexPath) as! WorkoutTitleTableViewCell
            cell.delegate = self
            return cell
        case .exercises:
            if indexPath.row == workoutPlan.planItems?.count {
                let cell = tableView.dequeueReusableCell(withIdentifier: AddItemTableViewCell.reuseIdentifier, for: indexPath) as! AddItemTableViewCell
                cell.update(title: "Add Exercise")
                cell.delegate = self
                cell.selectionStyle = .none
                return cell
            } else {
                let cell = tableView.dequeueReusableCell(withIdentifier: AddExerciseTableViewCell.reuseIdentifier, for: indexPath) as! AddExerciseTableViewCell
                let exercise = workoutPlan.planItems?[indexPath.row] as! PlanItem
                cell.update(with: exercise)
                cell.delegate = self
                return cell
            }
        }
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let section = Section(rawValue: section)!
        switch section {
        case .name:
            return "Workout Name"
        case .exercises:
            return "Exercises"
        }
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        guard let section = Section(rawValue: indexPath.section) else { return false }
        switch section {
        case .name:
            return false
        case .exercises:
            return indexPath.row != workoutPlan.planItems?.count
        }
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if (editingStyle == .delete) {
            workoutPlan.removeFromPlanItems(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .automatic)
        }
    }
    
    override func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        let exercise = workoutPlan.planItems?[sourceIndexPath.row] as! PlanItem
        workoutPlan.removeFromPlanItems(at: sourceIndexPath.row)
        workoutPlan.insertIntoPlanItems(exercise, at: destinationIndexPath.row)
    }
    
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        guard let section = Section(rawValue: indexPath.section) else { return false }
        switch section {
        case .name:
            return false
        case .exercises:
            return true
        }
    }
    
    private func validInput() -> Bool {
        guard let title = workoutPlan.title,
              let planItems = workoutPlan.planItems?.array as? [PlanItem]
        else {
            return false
        }
        
        if title.isEmpty {
            return false
        }
        
        for item in planItems {
            if let title = item.title, let sets = item.sets, let reps = item.reps, let weight = item.weight {
                if title.isEmpty || sets.isEmpty || reps.isEmpty || weight.isEmpty {
                    return false
                }
            }
        }
        
        return true
    }
    
//    func createWorkoutPlan(title: String, exercises: [AddExerciseItem]) {
//        let newWorkoutPlan = WorkoutPlan(context: context)
//        newWorkoutPlan.title = title
//        newWorkoutPlan.exercises = exercises
//        
//        do {
//            try context.save()
//        } catch {
//            print("Failed to create workout plan: \(error)")
//        }
//    }
}

// MARK: - Table view delegates

extension AddWorkoutTableViewController: WorkoutTitleTableViewCellDelegate {
    func workoutTitleTableViewCell(_ cell: WorkoutTitleTableViewCell, didUpdateTitle title: String) {
        workoutPlan.title = title
        saveButton.isEnabled = validInput()
    }
}

extension AddWorkoutTableViewController: AddWorkoutFooterViewDelegate {
    func didTapAddExerciseButton(_ sender: UIButton) {
//        guard let count = workoutPlan.planItems?.count else { return }
//        let exercise = PlanItem(entity: PlanItem.entity(), insertInto: nil)
//        exercise.title = ""
//        exercise.sets = ""
//        exercise.reps = ""
//        exercise.weight = ""
//        
//        workoutPlan.insertIntoPlanItems(exercise, at: count)
//        let newIndexPath = IndexPath(row: count, section: Section.exercises.rawValue)
//        tableView.insertRows(at: [newIndexPath], with: .automatic)
    }
}

extension AddWorkoutTableViewController: AddExerciseTableViewCellDelegate {
    func addExerciseTableViewCell(_ cell: AddExerciseTableViewCell, didUpdatePlanItem planItem: PlanItem) {
        guard let indexPath = tableView.indexPath(for: cell) else { return }
        // TODO: Don't need to reassign, look at workout Detail vc. Object is class so pass by ref
        let existingItem = workoutPlan.planItems?[indexPath.row] as! PlanItem
        existingItem.title = planItem.title
        existingItem.sets = planItem.sets
        existingItem.reps = planItem.reps
        existingItem.weight = planItem.weight
        saveButton.isEnabled = validInput()
    }
}


extension AddWorkoutTableViewController: AddItemTableViewCellDelegate {
    func didTapAddButton(_ cell: UITableViewCell) {
        guard let count = workoutPlan.planItems?.count else { return }
        let exercise = PlanItem(entity: PlanItem.entity(), insertInto: nil)
        exercise.title = ""
        exercise.sets = ""
        exercise.reps = ""
        exercise.weight = ""
        
        workoutPlan.insertIntoPlanItems(exercise, at: count)
        let newIndexPath = IndexPath(row: count, section: Section.exercises.rawValue)
        tableView.insertRows(at: [newIndexPath], with: .automatic)
    }
    
    
}

#Preview {
    UINavigationController(rootViewController: AddWorkoutTableViewController())
}
