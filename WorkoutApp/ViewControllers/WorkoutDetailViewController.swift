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

protocol WorkoutModel {
    var workout: Workout { get }
    var primaryButtonText: String { get }
    func didTapPrimaryButton(_ viewController: UIViewController) -> UIAction
}

class WorkoutDetailViewController: UIViewController {
    
    private let tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .insetGrouped)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        return tableView
    }()
    
//    var workout: Workout
    var timerButton: TimerBarButton?
        
    let context = CoreDataStack.shared.mainContext
//    let childContext: NSManagedObjectContext = CoreDataStack.shared.newBackgroundContext()

    weak var delegate: WorkoutDetailTableViewControllerDelegate?
    weak var progressDelegate: WorkoutDetailTableViewControllerDelegate?
        
    let workoutModel: WorkoutModel
    
    init(workoutModel: WorkoutModel) {
        self.workoutModel = workoutModel
        print(workoutModel.workout.printPrettyString())
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
//    enum State {
//        case createWorkout(String)
//        case updateWorkout(Workout)
//        case startWorkout(Workout)
//        case updateLog(Workout)
//    }

//    init(template: Template) {
//        workout = Workout(context: childContext)
//        workout.title = template.title
//        workout.createdAt = .now
//        
//        for templateExercise in template.templateExercises {
//            let exercise = Exercise(context: childContext)
//            exercise.name = templateExercise.name
//            exercise.workout = workout
//            
//            for i in 0..<templateExercise.sets {
//                let exerciseSet = ExerciseSet(context: childContext)
//                exerciseSet.isComplete = false
//                exerciseSet.reps = ""
//                exerciseSet.weight = ""
//                exerciseSet.index = Int16(i)
//                exerciseSet.exercise = exercise
//                exercise.addToExerciseSets(exerciseSet)
//            }
//            
//            workout.addToExercises(exercise)
//        }
//        
//        super.init(nibName: nil, bundle: nil)
//    }
//    
//    required init?(coder: NSCoder) {
//        fatalError("init(coder:) has not been implemented")
//    }
    
//    init(log: Workout) {
//        super.init(nibName: nil, bundle: nil)
//    }
    
    // TODO: Maybe use protocol instead of switch statements.
//    init(_ state: State) {
//        self.state = state
//        childContext = CoreDataStack.shared.newBackgroundContext()
////        childContext = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.newBackgroundContext()
//
//        switch state {
//        case .createWorkout(let workoutName):
//            workout = Workout(context: childContext)
//            workout.title = workoutName
//            workout.createdAt = nil // templates do not have dates
//        case .updateWorkout(let template):
//            workout = Workout.copy(workout: template, with: childContext)
//            for exercise in workout.getExercises() {
//                for set in exercise.getExerciseSets() {
//                    set.isComplete = false
//                    set.weight = ""
//                    set.reps = ""
//                }
//            }
//        case .startWorkout(let template):
//            workout = Workout.copy(workout: template, with: childContext)
//            workout.createdAt = .now
//            for exercise in workout.getExercises() {
//                for set in exercise.getExerciseSets() {
//                    set.isComplete = false
//                    set.weight = ""
//                    set.reps = ""
//                }
//            }
//        case .updateLog(let log):
//            workout = Workout.copy(workout: log, with: childContext)   // make copy of log, then save new log and delete old log
//        }
//        
//        // Load previous exercise's weights
//        let exercises = workout.getExercises()
//        for exercise in exercises {
//            if let previousExercise = exercise.getPreviousExerciseDone() {
//                previousExercises[exercise.name] = previousExercise.getExerciseSets().map { ($0.weightString, $0.reps) }
//            }
//        }
//                
//        super.init(style: .insetGrouped)
//    }
//    
//    required init?(coder: NSCoder) {
//        fatalError("init(coder:) has not been implemented")
//    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("ViewDidLoad()")
        workoutModel.workout.printPrettyString()
        print(workoutModel.workout.managedObjectContext)
        navigationItem.title = workoutModel.workout.title
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
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: workoutModel.primaryButtonText, primaryAction: workoutModel.didTapPrimaryButton(self))
                
