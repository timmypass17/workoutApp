//
//  WorkoutDetailTableViewController.swift
//  WorkoutApp
//
//  Created by Timmy Nguyen on 1/11/24.
//

import UIKit
import CoreData

// Split this delegate up, some classes don't implment some functionss
protocol WorkoutDetailTableViewControllerDelegate: AnyObject {
    func workoutDetailTableViewController(_ viewController: WorkoutDetailTableViewController, didCreateWorkout workout: Workout)
    func workoutDetailTableViewController(_ viewController: WorkoutDetailTableViewController, didUpdateWorkout workout: Workout)
    func workoutDetailTableViewController(_ viewController: WorkoutDetailTableViewController, didFinishWorkout workout: Workout)
    func workoutDetailTableViewController(_ viewController: WorkoutDetailTableViewController, didUpdateLog workout: Workout)
}

// TODO: Bug with deleting log, deletes all exercise and sets
// 1. Finish Workout A
// 2. Delete Workout A's logged bench press
// 3. Workout A's bench press is empty and previous is empty
// Solution: Problably something with deletion rule
// Child context: Child contexts are useful when you want to make changes in a separate context and then either save those changes or discard them without affecting the main context.
class WorkoutDetailTableViewController: UITableViewController {
    let workout: Workout
    let state: State
    var previousExercises: [String: [(String, String)]] = [:]
    var timerButton: TimerBarButton?
        
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    let childContext: NSManagedObjectContext
    
    weak var delegate: WorkoutDetailTableViewControllerDelegate?
    weak var progressDelegate: WorkoutDetailTableViewControllerDelegate?
    
    enum State {
        case createWorkout(String)
        case updateWorkout(Workout)
        case startWorkout(Workout)
        case updateLog(Workout)
    }
    
    // TODO: Maybe use protocol instead of switch statements.
    init(_ state: State) {
        self.state = state
        childContext = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.newBackgroundContext()

        switch state {
        case .createWorkout(let workoutName):
            workout = Workout(context: childContext)
            workout.title = workoutName
            workout.createdAt = nil // templates do not have dates
        case .updateWorkout(let template):
            workout = Workout.copy(workout: template, with: childContext)
            for exercise in workout.getExercises() {
                for set in exercise.getExerciseSets() {
                    set.isComplete = false
                    set.weight = ""
                    set.reps = ""
                }
            }
        case .startWorkout(let template):
            workout = Workout.copy(workout: template, with: childContext)
            workout.createdAt = .now
            for exercise in workout.getExercises() {
                for set in exercise.getExerciseSets() {
                    set.isComplete = false
                    set.weight = ""
                    set.reps = ""
                }
            }
        case .updateLog(let log):
            workout = Workout.copy(workout: log, with: childContext)   // make copy of log, then save new log and delete old log
        }
        
        // Load previous exercise's weights
        let exercises = workout.getExercises()
        for exercise in exercises {
            if let previousExercise = exercise.getPreviousExerciseDone() {
                previousExercises[exercise.title] = previousExercise.getExerciseSets().map { ($0.weightString, $0.reps) }
            }
        }
                
        super.init(style: .insetGrouped)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(tableView!,
                                               selector: #selector(UITableView.reloadData),
                                               name: AccentColor.valueChangedNotification,
                                               object: nil)
        
        navigationItem.title = workout.title
        if case .updateWorkout(_) = state {
            navigationItem.title = "\(workout.title) [Template]"
        }

        navigationController?.navigationBar.prefersLargeTitles = true
        
        setupBarButton()
        if Settings.shared.showAddExercise {
            let footer = AddExerciseFooterView()
            footer.frame = CGRect(x: 0, y: 0, width: tableView.frame.width, height: 42)
            footer.delegate = self
            tableView.tableFooterView = footer
        } else if case .createWorkout = state {
            // can't really combine if case with OR :/
            let footer = AddExerciseFooterView()
            footer.frame = CGRect(x: 0, y: 0, width: tableView.frame.width, height: 42)
            footer.delegate = self
            tableView.tableFooterView = footer
        } else if case .updateWorkout(_) = state {
            let footer = AddExerciseFooterView()
            footer.frame = CGRect(x: 0, y: 0, width: tableView.frame.width, height: 42)
            footer.delegate = self
            tableView.tableFooterView = footer
        }
        
        tableView.register(WorkoutDetailTableViewCell.self, forCellReuseIdentifier: WorkoutDetailTableViewCell.reuseIdentifier)
        tableView.register(AddItemTableViewCell.self, forCellReuseIdentifier: AddItemTableViewCell.reuseIdentifier)
        
        updateUI()
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let exercises = workout.getExercises()
        let header = ExerciseHeaderView(title: exercises[section].title, section: section)
        header.delegate = self
        if case .updateWorkout(_) = state {
            header.editButton.isHidden = false
        } else {
            header.editButton.isHidden = true
        }
        return header
    }

    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return workout.getExercises().count
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return workout.getExercise(at: section).getExerciseSets().count + 1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let exercise = workout.getExercise(at: indexPath.section)
        let sets = exercise.getExerciseSets()
        
