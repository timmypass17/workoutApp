//
//  WorkoutViewController.swift
//  BuiltDiff
//
//  Created by Timmy Nguyen on 12/25/24.
//

import UIKit

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
        configuration.image = UIImage(systemName: "dumbbell") // figure.strengthtraining.traditional

        let view = UIContentUnavailableView(configuration: configuration)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.isHidden = true
        return view
    }()
    
    private var addButton: UIBarButtonItem!
    
//    private var workoutPlans: [Workout] = []
    private let context = CoreDataStack.shared.mainContext
    private let workoutService: WorkoutService
    
    private var templates: [Template] = []
    
    init(workoutService: WorkoutService) {
        self.workoutService = workoutService
//        workoutPlans = workoutService.fetchWorkoutPlans()
        templates = workoutService.fetchTemplates()
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
        
        updateUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if let selectedIndexPath = tableView.indexPathForSelectedRow {
            tableView.deselectRow(at: selectedIndexPath, animated: true)
        }
    }
    
    func updateUI() {
        contentUnavailableView.isHidden = !templates.isEmpty
        tableView.reloadData()
    }
    
    private func didTapAddButton() -> UIAction {
        return UIAction { _ in
            let createWorkoutViewController = CreateWorkoutViewController()
            createWorkoutViewController.delegate = self
            let vc = UINavigationController(rootViewController: createWorkoutViewController)
            self.present(vc, animated: true)
        }
    }
    
    private func showCreateWorkoutAlert() {
//        let alert = UIAlertController(title: "Create Workout Template", message: "Enter name below", preferredStyle: .alert)
//        
//        alert.addTextField { textField in
//            textField.placeholder = "Ex. Push Day"
//            textField.autocapitalizationType = .sentences
//            let textChangedAction = UIAction { _ in
//                alert.actions[1].isEnabled = textField.text!.count > 0
//            }
//            textField.addAction(textChangedAction, for: .allEditingEvents)
//        }
//        
//        let createAction = UIAlertAction(title: "Create", style: .default) { [weak self] _ in
//            guard let self, let title = alert.textFields?[0].text else { return }
//            let workoutDetailTableViewController = WorkoutDetailTableViewController(.createWorkout(title))
//            workoutDetailTableViewController.delegate = self
//            self.navigationController?.pushViewController(workoutDetailTableViewController, animated: true)
//        }
//        
//        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
//        alert.addAction(createAction)
//        
//        self.present(alert, animated: true, completion: nil)
    }
    
    func showDeleteAlert(indexPath: IndexPath) {
        let template = templates[indexPath.row]
        let alert = UIAlertController(title: "Delete Template?", message: "Are you sure you want to delete \"\(template.title)\"", preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.addAction(UIAlertAction(title: "Remove", style: .destructive) { [weak self] _ in
            guard let self else { return }
            workoutService.deleteTemplate(&templates, at: indexPath)
            tableView.deleteRows(at: [indexPath], with: .automatic)
            contentUnavailableView.isHidden = !templates.isEmpty
        })
        
        self.present(alert, animated: true, completion: nil)
    }
}

extension WorkoutViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return templates.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        let cell = tableView.dequeueReusableCell(withIdentifier: WorkoutTableViewCell.reuseIdentifier, for: indexPath) as! WorkoutTableViewCell
//        let workout = workoutPlans[indexPath.row]
//        cell.update(with: workout)
//        return cell
        
        let cell = tableView.dequeueReusableCell(withIdentifier: WorkoutTableViewCell.reuseIdentifier, for: indexPath) as! WorkoutTableViewCell
        let template = templates[indexPath.row]
        cell.update(template: template)
        return cell
    }

}

extension WorkoutViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let template = templates[indexPath.row]
        let startWorkoutViewController = StartWorkoutViewController(template: template)
        
        let logTableViewController = (tabBarController?.viewControllers?[1] as? UINavigationController)?.viewControllers[0] as! LogViewController
        startWorkoutViewController.delegate = logTableViewController

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
//        return UIContextMenuConfiguration(identifier: nil, previewProvider: nil, actionProvider: { suggestedActions in
//            let editAction =  UIAction(title: "Edit Workout", image: UIImage(systemName: "square.and.pencil")) { [self] _ in
//                let template = workoutPlans[indexPath.row]
//                let workoutDetailTableViewController = WorkoutDetailTableViewController(.updateWorkout(template))
//                workoutDetailTableViewController.delegate = self
//                navigationController?.pushViewController(workoutDetailTableViewController, animated: true)
//            }
//
//            let deleteAction = UIAction(title: "Delete Workout", image: UIImage(systemName: "trash"), attributes: .destructive) { _ in
//                self.showDeleteAlert(indexPath: indexPath)
//            }
//            return UIMenu(title: "", children: [editAction, deleteAction])
//        })
        return nil
    }
}

//
extension WorkoutViewController: UITableViewDragDelegate {
    func tableView(_ tableView: UITableView, itemsForBeginning session: UIDragSession, at indexPath: IndexPath) -> [UIDragItem] {
//        let dragItem = UIDragItem(itemProvider: NSItemProvider())
//        dragItem.localObject = workoutPlans[indexPath.row]
//        return [dragItem]
        return []
    }
    
    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
//        guard sourceIndexPath != destinationIndexPath else { return  }
//        workoutService.reorderWorkouts(&workoutPlans, moveWorkoutAt: sourceIndexPath, to: destinationIndexPath)
    }
    
}

extension WorkoutViewController: CreateWorkoutViewControllerDelegate {
    func createWorkoutViewController(_ viewController: CreateWorkoutViewController, didCreateWorkoutTemplate template: Template) {
        template.index = Int16(templates.count)
        
        // Important: Make sure u finish modifying child object before saving or else additional changes wont be persisted to core data when saving main context
        // Have to save here because needed to update index. Or maybe pass index ahead of time
        do {
            try viewController.childContext.save()
        } catch {
            print("Error saving reordered items: \(error)")
        }
        
        CoreDataStack.shared.saveContext()
        templates.append(template)
        tableView.insertRows(at: [IndexPath(row: templates.count - 1, section: 0)], with: .automatic)
        contentUnavailableView.isHidden = !templates.isEmpty
    }
}
