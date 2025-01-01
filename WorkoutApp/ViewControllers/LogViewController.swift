//
//  LogTableViewController.swift
//  WorkoutApp
//
//  Created by Timmy Nguyen on 1/17/24.
//

import UIKit

protocol LogViewControllerDelegate: AnyObject {
    func logViewController(_ viewController: LogViewController, didDeleteWorkout workout: Workout)
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
    var months: [Date] {
        return logs.keys.sorted()
    }

    let workoutService: WorkoutService
    let context = CoreDataStack.shared.mainContext
    weak var delegate: LogViewControllerDelegate?
    
    init(workoutService: WorkoutService) {
        self.workoutService = workoutService
        // Sort workouts by month/year
        let fetchedLogs: [Workout] = workoutService.fetchLogs()
        for log in fetchedLogs {
            logs[log.monthKey, default: []].append(log)
            print(log.monthKey)
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
    
    override func viewDidAppear(_ animated: Bool) {
        Settings.shared.logBadgeValue = 0
        NotificationCenter.default.post(name: Settings.logBadgeValueChangedNotification, object: nil)
    }
    
    func updateUI() {
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.title = "Log"
        tableView.register(LogTableViewCell.self, forCellReuseIdentifier: LogTableViewCell.reuseIdentifier)
        
//        contentUnavailableView.isHidden = !pastWorkouts.isEmpty
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
        return months.count
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let month = months[section]
        return logs[month]?.count ?? 0
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: LogTableViewCell.reuseIdentifier, for: indexPath) as! LogTableViewCell
        let month = months[indexPath.section]
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
            workoutService.deleteLog(&logs, at: indexPath)
            tableView.deleteRows(at: [indexPath], with: .automatic)
            
            let month = months[indexPath.section]
            if logs[month, default: []].isEmpty {
                // Delete section if necessary
                logs[month] = nil
                tableView.deleteSections(IndexSet(integer: indexPath.section), with: .automatic)
            } else {
                // Reloadds section header
                tableView.reloadSections(IndexSet(integer: indexPath.section), with: .automatic)
            }
        }
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let month = months[section]
        return LogSectionHeaderView(title: getMonthYearString(from: month), workoutCount: logs[month]?.count ?? 0)
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let month = months[indexPath.section]
        guard let log = logs[month]?[indexPath.row] else { return }
//        let workoutDetailViewController = WorkoutDetailViewController(workoutModel: LogWorkoutModel(log: log))
//        navigationController?.pushViewController(workoutDetailViewController, animated: true)

        
//        let month = sortedMonthYears[indexPath.section]
//        guard let workouts = pastWorkouts[month] else { return }
//        
//        let workout = workouts[indexPath.row]
//        let workoutDetailViewController = WorkoutDetailTableViewController(.updateLog(workout))
//        workoutDetailViewController.delegate = self
//        if let progressTableViewController = (tabBarController?.viewControllers?[2] as? UINavigationController)?.viewControllers[0] as? ProgressViewController {
//            workoutDetailViewController.progressDelegate = progressTableViewController
//        }
//        navigationController?.pushViewController(workoutDetailViewController, animated: true)
    }
    
}

extension LogViewController: WorkoutDetailTableViewControllerDelegate {
    func workoutDetailTableViewController(_ viewController: WorkoutDetailViewController, didCreateWorkout workout: Workout) {
        return
    }
    
    func workoutDetailTableViewController(_ viewController: WorkoutDetailViewController, didUpdateWorkout workout: Workout) {
        return
    }
    
    func workoutDetailTableViewController(_ viewController: WorkoutDetailViewController, didFinishWorkout workout: Workout) {
        if let section = months.firstIndex(where: { $0 == workout.monthKey }) {
            // If section exists, reload it
            logs[workout.monthKey, default: []].append(workout)
            tableView.reloadSections(IndexSet(integer: section), with: .automatic)
        } else {
            // Else, insert section
            logs[workout.monthKey, default: []].append(workout)
            let section = months.firstIndex(where: { $0 == workout.monthKey })!
            tableView.insertSections(IndexSet(integer: section), with: .automatic)
        }
    }

    func workoutDetailTableViewController(_ viewController: WorkoutDetailViewController, didUpdateLog workout: Workout) {
        // note: we could've optimize by updating the rows and sections of the workout but i got lazy so i just refetched data
        updateUI()
    }
}

var monthYearDateFormatter: DateFormatter {
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "MMMM yyyy"
    return dateFormatter
}

func getMonthYearString(from date: Date) -> String {
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "MMMM yyyy"
    return dateFormatter.string(from: date)
}