        if indexPath.row == sets.count {
            let cell = tableView.dequeueReusableCell(withIdentifier: AddItemTableViewCell.reuseIdentifier, for: indexPath) as! AddItemTableViewCell
            cell.update(title: "Add Set")
            cell.delegate = self
            cell.selectionStyle = .none
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: WorkoutDetailTableViewCell.reuseIdentifier, for: indexPath) as! WorkoutDetailTableViewCell
            cell.delegate = self
            let previousWeights = previousExercises[exercise.title, default: []]
            cell.update(with: workout, for: indexPath, previousWeights: previousWeights)
            return cell
        }
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        let exercise = workout.getExercise(at: indexPath.section)
        let exerciseSets = exercise.getExerciseSets()
        return indexPath.row != exerciseSets.count
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        let exercises = workout.getExercises()
        
        if (editingStyle == .delete) {
            exercises[indexPath.section].removeFromExerciseSets(at: indexPath.row)
            tableView.beginUpdates()
            tableView.deleteRows(at: [indexPath], with: .automatic)
            
            if exercises[indexPath.section].getExerciseSets().count == 0 {
                workout.removeFromExercises(exercises[indexPath.section])   // if set is empty, then remove exercise from workout
                tableView.deleteSections(IndexSet(integer: indexPath.section), with: .automatic)
            } else {
                tableView.reloadSections(IndexSet(integer: indexPath.section), with: .automatic)
            }
            tableView.endUpdates()
            updateUI()
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        // Back button pressed
        if self.isMovingFromParent {
            timerButton?.timer.stopTimer()  // timer runs in thread, leaving view doesn't get rid of timer
        }
    }
    
    func updateUI() {
        updateFinishButton()
    }
    
    func updateFinishButton() {
        // Check if all set is complete
        let exercises = workout.getExercises()
        guard !exercises.isEmpty else {
            navigationItem.rightBarButtonItem?.isEnabled = false
            return
        }
        
        let shouldEnableFinishButton = exercises.allSatisfy { exercise in
            let exerciseSets = exercise.getExerciseSets()
            return exerciseSets.allSatisfy { validInput(exerciseSet: $0) }
        }
        
        navigationItem.rightBarButtonItem?.isEnabled = shouldEnableFinishButton
        
        func validInput(exerciseSet: ExerciseSet) -> Bool {
            let weight = exerciseSet.weight
            return exerciseSet.isComplete && weight.isNumeric && exerciseSet.reps.isNumeric
        }
    }
    
    func setupBarButton() {
        let addEditButton: UIBarButtonItem
        let buttonTitle: String
        let alertTitle: String
        switch state {
        case .createWorkout(_):
            buttonTitle = "Save"
            alertTitle = "Create Workout?"
        case .updateWorkout(_):
            buttonTitle = "Save"
            alertTitle = "Save Template?"
        case .startWorkout(_):
            buttonTitle = "Finish"
            alertTitle = "Finish Workout?"
        case .updateLog(_):
            buttonTitle = "Save"
            alertTitle = "Save Changes?"
        }
        let action = UIAction { [self] _ in
            timerButton?.timer.stopTimer()
            var message = ""
            if let elapsedTime = timerButton?.timer.elapsedTime {
                let formatter = DateComponentsFormatter()
                formatter.unitsStyle = .abbreviated
                formatter.allowedUnits = [.hour, .minute, .second]
                let timeString = formatter.string(from: elapsedTime)!
                message =  "Your workout today at \(Date().formatted(date: .abbreviated, time: .omitted)) lasted \(timeString)"
            }
            
            let alert = UIAlertController(title: alertTitle, message: message, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel) { _ in
                self.timerButton?.timer.startTimer()
            })
            
            alert.addAction(UIAlertAction(title: "Done", style: .default, handler: { [self] _ in
                do {
                    
                    try childContext.save()
                    
                    switch state {
                    case .createWorkout(_):
                        delegate?.workoutDetailTableViewController(self, didCreateWorkout: workout)
                    case .updateWorkout(let template):
                        // Delete old template
                        if let templateContext = template.managedObjectContext {
                            templateContext.delete(template)
                            try templateContext.save()
                            delegate?.workoutDetailTableViewController(self, didUpdateWorkout: workout)
                        }
                    case .startWorkout(_):
                        delegate?.workoutDetailTableViewController(self, didFinishWorkout: workout)
                        progressDelegate?.workoutDetailTableViewController(self, didFinishWorkout: workout)
                        Settings.shared.logBadgeValue += 1
                        NotificationCenter.default.post(name: Settings.logBadgeValueChangedNotification, object: nil)
                    case .updateLog(let log):
                        // Delete old log
                        if let logContext = log.managedObjectContext {
                            logContext.delete(log)
                            try logContext.save()
                        }
                        delegate?.workoutDetailTableViewController(self, didUpdateLog: workout)
                        progressDelegate?.workoutDetailTableViewController(self, didUpdateLog: workout)
                    }

                    navigationController?.popViewController(animated: true)
                } catch {
                    print("Failed to save workout: \(error)")
                }
            }))
            
            self.present(alert, animated: true, completion: nil)
        }
        
        addEditButton = UIBarButtonItem(title: buttonTitle, primaryAction: action)
        switch state {
        case .updateLog(_):
            let calendarAction = UIAction { [self] _ in
                let calendarViewController = CalendarViewController(workout: workout)
                let navigationController = UINavigationController(rootViewController: calendarViewController)
                if let sheet = navigationController.sheetPresentationController {
                    sheet.detents = [.custom(resolver: { context in
                        return self.view.frame.height * 0.6
                    })]
                }
                self.present(navigationController, animated: true)
            }
            let calendarButton = UIBarButtonItem(image: UIImage(systemName: "calendar"), primaryAction: calendarAction)
            navigationItem.rightBarButtonItems = [addEditButton, calendarButton]
        case .startWorkout(_):
            // Timer
            navigationItem.rightBarButtonItems = [addEditButton]
            if Settings.shared.showTimer {
                timerButton = TimerBarButton()
                navigationItem.rightBarButtonItems?.append(timerButton!)
            }

        default:
            navigationItem.rightBarButtonItem = addEditButton
        }
    }
    
}

