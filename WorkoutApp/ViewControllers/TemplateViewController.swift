//
//  CreateWorkoutViewController.swift
//  BuiltDiff
//
//  Created by Timmy Nguyen on 12/27/24.
//

import UIKit
import CoreData

//protocol CreateWorkoutViewControllerDelegate: AnyObject {
//    func createWorkoutViewController(_ viewController: TemplateViewController, didCreateWorkoutTemplate template: Template)
//}

class TemplateViewController: UIViewController {
    
    private let tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .insetGrouped)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        return tableView
    }()
    
    var template: Template
    let childContext: NSManagedObjectContext
    let workoutService: WorkoutService

    init(template: Template, childContext: NSManagedObjectContext, workoutService: WorkoutService) {
        self.template = template
        self.childContext = childContext
        self.workoutService = workoutService
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    enum Section: Int, CaseIterable {
        case title, exercises
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(TemplateTitleTableViewCell.self, forCellReuseIdentifier: TemplateTitleTableViewCell.reuseIdentifier)
        tableView.register(TemplateExerciseTableViewCell.self, forCellReuseIdentifier: TemplateExerciseTableViewCell.reuseIdentifier)
        tableView.register(AddTemplateExerciseTableViewCell.self, forCellReuseIdentifier: AddTemplateExerciseTableViewCell.reuseIdentifier)
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(systemItem: .cancel, primaryAction: didTapCancelButton())
        navigationItem.rightBarButtonItems = [editButtonItem]

        view.addSubview(tableView)

        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
    }
    
    override func setEditing(_ editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)
        tableView.setEditing(editing, animated: animated)
    }
    
    func updateSaveButton() {
        navigationItem.rightBarButtonItems?[0].isEnabled = !template.title.isEmpty
    }
    
    func didTapCancelButton() -> UIAction {
        return UIAction { _ in
            self.dismiss(animated: true)
        }
    }
}

extension TemplateViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return Section.allCases.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let section = Section(rawValue: section) else { return 0 }
        switch section {
        case .title:
            return 1
        case .exercises:
            let button = 1
            return template.templateExercises.count + button
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let section = Section(rawValue: indexPath.section) else { return UITableViewCell() }
        switch section {
        case .title:
            let cell = tableView.dequeueReusableCell(withIdentifier: TemplateTitleTableViewCell.reuseIdentifier, for: indexPath) as! TemplateTitleTableViewCell
            cell.delegate = self
            cell.update(title: template.title)
            return cell
        case .exercises:
            let isAddButtonRow = indexPath.row == template.templateExercises.count
            if isAddButtonRow {
                let cell = tableView.dequeueReusableCell(withIdentifier: AddTemplateExerciseTableViewCell.reuseIdentifier, for: indexPath) as! AddTemplateExerciseTableViewCell
                return cell
            }
            
            let cell = tableView.dequeueReusableCell(withIdentifier: TemplateExerciseTableViewCell.reuseIdentifier, for: indexPath) as! TemplateExerciseTableViewCell
            let templateExercise = template.templateExercises[indexPath.row]
            cell.accessoryType = .disclosureIndicator
            cell.update(templateExercise: templateExercise)
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        guard let section = Section(rawValue: section) else { return nil }
        switch section {
        case .title:
            return "Title"
        case .exercises:
            return "Exercises"
        }
    }
}

