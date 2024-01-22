//
//  WorkoutDetailTableViewController.swift
//  WorkoutApp
//
//  Created by Timmy Nguyen on 1/11/24.
//

import UIKit

protocol WorkoutDetailTableViewControllerDelegate: AnyObject {
    func workoutDetailTableViewController(_ viewController: WorkoutDetailTableViewController, didSaveWorkout workout: Workout)
}


class WorkoutDetailTableViewController: UITableViewController {
    var workout: Workout!
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    weak var delegate: WorkoutDetailTableViewControllerDelegate?
    
    private let finishButton: UIBarButtonItem = {
        let button = UIBarButtonItem(title: "Finish")
        return button
    }()
    
    init(workoutPlan: WorkoutPlan) {
        //        workout = Workout(entity: Workout.entity(), insertInto: nil)
        workout = Workout(context: context)
        workout.title = workoutPlan.title
        workout.createdAt = .now
        if let planItems = workoutPlan.planItems?.array as? [PlanItem] {
            // Add exercises to workout
            for item in planItems {
                guard let sets = Int(item.sets ?? "0") else { continue }
                //                let exercise = Exercise(entity: Exercise.entity(), insertInto: nil)
                let exercise = Exercise(context: context)
                exercise.title = item.title
                // Add sets to exercises
                for _ in 0..<sets {
                    //                    let exerciseSet = ExerciseSet(entity: ExerciseSet.entity(), insertInto: nil)
                    let exerciseSet = ExerciseSet(context: context)
                    exerciseSet.reps = item.reps
                    exerciseSet.weight = item.weight
                    exercise.addToExerciseSets(exerciseSet)
                }
                workout.addToExercises(exercise)
            }
        }
        super.init(style: .plain)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = workout.title
        tableView.register(WorkoutDetailTableViewCell.self, forCellReuseIdentifier: WorkoutDetailTableViewCell.reuseIdentifier)
        tableView.register(AddItemTableViewCell.self, forCellReuseIdentifier: AddItemTableViewCell.reuseIdentifier)
        let finishAction = UIAction { _ in
            let alert = UIAlertController(title: "Finish Workout?", message: "Your workout lasted x minutes\nFriday, Jan 17, 2023", preferredStyle: .alert)
            alert.addTextField { textField in
                textField.placeholder = "Add your notes here..."
            }
            
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
            alert.addAction(UIAlertAction(title: "Done", style: .default, handler: { [self] _ in
                // TODO: Save workout
                do {
                    try self.context.save()
                    delegate?.workoutDetailTableViewController(self, didSaveWorkout: workout)
                    navigationController?.popViewController(animated: true)
                } catch {
                    print("Failed to save workout: \(error)")
                }
            }))
            
            self.present(alert, animated: true, completion: nil)
        }
        
        navigationItem.rightBarButtonItem?.primaryAction = finishAction
        navigationItem.rightBarButtonItem = finishButton
        
        //        let footer = AddWorkoutFooterView(title: "Add Exercise")
        //        footer.frame = CGRect(x: 0, y: 0, width: tableView.frame.width, height: 50)
        //        tableView.tableFooterView = footer
        updateUI()
    }
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        guard let exercises = workout.exercises else { return 0 }
        return exercises.count
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let exercises = workout.exercises?.array as? [Exercise],
              let exerciseSets = exercises[section].exerciseSets?.array as? [ExerciseSet]
        else { return 0 }
        return exerciseSets.count + 1 // extra for button
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let exercises = workout.exercises?.array as? [Exercise]
        let exerciseSets = exercises?[indexPath.section].exerciseSets?.array as? [ExerciseSet]
        let size = exerciseSets?.count
        
        if indexPath.row == size {
            let cell = tableView.dequeueReusableCell(withIdentifier: AddItemTableViewCell.reuseIdentifier, for: indexPath) as! AddItemTableViewCell
            cell.update(title: "Add Set")
            cell.delegate = self
            cell.selectionStyle = .none
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: WorkoutDetailTableViewCell.reuseIdentifier, for: indexPath) as! WorkoutDetailTableViewCell
            cell.delegate = self
            if let exerciseSet = exerciseSets?[indexPath.row] {
                cell.update(with: exerciseSet, for: indexPath)
            }
            return cell
        }
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        guard let exercises = workout.exercises?.array as? [Exercise] else { return nil }
        return exercises[section].title
    }
    
    // Swipe to delete
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        let exercises = workout.exercises?.array as? [Exercise]
        let exerciseSets = exercises?[indexPath.section].exerciseSets?.array as? [ExerciseSet]
        let size = exerciseSets?.count ?? 0
        
        return indexPath.row != size
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        guard let exercises = workout.exercises?.array as? [Exercise] else { return }
        
        if (editingStyle == .delete) {
            // handle delete (by removing the data from your array and updating the tableview)
            exercises[indexPath.section].removeFromExerciseSets(at: indexPath.row)
            tableView.beginUpdates()
            tableView.deleteRows(at: [indexPath], with: .automatic)
            tableView.reloadSections(IndexSet(integer: indexPath.section), with: .automatic)
            tableView.endUpdates()
            updateUI()
        }
    }
    
    func updateUI() {
        updateFinishButton()
    }
    
    func updateFinishButton() {
        // Check if all set is complete
        guard let exercises = workout.exercises?.array as? [Exercise] else { return }

        let shouldEnableFinishButton = exercises.allSatisfy { exercise in
            guard let exerciseSets = exercise.exerciseSets?.array as? [ExerciseSet] else { return false }
            return exerciseSets.allSatisfy { validInput(exerciseSet: $0) }
        }

        finishButton.isEnabled = shouldEnableFinishButton
        
        func validInput(exerciseSet: ExerciseSet) -> Bool {
            guard let weight = exerciseSet.weight,
                  let reps = exerciseSet.reps
            else { return false }
            
            return exerciseSet.isComplete && weight.isNumeric && reps.isNumeric
        }
    }
}

extension WorkoutDetailTableViewController: AddItemTableViewCellDelegate {
    func didTapAddButton(_ sender: UITableViewCell) {
        guard let indexPath = tableView.indexPath(for: sender) else { return }
        
        // Add exercise set
        let exercises = workout.exercises?.array as? [Exercise] ?? []
        //        let exerciseSet = ExerciseSet(entity: ExerciseSet.entity(), insertInto: nil)
        let exerciseSet = ExerciseSet(context: context)
        
        exercises[indexPath.section].addToExerciseSets(exerciseSet)
        
        tableView.insertRows(at: [indexPath], with: .automatic)
        
        updateUI()
    }
}

extension WorkoutDetailTableViewController: WorkoutDetailTableViewCellDelegate {
    func workoutDetailTableViewCell(_ cell: WorkoutDetailTableViewCell, didUpdateExerciseSet exerciseSet: ExerciseSet) {
        updateUI()
    }
}

extension String {
    var isNumeric: Bool {
        // Attempt to create an Int or Double from the string
        return Double(self) != nil
    }
}

