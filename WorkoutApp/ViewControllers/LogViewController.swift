//
//  LogTableViewController.swift
//  WorkoutApp
//
//  Created by Timmy Nguyen on 1/17/24.
//

import UIKit
import CoreData

protocol LogViewControllerDelegate: AnyObject {
    func logViewController(_ viewController: LogViewController, didDeleteLog log: Workout)
    func logViewController(_ viewController: LogViewController, didSaveLog log: Workout)
}

class LogViewController: UIViewController {

    let tableView: UITableView = {
        let tableView = UITableView()
        tableView.translatesAutoresizingMaskIntoConstraints = false
        return tableView
    }()
    
    var contentUnavailableView: UIView = {
        var configuration = UIContentUnavailableConfiguration.empty()
        configuration.text = "No Logs Yet"
        configuration.secondaryText = "Your logs will appear here once you finish a workout."
        configuration.image = UIImage(systemName: "calendar")

        let view = UIContentUnavailableView(configuration: configuration)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.isHidden = true
        return view
    }()
    
    var logs: [Date: [Workout]] = [:]
    var monthYears: [Date] {
        return logs.keys.sorted(by: >)
    }

    let workoutService: WorkoutService
    weak var delegate: LogViewControllerDelegate?
    weak var progressDelegate: LogViewControllerDelegate?
    
    var fetchedResultsController: NSFetchedResultsController<Workout>!

    // TODO: remove later
    private lazy var dateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        return dateFormatter
    }()
    
    init(workoutService: WorkoutService) {
        self.workoutService = workoutService
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.title = "Log"
        tableView.register(LogViewCell.self, forCellReuseIdentifier: LogViewCell.reuseIdentifier)
        tableView.register(LogSectionHeaderView.self, forHeaderFooterViewReuseIdentifier: LogSectionHeaderView.reuseIdentifier)

        NotificationCenter.default.addObserver(tableView,
            selector: #selector(UITableView.reloadData),
            name: WeightType.valueChangedNotification, object: nil)

        tableView.dataSource = self
        tableView.delegate = self
        
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
        
        let fetchRequest: NSFetchRequest<Workout> = Workout.fetchRequest()
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: #keyPath(Workout.createdAt_), ascending: false)]

        fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest,
                                                              managedObjectContext: CoreDataStack.shared.mainContext,
                                                              sectionNameKeyPath: #keyPath(Workout.createdMonthID),
                                                              cacheName: nil)
                
        fetchedResultsController.delegate = self
        
        // Perform a fetch.
        do {
            // actually fetches from cloudkit, when delete and reinstall app
            try fetchedResultsController?.performFetch()
            contentUnavailableView.isHidden = !(fetchedResultsController.fetchedObjects?.isEmpty ?? true)
            print("Logs fetched: \(fetchedResultsController!.fetchedObjects?.count ?? 0)")
        } catch {
            // Handle error appropriately. It's useful to use
            // `fatalError(_:file:line:)` during development.
            fatalError("Failed to perform fetch: \(error.localizedDescription)")
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if let selectedIndexPath = tableView.indexPathForSelectedRow {
            tableView.deselectRow(at: selectedIndexPath, animated: true)
        }
        Settings.shared.logBadgeValue = 0
        NotificationCenter.default.post(name: Settings.logBadgeValueChangedNotification, object: nil)
    }
    
    func showDeleteAlert(at indexPath: IndexPath) {
        let logToRemove = fetchedResultsController.object(at: indexPath)
        
        let alert = UIAlertController(title: "Delete Log?", message: "Are you sure you want to delete \"\(logToRemove.title)\"", preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.addAction(UIAlertAction(title: "Remove", style: .destructive) { [weak self] _ in
            guard let self else { return }
            deleteLog(at: indexPath)
        })
        
        self.present(alert, animated: true, completion: nil)
    }
    
    func deleteLog(at indexPath: IndexPath) {
        let logToRemove = fetchedResultsController.object(at: indexPath)
        CoreDataStack.shared.mainContext.delete(logToRemove)
        CoreDataStack.shared.saveContext()
        progressDelegate?.logViewController(self, didDeleteLog: logToRemove)
    }
}

extension LogViewController: UITableViewDataSource {