//        let footer = AddExerciseFooterView()
//        footer.frame = CGRect(x: 0, y: 0, width: tableView.frame.width, height: 42)
//        footer.delegate = self
//        tableView.tableFooterView = footer
        
        tableView.register(WorkoutDetailTableViewCell.self, forCellReuseIdentifier: WorkoutDetailTableViewCell.reuseIdentifier)
        tableView.register(AddSetTableViewCell.self, forCellReuseIdentifier: AddSetTableViewCell.reuseIdentifier)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        // Back button pressed
        if self.isMovingFromParent {
            timerButton?.timer.stopTimer()  // timer runs in thread, leaving view doesn't get rid of timer
        }
    }
    
    func didTapFinishButton() -> UIAction {
        return UIAction { _ in
            if self.workoutModel.workout.isFinished {
                self.showFinishAlert(title: "Workout Complete!", message: "Are you ready to finish your workout?")
            } else {
                self.showFinishAlert(title: "Finish Workout?", message: "Some weight or reps fields are still empty. Are you sure you want to finish your workout?")
            }
        }
    }
    
    func showFinishAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.addAction(UIAlertAction(title: "Confirm", style: .default) { _ in
            self.didTapConfirmButton()
        })
        
        
        present(alert, animated: true, completion: nil)
    }
    
    func didTapConfirmButton() {
//        do {
//            try childContext.save()
//        } catch {
//            print("Error saving reordered items: \(error)")
//        }
//        
//        CoreDataStack.shared.saveContext()
//        
//        delegate?.workoutDetailTableViewController(self, didFinishWorkout: workout)
//        progressDelegate?.workoutDetailTableViewController(self, didFinishWorkout: workout)
//        Settings.shared.logBadgeValue += 1
//        NotificationCenter.default.post(name: Settings.logBadgeValueChangedNotification, object: nil)
//        navigationController?.popViewController(animated: true)
    }
    
    func setupBarButton() {
        let addEditButton: UIBarButtonItem
        let buttonTitle: String = "Button Title"
        let alertTitle: String = "Alert Title"
//        switch state {
//        case .createWorkout(_):
//            buttonTitle = "Save"
//            alertTitle = "Create Template?"
//        case .updateWorkout(_):
//            buttonTitle = "Save"
//            alertTitle = "Save Changes?"
//        case .startWorkout(_):
//            buttonTitle = "Finish"
//            alertTitle = "Finish Workout?"
//        case .updateLog(_):
//            buttonTitle = "Save"
//            alertTitle = "Save Changes?"
//        }
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
                    
                    // Isolated Changes: Use child contexts for features like editing forms, where changes can be discarded without affecting the main context if the user cancels.

                    // push changes to parent's context (parent will also need to save() aswell)
//                    try childContext.save()
                    
//                    switch state {
//                    case .createWorkout(_):
//                        delegate?.workoutDetailTableViewController(self, didCreateWorkout: workout)
//                    case .updateWorkout(let template):
//                        // Delete old template
//                        if let templateContext = template.managedObjectContext {
//                            templateContext.delete(template)
//                            try templateContext.save()
//                            delegate?.workoutDetailTableViewController(self, didUpdateWorkout: workout)
//                        }
//                    case .startWorkout(_):
//                        delegate?.workoutDetailTableViewController(self, didFinishWorkout: workout)
//                        progressDelegate?.workoutDetailTableViewController(self, didFinishWorkout: workout)
//                        Settings.shared.logBadgeValue += 1
//                        NotificationCenter.default.post(name: Settings.logBadgeValueChangedNotification, object: nil)
//                    case .updateLog(let log):
//                        // Delete old log
//                        if let logContext = log.managedObjectContext {
//                            logContext.delete(log)
//                            try logContext.save()
//                        }
//                        delegate?.workoutDetailTableViewController(self, didUpdateLog: workout)
//                        progressDelegate?.workoutDetailTableViewController(self, didUpdateLog: workout)
//                    }

                    navigationController?.popViewController(animated: true)
                } catch {
                    print("Failed to save workout: \(error)")
                }
            }))
            
            self.present(alert, animated: true, completion: nil)
        }
        
        addEditButton = UIBarButtonItem(title: buttonTitle, primaryAction: action)