extension WorkoutDetailTableViewController: AddItemTableViewCellDelegate {
    func didTapAddButton(_ sender: UITableViewCell) {
        guard let indexPath = tableView.indexPath(for: sender) else { return }
        
        // Add set
        let exercise = workout.getExercise(at: indexPath.section)
        let set = ExerciseSet(context: childContext)
        set.isComplete = false
        set.weight = ""
        set.reps = ""
        set.exercise = exercise
        exercise.addToExerciseSets(set)
        
        tableView.insertRows(at: [indexPath], with: .automatic)
        
        updateUI()
    }
}

extension WorkoutDetailTableViewController: WorkoutDetailTableViewCellDelegate {
    func workoutDetailTableViewCell(_ cell: WorkoutDetailTableViewCell, nextButtonTapped: Bool) {
        if cell.weightTextField.isFirstResponder {
            cell.repsTextField.becomeFirstResponder()
        }
        else if cell.repsTextField.isFirstResponder {
            guard let indexPath = tableView.indexPath(for: cell) else { return }
            // Toggle checkmark
            if !cell.set.isComplete {
                cell.set.isComplete = true
                // If textfield is empty, use placeholder value
                if cell.weightTextField.text == "" {
                    cell.set.weight = cell.weightTextField.placeholder ?? "0"
                    cell.weightTextField.text = cell.weightTextField.placeholder
                }
                if cell.repsTextField.text == "" {
                    cell.set.reps = cell.repsTextField.placeholder ?? "0"
                    cell.repsTextField.text = cell.repsTextField.placeholder
                }
                if Settings.shared.enableHaptic {
                    let generator = UIImpactFeedbackGenerator(style: .heavy)
                    generator.impactOccurred()
                }
                tableView.reloadSections(IndexSet(integer: indexPath.section), with: .automatic)
                updateUI()
            }
            // If last textfield, do nothing
            let exercisesCount = workout.getExercises().count
            if indexPath.section == exercisesCount - 1 &&
                indexPath.row == workout.getExercise(at: exercisesCount - 1).getExerciseSets().count - 1 {
                return
            }
            // Go to next row
            let nextIndexPath: IndexPath
            if indexPath.row < workout.getExercise(at: indexPath.section).getExerciseSets().count - 1 {
                nextIndexPath = IndexPath(row: indexPath.row + 1, section: indexPath.section)
            } else {
                // Go to next section
                nextIndexPath = IndexPath(row: 0, section: indexPath.section + 1)
            }
            let nextCell = tableView.cellForRow(at: nextIndexPath) as! WorkoutDetailTableViewCell
            nextCell.weightTextField.becomeFirstResponder()
        }
    }
    
