//
//  WorkoutDetailTableViewController.swift
//  WorkoutApp
//
//  Created by Timmy Nguyen on 1/11/24.
//

import UIKit
import CoreData

// TODO: Split this delegate up, some classes don't implment some functionss
protocol WorkoutDetailTableViewControllerDelegate: AnyObject {
    func workoutDetailTableViewController(_ viewController: WorkoutDetailViewController, didCreateWorkout workout: Workout)
    func workoutDetailTableViewController(_ viewController: WorkoutDetailViewController, didUpdateWorkout workout: Workout)
    func workoutDetailTableViewController(_ viewController: WorkoutDetailViewController, didFinishWorkout workout: Workout)
    func workoutDetailTableViewController(_ viewController: WorkoutDetailViewController, didUpdateLog workout: Workout)
}

class WorkoutDetailViewController: UIViewController {
    
    private let tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .insetGrouped)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        return tableView
    }()
        
    weak var progressDelegate: WorkoutDetailTableViewControllerDelegate?
        
    var workout: Workout!
    let childContext = CoreDataStack.shared.newBackgroundContext()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = workout.title
        navigationController?.navigationBar.prefersLargeTitles = true
        tableView.dataSource = self
        tableView.delegate = self
        view.addSubview(tableView)

        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
    
        NotificationCenter.default.addObserver(tableView,
                                               selector: #selector(UITableView.reloadData),
                                               name: AccentColor.valueChangedNotification,
                                               object: nil)
                        
//        let footer = AddExerciseFooterView()
//        footer.frame = CGRect(x: 0, y: 0, width: tableView.frame.width, height: 42)
//        footer.delegate = self
//        tableView.tableFooterView = footer
        
        tableView.register(WorkoutDetailTableViewCell.self, forCellReuseIdentifier: WorkoutDetailTableViewCell.reuseIdentifier)
        tableView.register(AddSetTableViewCell.self, forCellReuseIdentifier: AddSetTableViewCell.reuseIdentifier)
    }
}

extension WorkoutDetailViewController: AddSetTableViewCellDelegate {
    func didTapAddSetButton(_ sender: AddSetTableViewCell) {
        guard let indexPath = tableView.indexPath(for: sender) else { return }
        
        let exercise = workout.getExercise(at: indexPath.section)
        let set = ExerciseSet(context: childContext)
        set.index = Int16(workout.getExercise(at: indexPath.section).getExerciseSets().count)
        set.isComplete = false
        set.weight = ""
        set.reps = ""
        set.exercise = exercise
        exercise.addToExerciseSets(set)
        
        tableView.insertRows(at: [indexPath], with: .automatic)
    }
}

extension WorkoutDetailViewController: WorkoutDetailTableViewCellDelegate {
    func workoutDetailTableViewCell(_ cell: WorkoutDetailTableViewCell, didTapIncrementRepsButton: Bool) {
        guard let indexPath = tableView.indexPath(for: cell) else { return }
        
        let exercise = workout.getExercise(at: indexPath.section)
        let set = exercise.getExerciseSets()[indexPath.row]
        
        let currentReps = Int(set.reps) ?? Int(cell.repsTextField.placeholder ?? "0") ?? 0
        
        let incrementedReps = currentReps + 1
        set.reps = String(incrementedReps)
        
        cell.repsTextField.text = set.reps
        
        if Settings.shared.enableHaptic {
            let generator = UIImpactFeedbackGenerator(style: .light)
            generator.impactOccurred()
        }
    }
    
    func workoutDetailTableViewCell(_ cell: WorkoutDetailTableViewCell, didTapDecrementRepsButton: Bool) {
        guard let indexPath = tableView.indexPath(for: cell) else { return }
        
        let exercise = workout.getExercise(at: indexPath.section)
        let set = exercise.getExerciseSets()[indexPath.row]
        
        let currentReps = Int(set.reps) ?? Int(cell.repsTextField.placeholder ?? "0") ?? 0
        
        let incrementedReps = currentReps - 1
        set.reps = String(incrementedReps)
        
        cell.repsTextField.text = set.reps
        
        if Settings.shared.enableHaptic {
            let generator = UIImpactFeedbackGenerator(style: .light)
            generator.impactOccurred()
        }
    }
    