//        switch state {
//        case .updateLog(_):
//            let calendarAction = UIAction { [self] _ in
//                let calendarViewController = CalendarViewController(workout: workout)
//                let navigationController = UINavigationController(rootViewController: calendarViewController)
//                if let sheet = navigationController.sheetPresentationController {
//                    sheet.detents = [.custom(resolver: { context in
//                        return self.view.frame.height * 0.6
//                    })]
//                }
//                self.present(navigationController, animated: true)
//            }
//            let calendarButton = UIBarButtonItem(image: UIImage(systemName: "calendar"), primaryAction: calendarAction)
//            navigationItem.rightBarButtonItems = [addEditButton, calendarButton]
//        case .updateWorkout(_):
//            let renameAction = UIAction { [self] _ in
//                let alert = UIAlertController(title: "Rename Template", message: "Enter new name below", preferredStyle: .alert)
//                
//                alert.addTextField { textField in
//                    textField.placeholder = "Ex. Push Day"
//                    textField.autocapitalizationType = .sentences
//                    let textChangedAction = UIAction { _ in
//                        alert.actions[1].isEnabled = textField.text!.count > 0
//                    }
//                    textField.addAction(textChangedAction, for: .allEditingEvents)
//                }
//                
//                alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
//                alert.addAction(UIAlertAction(title: "Done", style: .default, handler: { _ in
//                    guard let templateName = alert.textFields?[0].text else { return }
//                    print(templateName)
//                    self.workout.title = templateName
//                    self.navigationItem.title = "\(templateName) [Template]"
//                }))
//                
//                self.present(alert, animated: true, completion: nil)
//            }
//            let renameButton = UIBarButtonItem(image: UIImage(systemName: "rectangle.and.pencil.and.ellipsis"), primaryAction: renameAction)
//            navigationItem.rightBarButtonItems = [addEditButton, renameButton]
//        case .startWorkout(_):
//            // Timer
//            navigationItem.rightBarButtonItems = [addEditButton]
//            if Settings.shared.showTimer {
//                timerButton = TimerBarButton()
//                navigationItem.rightBarButtonItems?.append(timerButton!)
//            }
//        default:
//            navigationItem.rightBarButtonItem = addEditButton
//        }
    }
    
}

extension WorkoutDetailViewController: AddSetTableViewCellDelegate {
    func didTapAddSetButton(_ sender: AddSetTableViewCell) {
//        guard let indexPath = tableView.indexPath(for: sender) else { return }
//        
//        let exercise = workoutModel.workout.getExercise(at: indexPath.section)
//        let set = ExerciseSet(context: childContext)
//        set.isComplete = false
//        set.weight = ""
//        set.reps = ""
//        set.exercise = exercise
//        exercise.addToExerciseSets(set)
//        
//        tableView.insertRows(at: [indexPath], with: .automatic)
    }
}