extension TemplateViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let isAddButtonRow = indexPath.row == template.templateExercises.count
        guard let section = Section(rawValue: indexPath.section),
              section == .exercises
        else { return }
        
        if isAddButtonRow {
            tableView.deselectRow(at: indexPath, animated: true)
            let exercisesTableViewController = ExercisesTableViewController(workoutService: workoutService)
            exercisesTableViewController.delegate = self
            let vc = UINavigationController(rootViewController: exercisesTableViewController)
            self.present(vc, animated: true)
        } else {
            let exercise = template.templateExercises[indexPath.row]
            let exerciseDetailViewController = EditExerciseDetailViewController(exercise: exercise.name, sets: Int(exercise.sets), reps: Int(exercise.reps))
            exerciseDetailViewController.delegate = self
            let vc = UINavigationController(rootViewController: exerciseDetailViewController)
            if let sheet = vc.sheetPresentationController {
                sheet.detents = [.medium()]
            }
            present(vc, animated: true)
        }
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        let isAddButtonRow = indexPath.row == template.templateExercises.count
        guard let section = Section(rawValue: indexPath.section) else { return false }
        
        return section == .exercises && !isAddButtonRow
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let exerciseToRemove = template.templateExercises[indexPath.row]
            template.removeFromTemplateExercises_(exerciseToRemove) // note: Does not delete exercise, still persisted
            childContext.delete(exerciseToRemove)                   // Exercise is marked for deletion
            
            do {
                try childContext.save() // Exercise is now deleted
            } catch {
                print("Error saving reordered items: \(error)")
            }
            
            tableView.deleteRows(at: [indexPath], with: .automatic)
        }
    }
    
    // Holy fuck, have to use set cause cloudkit doesn't have any "ordering" so everything is stored as an unordered
    // set but with an "index" field so i have to make sure items are still in sorted order after modifying them
    // TODO: Make sure everything works properly, still bug when deleting log sometimes? Try using cloudkit
    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        guard destinationIndexPath.section != 0 else { return }
        
        // TODO: Cloudkit
        let exerciseToMove = template.templateExercises[sourceIndexPath.row]
        // [A, B, C, D, E] B -> D
        // [A, B, C, _, D, E] move everything after destin to right
        // [A, _, C, B, D, E]   move B to destination
        // [A, C, B, D, E]      reorganize
        
        // move forward
        if sourceIndexPath.row < destinationIndexPath.row {
            print("Original")
            template.templateExercises.forEach { print($0.name, $0.index)}
            print()
            print("Shift to right")
            for i in (destinationIndexPath.row + 1..<template.templateExercises.count).reversed() {
                print(i)
                template.templateExercises[i].index = Int16(i + 1)
            }
            print()
            exerciseToMove.index = Int16(destinationIndexPath.row + 1)
            print("After Insert-")
            template.templateExercises.forEach { print($0.name, $0.index)}
        } else {
            //  B <- D
            // [A, B, C, D, E]
            // [A, _, B, C, D, E] move everything after source to right
            // [A, D, B, C, _, E] update D's index to destination
            // [A, D, B, C, E] reforganize
            
            
            print("Original")
            template.templateExercises.forEach { print($0.name, $0.index)}
            print()
            print("Shift to right")
            for i in (destinationIndexPath.row..<template.templateExercises.count).reversed() {
                print(i)
                template.templateExercises[i].index = Int16(i + 1)
            }
            print()
            print("After shift")
            template.templateExercises.forEach { print($0.name, $0.index)}
            print()
            exerciseToMove.index = Int16(destinationIndexPath.row)
            print("After Insert-")
            template.templateExercises.forEach { print($0.name, $0.index)}
        }
        
        print()
        for (index, exercise) in template.templateExercises.enumerated() {
            exercise.index = Int16(index)
        }
        print("Reorganize")
        print()
        
        template.templateExercises.forEach { print($0.name, $0.index)}

        
        // Save the context
        do {
            try childContext.save()
        } catch {
            print("Error saving reordered items: \(error)")
        }
        
        tableView.reloadData()
    }
    
    func tableView(_ tableView: UITableView, targetIndexPathForMoveFromRowAt sourceIndexPath: IndexPath, toProposedIndexPath proposedDestinationIndexPath: IndexPath) -> IndexPath {
        // Restricts cell's reorder destination (i.e. repositioning exercise under "Add Exercise" button)
        let isAddExerciseButtonRow = template.templateExercises.count
        guard let destinationSection = Section(rawValue: proposedDestinationIndexPath.section),
              destinationSection == .exercises,
              proposedDestinationIndexPath.row != isAddExerciseButtonRow
        else { return sourceIndexPath }
        
        return proposedDestinationIndexPath
    }
}


extension TemplateViewController: AddExerciseDetailViewControllerDelegate {
    func addExerciseDetailViewControllerDelegate(_ viewController: AddExerciseDetailViewController, didAddExercise exercise: String, sets: Int, reps: Int) {
        let sampleExercise = TemplateExercise(context: childContext)
        sampleExercise.name = exercise
        sampleExercise.sets = Int16(sets)
        sampleExercise.reps = Int16(reps)
        sampleExercise.index = Int16(template.templateExercises.count)
        sampleExercise.template = template
        template.addToTemplateExercises_(sampleExercise)
        
        tableView.insertRows(at: [IndexPath(row: template.templateExercises.count - 1, section: Section.exercises.rawValue)], with: .automatic)
    }
    
    func addExerciseDetailViewControllerDelegate(_ viewController: AddExerciseDetailViewController, didDismiss: Bool) {
        guard let selectedIndexPath = tableView.indexPathForSelectedRow else { return }
        tableView.deselectRow(at: selectedIndexPath, animated: true)
    }

}

extension TemplateViewController: EditExerciseDetailViewControllerDelegate {
    func editExerciseDetailViewControllerDelegate(_ viewController: EditExerciseDetailViewController, didUpdateExercise exercise: String, sets: Int, reps: Int) {
        guard let selectedIndexPath = tableView.indexPathForSelectedRow else { return }
        let exercise = template.templateExercises[selectedIndexPath.row]
        exercise.sets = Int16(sets)
        exercise.reps = Int16(reps)
        
        tableView.reloadRows(at: [selectedIndexPath], with: .automatic)
        print("Updated \(exercise) \(sets) x \(reps)")
    }
    
    func editExerciseDetailViewControllerDelegate(_ viewController: EditExerciseDetailViewController, didDismiss: Bool) {
        guard let selectedIndexPath = tableView.indexPathForSelectedRow else { return }
        tableView.deselectRow(at: selectedIndexPath, animated: true)
    }
}

extension TemplateViewController: TemplateTitleTableViewCellDelegate {
    func templateTitleTableViewCell(_ cell: TemplateTitleTableViewCell, titleTextFieldDidChange title: String) {
        template.title = title
        updateSaveButton()
    }
}