    func workoutDetailTableViewCell(_ cell: WorkoutDetailTableViewCell, didTapIncrementWeightButton: Bool) {
        guard let indexPath = tableView.indexPath(for: cell) else { return }
        
        let exercise = workout.getExercise(at: indexPath.section)
        let set = exercise.getExerciseSets()[indexPath.row]
        
        let currentWeight = Double(set.weight) ?? Double(cell.weightTextField.placeholder ?? "0") ?? 0
        
        let incrementedWeight = currentWeight + Settings.shared.weightIncrement
        set.weight = formatWeight(incrementedWeight)
        
        cell.weightTextField.text = set.weight
        
        if Settings.shared.enableHaptic {
            let generator = UIImpactFeedbackGenerator(style: .light)
            generator.impactOccurred()
        }
    }
    
    func workoutDetailTableViewCell(_ cell: WorkoutDetailTableViewCell, didTapDecrementWeightButton: Bool) {
        guard let indexPath = tableView.indexPath(for: cell) else { return }
        
        let exercise = workout.getExercise(at: indexPath.section)
        let set = exercise.getExerciseSets()[indexPath.row]
        
        let currentWeight = Double(set.weight) ?? Double(cell.weightTextField.placeholder ?? "0") ?? 0
        
        let decrementedWeight = currentWeight - Settings.shared.weightIncrement
        set.weight = formatWeight(decrementedWeight)
        
        cell.weightTextField.text = set.weight
        
        if Settings.shared.enableHaptic {
            let generator = UIImpactFeedbackGenerator(style: .light)
            generator.impactOccurred()
        }
    }
    
    func workoutDetailTableViewCell(_ cell: WorkoutDetailTableViewCell, didTapNextButton: Bool) {
        guard let indexPath = tableView.indexPath(for: cell) else { return }
        
        if cell.weightTextField.isFirstResponder {
            cell.repsTextField.becomeFirstResponder()
            return
        }
        
        if cell.repsTextField.isFirstResponder {
            // Mark the current set as tapped
            workoutDetailTableViewCell(cell, didTapSetButton: true)
            
            // Determine if this is the last set of the last exercise
            let isLastExercise = indexPath.section == workout.getExercises().count - 1
            let isLastSet = indexPath.row == workout.getExercise(at: indexPath.section).getExerciseSets().count - 1
            
            guard !(isLastExercise && isLastSet) else { return }
            
            // Calculate the next index path
            let nextIndexPath: IndexPath
            let setCount = workout.getExercise(at: indexPath.section).getExerciseSets().count
            if indexPath.row + 1 < setCount {
                // Move to the next set in the same exercise
                nextIndexPath = IndexPath(row: indexPath.row + 1, section: indexPath.section)
            } else {
                // Move to the first set of the next exercise
                nextIndexPath = IndexPath(row: 0, section: indexPath.section + 1)
            }
            
            // Make the weight text field in the next cell the first responder
            let nextCell = tableView.cellForRow(at: nextIndexPath) as! WorkoutDetailTableViewCell
            nextCell.weightTextField.becomeFirstResponder()
        }
    }
    
    func workoutDetailTableViewCell(_ cell: WorkoutDetailTableViewCell, didTapPreviousButton: Bool) {
        if cell.repsTextField.isFirstResponder {
            cell.weightTextField.becomeFirstResponder()
            return
        }
        
        if cell.weightTextField.isFirstResponder {
            guard let indexPath = tableView.indexPath(for: cell) else { return }
            // If first textfield, do nothing
            if indexPath == IndexPath(row: 0, section: 0) {
                return
            }
            // Go to previous row
            let previousIndexPath: IndexPath
            if indexPath.row - 1 >= 0 {
                // Go to previous set
                previousIndexPath = IndexPath(row: indexPath.row - 1, section: indexPath.section)
            } else {
                // Go to previous exercise
                previousIndexPath = IndexPath(
                    row: workout.getExercise(at: indexPath.section - 1).getExerciseSets().count - 1,
                    section: indexPath.section - 1)
            }
            
            let previousCell = tableView.cellForRow(at: previousIndexPath) as! WorkoutDetailTableViewCell
            previousCell.repsTextField.becomeFirstResponder()
        }
    }