extension WorkoutDetailViewController: WorkoutDetailTableViewCellDelegate {
    func workoutDetailTableViewCell(_ cell: WorkoutDetailTableViewCell, nextButtonTapped: Bool) {
//        if cell.weightTextField.isFirstResponder {
//            cell.repsTextField.becomeFirstResponder()
//        }
//        else if cell.repsTextField.isFirstResponder {
//            guard let indexPath = tableView.indexPath(for: cell) else { return }
//            // Toggle checkmark
//            if !cell.set.isComplete {
//                cell.set.isComplete = true
//                // If textfield is empty, use placeholder value
//                if cell.weightTextField.text == "" {
//                    cell.set.weight = cell.weightTextField.placeholder ?? "0"
//                    cell.weightTextField.text = cell.weightTextField.placeholder
//                }
//                if cell.repsTextField.text == "" {
//                    cell.set.reps = cell.repsTextField.placeholder ?? "0"
//                    cell.repsTextField.text = cell.repsTextField.placeholder
//                }
//                if Settings.shared.enableHaptic {
//                    let generator = UIImpactFeedbackGenerator(style: .heavy)
//                    generator.impactOccurred()
//                }
//                tableView.reloadRows(at: [indexPath], with: .automatic)
////                tableView.reloadSections(IndexSet(integer: indexPath.section), with: .automatic)
//            }
//            // If last textfield, do nothing
//            let exercisesCount = workout.getExercises().count
//            if indexPath.section == exercisesCount - 1 &&
//                indexPath.row == workout.getExercise(at: exercisesCount - 1).getExerciseSets().count - 1 {
//                return
//            }
//            // Go to next row
//            let nextIndexPath: IndexPath
//            if indexPath.row < workout.getExercise(at: indexPath.section).getExerciseSets().count - 1 {
//                nextIndexPath = IndexPath(row: indexPath.row + 1, section: indexPath.section)
//            } else {
//                // Go to next section
//                nextIndexPath = IndexPath(row: 0, section: indexPath.section + 1)
//            }
//            let nextCell = tableView.cellForRow(at: nextIndexPath) as! WorkoutDetailTableViewCell
//            nextCell.weightTextField.becomeFirstResponder()
//        }
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
                    row: workoutModel.workout.getExercise(at: indexPath.section - 1).getExerciseSets().count - 1,
                    section: indexPath.section - 1)
            }
            let previousCell = tableView.cellForRow(at: previousIndexPath) as! WorkoutDetailTableViewCell
            previousCell.repsTextField.becomeFirstResponder()
        }
    }
    
    func workoutDetailTableViewCell(_ cell: WorkoutDetailTableViewCell, didUpdateExerciseSet exerciseSet: ExerciseSet) {
//        updateUI()
    }
    
    func workoutDetailTableViewCell(_ cell: WorkoutDetailTableViewCell, didTapCheckmarkForSet exerciseSet: ExerciseSet) {
        guard let indexPath = tableView.indexPath(for: cell) else { return }
        tableView.reloadSections(IndexSet(integer: indexPath.section), with: .automatic)
//        updateUI()
    }
    
    func workoutDetailTableViewCell(_ cell: WorkoutDetailTableViewCell, didTapSetButton: Bool) {
        guard let indexPath = tableView.indexPath(for: cell) else { return }
        let exerciseSet = workoutModel.workout.getExercise(at: indexPath.section).getExerciseSet(at: indexPath.row)
        exerciseSet.isComplete = cell.setButton.isSelected
        
        if cell.weightTextField.text == "" {
            let weight = Float(cell.weightTextField.placeholder ?? "0") ?? 0.0
            exerciseSet.weight = String(format: "%g", weight)
        }
        if cell.repsTextField.text == "" {
            let reps = Int(cell.repsTextField.placeholder ?? "0") ?? 0
            exerciseSet.reps = String(reps)
        }
        if Settings.shared.enableHaptic {
            let generator = UIImpactFeedbackGenerator(style: .heavy)
            generator.impactOccurred()
        }
        
        var indexPaths: [IndexPath] = []
        for row in 0..<workoutModel.workout.getExercise(at: indexPath.section).getExerciseSets().count {
            indexPaths.append(IndexPath(row: row, section: indexPath.section))
        }
        
        tableView.reloadRows(at: indexPaths, with: .none)
        
        workoutModel.workout.printPrettyString()
    }
    
    func workoutDetailTableViewCell(_ cell: WorkoutDetailTableViewCell, weightTextDidChange weightText: String) {
        guard let indexPath = tableView.indexPath(for: cell) else { return }
        let exerciseSet = workoutModel.workout.getExercise(at: indexPath.section).getExerciseSet(at: indexPath.row)
        
        exerciseSet.weight = weightText
        exerciseSet.isComplete = !exerciseSet.weight.isEmpty || !exerciseSet.reps.isEmpty

        
//        var indexPaths: [IndexPath] = []
//        for row in 0..<workout.getExercise(at: indexPath.section).getExerciseSets().count {
//            indexPaths.append(IndexPath(row: row, section: indexPath.section))
//        }
//        tableView.reloadRows(at: indexPaths, with: .none)
//        
//        cell.weightTextField.becomeFirstResponder() // reloading row dismisses keyboard
    }
    
    func workoutDetailTableViewCell(_ cell: WorkoutDetailTableViewCell, repsTextDidChange repsText: String) {
        guard let indexPath = tableView.indexPath(for: cell) else { return }
        let exerciseSet = workoutModel.workout.getExercise(at: indexPath.section).getExerciseSet(at: indexPath.row)
        
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
        let exercise = workoutModel.workout.getExercise(at: section)
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

extension Collection {
    /// Returns the element at the specified index if it is within bounds, otherwise nil.
    subscript (safe index: Index) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }
}

extension WorkoutDetailViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return workoutModel.workout.getExercises().count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return workoutModel.workout.getExercise(at: section).getExerciseSets().count + 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let exercise = workoutModel.workout.getExercise(at: indexPath.section)
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
        let exercises = workoutModel.workout.getExercises()
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
        let exercise = workoutModel.workout.getExercise(at: indexPath.section)
        let exerciseSets = exercise.getExerciseSets()
        return indexPath.row != exerciseSets.count
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        let exercises = workoutModel.workout.getExercises()
        
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