    func numberOfSections(in tableView: UITableView) -> Int {
        return fetchedResultsController.sections?.count ?? 0
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return fetchedResultsController.sections?[section].numberOfObjects ?? 0
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: LogViewCell.reuseIdentifier, for: indexPath) as! LogViewCell
        let log = fetchedResultsController.object(at: indexPath)
        cell.update(workout: log)
        return cell
    }


}

extension LogViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }

    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if (editingStyle == .delete) {
            showDeleteAlert(at: indexPath)
        }
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard let sections = fetchedResultsController.sections, !sections.isEmpty,
              let date = Workout.date(from: sections[section].name) else {
            return nil
        }
        
        let headerView = tableView.dequeueReusableHeaderFooterView(withIdentifier: LogSectionHeaderView.reuseIdentifier) as! LogSectionHeaderView
        headerView.update(dateMonth: date, workoutCount: fetchedResultsController.sections?[section].numberOfObjects ?? 0)
        return headerView
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let log = fetchedResultsController.object(at: indexPath)
        let logWorkoutViewController = LogDetailViewController(log: log, workoutService: workoutService)
        logWorkoutViewController.delegate = self
        
//        let progressTableViewController = (tabBarController?.viewControllers?[2] as? UINavigationController)?.viewControllers[0] as! ProgressViewController
//        logWorkoutViewController.progressDelegate = progressTableViewController
        navigationController?.pushViewController(logWorkoutViewController, animated: true)
    }
    
}

extension LogViewController: LogDetailViewControllerDelegate {
    func logDetailViewController(_ viewController: LogDetailViewController, didSaveLog log: Workout) {
        // note: Updating relationships doesn't work with nsfetchresultcontroller, so reload data explicity
        tableView.reloadData()
        progressDelegate?.logViewController(self, didSaveLog: log)  // update progress aswell, isn't using nsfetchedresultcontroller
    }
}

extension LogViewController: NSFetchedResultsControllerDelegate {
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<any NSFetchRequestResult>) {
        tableView.beginUpdates()
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<any NSFetchRequestResult>) {
        tableView.endUpdates()
        updateSectionHeaders()
    }
    
    func controller(_ controller: NSFetchedResultsController<any NSFetchRequestResult>,
                    didChange sectionInfo: any NSFetchedResultsSectionInfo,
                    atSectionIndex sectionIndex: Int,
                    for type: NSFetchedResultsChangeType) {
        switch type {
        case .insert:
            tableView.insertSections(IndexSet(integer: sectionIndex), with: .automatic)
        case .delete:
            tableView.deleteSections(IndexSet(integer: sectionIndex), with: .automatic)
        default:
            break
        }
    }
        
    // Find out when the fetched results controller adds, removes, moves, or updates a fetched object.
    func controller(_ controller: NSFetchedResultsController<any NSFetchRequestResult>,
                    didChange anObject: Any,
                    at indexPath: IndexPath?,
                    for type: NSFetchedResultsChangeType,
                    newIndexPath: IndexPath?) {
        
        switch type {
        case .insert:
            guard let newIndexPath else { return }
            tableView.insertRows(at: [newIndexPath], with: .fade)
        case .delete:
            guard let indexPath else { return }
            tableView.deleteRows(at: [indexPath], with: .fade)
        case .update:
            guard let indexPath else { return }
            if let cell = tableView.cellForRow(at: indexPath) as? LogViewCell {
                let log = fetchedResultsController.object(at: indexPath)
                cell.update(workout: log)
            }
            
        case .move:
            guard let indexPath, let newIndexPath else { return }
            tableView.moveRow(at: indexPath, to: newIndexPath)
        @unknown default:
            break
        }
        
        contentUnavailableView.isHidden = !(controller.fetchedObjects?.isEmpty ?? true)
    }
    
    private func updateSectionHeaders() {
        guard let sections = fetchedResultsController.sections else { return }
        for section in 0..<sections.count {
            if let headerView = tableView.headerView(forSection: section) as? LogSectionHeaderView,
               let date = Workout.date(from: sections[section].name) {
                headerView.update(dateMonth: date, workoutCount: sections[section].numberOfObjects)
            }
        }
    }
}