    func workoutDetailTableViewCell(_ cell: WorkoutDetailTableViewCell, previousButtonTapped: Bool) {
        if cell.repsTextField.isFirstResponder {
            cell.weightTextField.becomeFirstResponder()
        }
        else if cell.weightTextField.isFirstResponder {
            guard let indexPath = tableView.indexPath(for: cell) else { return }
            // If first textfield, do nothing
            if indexPath == IndexPath(row: 0, section: 0) {
                return
            }
            // Go to previous row
            let previousIndexPath: IndexPath
            if indexPath.row > 0 {
                previousIndexPath = IndexPath(row: indexPath.row - 1, section: indexPath.section)
            } else {
                // Go to previous section
                previousIndexPath = IndexPath(
                    row: workout.getExercise(at: indexPath.section - 1).getExerciseSets().count - 1,
                    section: indexPath.section - 1)
            }
            let previousCell = tableView.cellForRow(at: previousIndexPath) as! WorkoutDetailTableViewCell
            previousCell.repsTextField.becomeFirstResponder()
        }
    }
    
    func workoutDetailTableViewCell(_ cell: WorkoutDetailTableViewCell, didUpdateExerciseSet exerciseSet: ExerciseSet) {
        updateUI()
    }
    
    func workoutDetailTableViewCell(_ cell: WorkoutDetailTableViewCell, didTapCheckmarkForSet exerciseSet: ExerciseSet) {
        guard let indexPath = tableView.indexPath(for: cell) else { return }
        tableView.reloadSections(IndexSet(integer: indexPath.section), with: .automatic)
        updateUI()
    }
    
}

extension WorkoutDetailTableViewController: AddExerciseFooterViewDelegate {
    func didTapAddExerciseButton(_ sender: UIButton) {
        let exercisesTableViewController = ExercisesTableViewController()
        exercisesTableViewController.delegate = self
        self.present(UINavigationController(rootViewController: exercisesTableViewController), animated: true, completion: nil)
    }
}

extension WorkoutDetailTableViewController: ExercisesTableViewControllerDelegate {
    func exercisesTableViewController(_ viewController: ExercisesTableViewController, didSelectExercises exercises: [String]) {
        // Loop through exercises
        for exerciseName in exercises {
            let section = workout.getExercises().count
            // Create exercise item
            let exercise = Exercise(context: childContext)
            exercise.title = exerciseName
            exercise.workout = workout  // need to set parent aswell, workout.addToExercises(exercise) does not do this.
            workout.addToExercises(exercise)
            // Create a single exerciseSet item
            let set = ExerciseSet(context: childContext)
            set.isComplete = false
            set.weight = ""
            set.reps = ""
            set.exercise = exercise
            exercise.addToExerciseSets(set)
            
            // Add previous exercise
            if let previousExercise = exercise.getPreviousExerciseDone() {
                previousExercises[exercise.title] = previousExercise.getExerciseSets().map { ($0.weightString, $0.reps) }
            }
            // Add section (this also insert's row)
            tableView.insertSections(IndexSet(integer: section), with: .automatic)
        }
    }
}

extension WorkoutDetailTableViewController: ExerciseHeaderViewDelegate {
    func exerciseHeaderView(_ sender: ExerciseHeaderView, didRenameExercise name: String, viewForHeaderInSection section: Int) {
        let exercise = workout.getExercise(at: section)
        exercise.title = name
        tableView.reloadSections(IndexSet(integer: section), with: .automatic)
    }
}

extension String {
    var isNumeric: Bool {
        // Attempt to create an Int or Double from the string
        return Double(self) != nil
    }
}

extension Collection {
    /// Returns the element at the specified index if it is within bounds, otherwise nil.
    subscript (safe index: Index) -> Element? {
        return indices.contains(index) ? self[index] : nil
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
