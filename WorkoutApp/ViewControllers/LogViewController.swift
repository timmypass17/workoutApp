//
//  LogTableViewController.swift
//  WorkoutApp
//
//  Created by Timmy Nguyen on 1/17/24.
//

import UIKit

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
        return logs.keys.sorted()
    }

    let workoutService: WorkoutService
    weak var delegate: LogViewControllerDelegate?
    
    init(workoutService: WorkoutService) {
        self.workoutService = workoutService
        // Sort workouts by month/year
        let fetchedLogs: [Workout] = workoutService.fetchLogs()
        for log in fetchedLogs {
            logs[log.monthKey, default: []].append(log)
        }
        
        super.init(nibName: nil, bundle: nil)
    }
    
    func getMonthYearKey(workout: Workout) -> Date {
        let components = Calendar.current.dateComponents([.year, .month], from: workout.createdAt)
        return Calendar.current.date(from: components)!
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
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
        
        updateUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if let selectedIndexPath = tableView.indexPathForSelectedRow {
            tableView.deselectRow(at: selectedIndexPath, animated: true)
        }
        Settings.shared.logBadgeValue = 0
        NotificationCenter.default.post(name: Settings.logBadgeValueChangedNotification, object: nil)
    }
    
    func updateUI() {
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.title = "Log"
        tableView.register(LogTableViewCell.self, forCellReuseIdentifier: LogTableViewCell.reuseIdentifier)
        
        contentUnavailableView.isHidden = !logs.isEmpty
        
        
//        pastWorkouts.removeAll()
//        let workouts: [Workout] = workoutService.fetchLoggedWorkouts()
//        for workout in workouts {
//            guard let createdAt = workout.createdAt else { continue }
//            let monthYear = getMonthYear(from: createdAt)
//            pastWorkouts[monthYear, default: []].append(workout)
//        }
//        tableView.reloadData()
    }

//    private func deleteWorkout(forRowAt indexPath: IndexPath) {
//        // Remove from core data
//        let monthYear = sortedMonthYears[indexPath.section]
//        let workoutToDelete = pastWorkouts[monthYear]![indexPath.row]
//        // Object may have been created in detail view (has it's own seperate child context from main context). Use that specific context instead
//        let context = workoutToDelete.managedObjectContext!
//        context.delete(workoutToDelete)
//        do {
//            try context.save()
//            delegate?.logViewController(self, didDeleteWorkout: workoutToDelete)
//        } catch {
//            print("Failed to delete workout: \(error)")
//        }
//        // Remove locally
//        pastWorkouts[monthYear]?.remove(at: indexPath.row)
//    }
}

extension LogViewController: UITableViewDataSource {

    func numberOfSections(in tableView: UITableView) -> Int {
        return monthYears.count
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let month = monthYears[section]
        return logs[month]?.count ?? 0
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: LogTableViewCell.reuseIdentifier, for: indexPath) as! LogTableViewCell
        let month = monthYears[indexPath.section]
        if let workout = logs[month]?[indexPath.row] {
            cell.update(with: workout)
        }

        return cell
    }

}

extension LogViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }

    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if (editingStyle == .delete) {
            let monthYear = monthYears[indexPath.section]
            let logToRemove = logs[monthYear, default: []][indexPath.row]
            workoutService.deleteLog(&logs, at: indexPath)
            
            delegate?.logViewController(self, didDeleteLog: logToRemove)
            
            tableView.deleteRows(at: [indexPath], with: .automatic)
            
            if logs[monthYear, default: []].isEmpty {
                // Delete section if necessary
                logs[monthYear] = nil
                tableView.deleteSections(IndexSet(integer: indexPath.section), with: .automatic)
            } else {
                // Reloadds section header
                tableView.reloadSections(IndexSet(integer: indexPath.section), with: .automatic)
            }
            
            contentUnavailableView.isHidden = !logs.isEmpty
        }
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let month = monthYears[section]
        return LogSectionHeaderView(title: getMonthYearString(from: month), workoutCount: logs[month]?.count ?? 0)
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let month = monthYears[indexPath.section]
        guard let log = logs[month]?[indexPath.row] else { return }
        let logWorkoutViewController = LogDetailViewController(log: log)
        logWorkoutViewController.delegate = self
        
//        let progressTableViewController = (tabBarController?.viewControllers?[2] as? UINavigationController)?.viewControllers[0] as! ProgressViewController
//        logWorkoutViewController.progressDelegate = progressTableViewController
        navigationController?.pushViewController(logWorkoutViewController, animated: true)
    }
    
}

extension LogViewController: StartWorkoutViewControllerDelegate {
    func startWorkoutViewController(_ viewController: StartWorkoutViewController, didFinishWorkout workout: Workout) {
        // important: get workout in main context
        let mainContextWorkout = CoreDataStack.shared.mainContext.object(with: workout.objectID) as! Workout
        if let section = monthYears.firstIndex(where: { $0 == mainContextWorkout.monthKey }) {
            // If section exists, reload it
            logs[mainContextWorkout.monthKey, default: []].insert(mainContextWorkout, at: 0)
            tableView.reloadSections(IndexSet(integer: section), with: .automatic)
        } else {
            // Else, insert section
            logs[mainContextWorkout.monthKey, default: []].insert(mainContextWorkout, at: 0)
            let section = monthYears.firstIndex(where: { $0 == mainContextWorkout.monthKey })!
            tableView.insertSections(IndexSet(integer: section), with: .automatic)
        }
        contentUnavailableView.isHidden = !logs.isEmpty
    }
}


extension LogViewController: LogDetailViewControllerDelegate {
    func logDetailViewController(_ viewController: LogDetailViewController, didSaveLog log: Workout) {
        // important: get log in main context (log that was save still has child context)
        let mainContextWorkout = CoreDataStack.shared.mainContext.object(with: log.objectID) as! Workout
        
        guard let section = monthYears.firstIndex(where: { $0 == mainContextWorkout.monthKey }),
           let row = logs[log.monthKey]?.firstIndex(where: { $0.objectID == mainContextWorkout.objectID })
        else {
            return
        }
        
        logs[log.monthKey]?[row] = mainContextWorkout
        tableView.reloadRows(at: [IndexPath(row: row, section: section)], with: .automatic)
        delegate?.logViewController(self, didSaveLog: mainContextWorkout)  // progress
    }
}

func getMonthYearString(from date: Date) -> String {
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "MMMM yyyy"
    return dateFormatter.string(from: date)
}