    func workoutDetailTableViewCell(_ cell: WorkoutDetailTableViewCell, didTapSetButton: Bool) {
        guard let indexPath = tableView.indexPath(for: cell) else { return }
        let exerciseSet = workout.getExercise(at: indexPath.section).getExerciseSet(at: indexPath.row)
        exerciseSet.isComplete = didTapSetButton
        
        if exerciseSet.weight.isEmpty {
            let weight = Float(cell.weightTextField.placeholder ?? "0") ?? 0.0
            exerciseSet.weight = String(format: "%g", weight)
            cell.weightTextField.text = cell.weightTextField.placeholder
        }
        
        if exerciseSet.reps.isEmpty {
            let reps = Int(cell.repsTextField.placeholder ?? "0") ?? 0
            exerciseSet.reps = String(reps)
            cell.repsTextField.text = cell.repsTextField.placeholder
        }
        
        if Settings.shared.enableHaptic {
            let generator = UIImpactFeedbackGenerator(style: .heavy)
            generator.impactOccurred()
        }
        
        // All cells in section have to be reloaded (checkmark is wierd if pressed randomly)
        // - reloading tableview rows disisses keyboard, so just update set button manually
        let indexPaths = (0..<workout.getExercise(at: indexPath.section).getExerciseSets().count)
            .map { IndexPath(row: $0, section: indexPath.section)}
        indexPaths.forEach {
            let cell = tableView.cellForRow(at: IndexPath(row: $0.row, section: $0.section)) as! WorkoutDetailTableViewCell
            cell.updateSetButton(exerciseSet: workout.getExercise(at: $0.section).getExerciseSet(at: $0.row))
        }
    }
    
    func workoutDetailTableViewCell(_ cell: WorkoutDetailTableViewCell, weightTextDidChange weightText: String) {
        guard let indexPath = tableView.indexPath(for: cell) else { return }
        let exerciseSet = workout.getExercise(at: indexPath.section).getExerciseSet(at: indexPath.row)
        
        exerciseSet.weight = weightText
        exerciseSet.isComplete = !exerciseSet.weight.isEmpty || !exerciseSet.reps.isEmpty
    }
    
    func workoutDetailTableViewCell(_ cell: WorkoutDetailTableViewCell, repsTextDidChange repsText: String) {
        guard let indexPath = tableView.indexPath(for: cell) else { return }
        let exerciseSet = workout.getExercise(at: indexPath.section).getExerciseSet(at: indexPath.row)
        
        exerciseSet.reps = repsText
        exerciseSet.isComplete = !exerciseSet.weight.isEmpty || !exerciseSet.reps.isEmpty
    }
}

extension WorkoutDetailViewController: AddExerciseFooterViewDelegate {
    func didTapAddExerciseButton(_ sender: UIButton) {
        let exercisesTableViewController = ExercisesTableViewController()
        exercisesTableViewController.delegate = self
        self.present(UINavigationController(rootViewController: exercisesTableViewController), animated: true, completion: nil)
    }
}

extension WorkoutDetailViewController: AddExerciseDetailViewControllerDelegate {
    func addExerciseDetailViewControllerDelegate(_ viewController: AddExerciseDetailViewController, didAddExercise exercise: String, sets: Int, reps: Int) {
        
    }
    
    func addExerciseDetailViewControllerDelegate(_ viewController: AddExerciseDetailViewController, didDismiss: Bool) {
        
    }

}

extension WorkoutDetailViewController: ExercisesTableViewControllerDelegate {
    func exercisesTableViewController(_ viewController: ExercisesTableViewController, didSelectExercises exercises: [String]) {
//        // Loop through exercises
//        for exerciseName in exercises {
//            let section = workoutModel.workout.getExercises().count
//            // Create exercise item
//            let exercise = Exercise(context: childContext)
//            exercise.name = exerciseName
//            exercise.workout = workoutModel.workout  // need to set parent aswell, workout.addToExercises(exercise) does not do this.
//            workoutModel.workout.addToExercises(exercise)
//            // Create a single exerciseSet item
//            let set = ExerciseSet(context: childContext)
//            set.isComplete = false
//            set.weight = ""
//            set.reps = ""
//            set.exercise = exercise
//            exercise.addToExerciseSets(set)
//            
////            // Add previous exercise
////            if let previousExercise = exercise.getPreviousExerciseDone() {
////                previousExercises[exercise.name] = previousExercise.getExerciseSets().map { ($0.weightString, $0.reps) }
////            }
//            // Add section (this also insert's row)
//            tableView.insertSections(IndexSet(integer: section), with: .automatic)
//        }
    }
}

extension WorkoutDetailViewController: ExerciseHeaderViewDelegate {
    func exerciseHeaderView(_ sender: ExerciseHeaderView, didRenameExercise name: String, viewForHeaderInSection section: Int) {
        let exercise = workout.getExercise(at: section)
        exercise.name = name
        tableView.reloadSections(IndexSet(integer: section), with: .automatic)
    }
}

extension String {
    var isNumeric: Bool {
        // Attempt to create an Int or Double from the string
        return Double(self) != nil
    }
}

//extension Collection {
//    /// Returns the element at the specified index if it is within bounds, otherwise nil.
//    subscript (safe index: Index) -> Element? {
//        return indices.contains(index) ? self[index] : nil
//    }
//}

extension WorkoutDetailViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return workout.getExercises().count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return workout.getExercise(at: section).getExerciseSets().count + 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let exercise = workout.getExercise(at: indexPath.section)
        let sets = exercise.getExerciseSets()
        
        let isAddSetButtonRow = indexPath.row == sets.count
        if isAddSetButtonRow {
            let cell = tableView.dequeueReusableCell(withIdentifier: AddSetTableViewCell.reuseIdentifier, for: indexPath) as! AddSetTableViewCell
            cell.delegate = self
            cell.selectionStyle = .none
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: WorkoutDetailTableViewCell.reuseIdentifier, for: indexPath) as! WorkoutDetailTableViewCell
            let exerciseSet = sets[indexPath.row]
            cell.delegate = self
            
            cell.update(exerciseSet: exerciseSet)
            
//            let previousWeights = previousExercises[exercise.name, default: []]
//            cell.update(with: workout, for: indexPath, previousWeights: previousWeights)
            return cell
        }
    }
}

extension WorkoutDetailViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let exercises = workout.getExercises()
        let header = ExerciseHeaderView(title: exercises[section].name, section: section)
        header.delegate = self
        header.editButton.isHidden = true
//        if case .updateWorkout(_) = state {
//            header.editButton.isHidden = false
//        } else {
//            header.editButton.isHidden = true
//        }
        return header
    }

    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        let exercise = workout.getExercise(at: indexPath.section)
        let exerciseSets = exercise.getExerciseSets()
        return indexPath.row != exerciseSets.count
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        let exercises = workout.getExercises()
        
        if (editingStyle == .delete) {
            exercises[indexPath.section].removeFromExerciseSets(at: indexPath.row)
            tableView.beginUpdates()
            tableView.deleteRows(at: [indexPath], with: .automatic)
//            if exercises[indexPath.section].getExerciseSets().count == 0 {
//                workout.removeFromExercises(exercises[indexPath.section])   // if set is empty, then remove exercise from workout
//                tableView.deleteSections(IndexSet(integer: indexPath.section), with: .automatic)
//            } else {
//                tableView.reloadSections(IndexSet(integer: indexPath.section), with: .automatic)
//            }
            
            tableView.endUpdates()
            
            // Reload indexpaths after the deleted rows
            var affectedIndexPaths: [IndexPath] = []
            for row in indexPath.row..<exercises[indexPath.section].getExerciseSets().count {
                affectedIndexPaths.append(IndexPath(row: row, section: indexPath.section))
                exercises[indexPath.section].getExerciseSets()[row].index = Int16(row)
            }
            
            tableView.reloadRows(at: affectedIndexPaths, with: .none)
            
            
//            updateUI()
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
}

/**
 Q1: Why do "let exercise = Exercise(entity: Exercise.entity(), insertInto: nil)"?
 - Because we do not want to create and add it to core data yet. User may decide not to create exercise.
 - Doing Exercise(context: context) gets added to context, and doing fetch still include those objects even though we didn't save the object via context.save(). (look at request.includesPendingChanges)
 - Doing Exercise(context: context) still leaves object in context even after exiting current vm or closing app. To remove model, you have to uninstall app or manually remove object from context
 
 Whenever user modifies core data object...
 - if context.save(), changes is persisted
 - if user doesn't save, unsaved changes are still persisted while app is active until user does context.save() or closes app (changes are discarded and not seen after reopening app)
    - actually this might be because context.save() is called in sceneDidEnterBackground()
 - unsaved changes are still temporarily saved in core data (so user still see thoses changes even tho they didn't fully commit to saving)
 */
