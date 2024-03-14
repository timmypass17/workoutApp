//
//  LogTableViewController.swift
//  WorkoutApp
//
//  Created by Timmy Nguyen on 1/17/24.
//

import UIKit

protocol LogTableViewControllerDelegate: AnyObject {
    func logTableViewController(_ viewController: LogTableViewController, didDeleteWorkout workout: Workout)
}

class LogTableViewController: UITableViewController {

    var pastWorkouts: [String: [Workout]] = [:]
    var sortedMonthYears: [String]  {
        return pastWorkouts.keys.sorted { (month1, month2) -> Bool in
            if let date1 = monthYearDateFormatter.date(from: month1), let date2 = monthYearDateFormatter.date(from: month2) {
                return date1 > date2
            }
            return false
        }
    }
    let workoutService: WorkoutService
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    weak var delegate: LogTableViewControllerDelegate?
    
    init(workoutService: WorkoutService) {
        self.workoutService = workoutService
        // Sort workouts by month/year
        let workouts: [Workout] = workoutService.fetchLoggedWorkouts()
        for workout in workouts {
            guard let createdAt = workout.createdAt else { continue }
            let monthYear = getMonthYear(from: createdAt)
            pastWorkouts[monthYear, default: []].append(workout)
        }
        super.init(style: .plain)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(tableView!,
            selector: #selector(UITableView.reloadData),
            name: WeightType.valueChangedNotification, object: nil)

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
        tableView.backgroundView = EmptyLabel(text: "Your workout history will appear here")
        
        pastWorkouts.removeAll()
        let workouts: [Workout] = workoutService.fetchLoggedWorkouts()
        for workout in workouts {
            guard let createdAt = workout.createdAt else { continue }
            let monthYear = getMonthYear(from: createdAt)
            pastWorkouts[monthYear, default: []].append(workout)
        }
        tableView.reloadData()
        tableView.backgroundView?.isHidden = pastWorkouts.isEmpty ? false : true
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return sortedMonthYears.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let month = sortedMonthYears[section]
        return pastWorkouts[month]?.count ?? 0
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: LogTableViewCell.reuseIdentifier, for: indexPath) as! LogTableViewCell
        let monthYear = sortedMonthYears[indexPath.section]
        if let workout = pastWorkouts[monthYear]?[indexPath.row] {
            cell.update(with: workout)
        }
        return cell
    }

    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }

    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if (editingStyle == .delete) {
            // Remove workout
            deleteWorkout(forRowAt: indexPath)
            tableView.deleteRows(at: [indexPath], with: .automatic)
            
            // Update tableview
            let monthYear = sortedMonthYears[indexPath.section]
            if pastWorkouts[monthYear]!.isEmpty {
                // Delete section if necessary
                pastWorkouts[monthYear] = nil
                tableView.deleteSections(IndexSet(integer: indexPath.section), with: .automatic)
            } else {
                tableView.reloadSections(IndexSet(integer: indexPath.section), with: .automatic)
            }
        }
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let monthYear = sortedMonthYears[section]
        return LogSectionHeaderView(title: monthYear, workoutCount: pastWorkouts[monthYear]?.count ?? 0)
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let month = sortedMonthYears[indexPath.section]
        guard let workouts = pastWorkouts[month] else { return }
        
        let workout = workouts[indexPath.row]
        let workoutDetailViewController = WorkoutDetailTableViewController(.updateLog(workout))
        workoutDetailViewController.delegate = self
        if let progressTableViewController = (tabBarController?.viewControllers?[2] as? UINavigationController)?.viewControllers[0] as? ProgressTableViewController {
            workoutDetailViewController.progressDelegate = progressTableViewController
        }
        navigationController?.pushViewController(workoutDetailViewController, animated: true)
    }
    
    private func deleteWorkout(forRowAt indexPath: IndexPath) {
        // Remove from core data
        let monthYear = sortedMonthYears[indexPath.section]
        let workoutToDelete = pastWorkouts[monthYear]![indexPath.row]
        // Object may have been created in detail view (has it's own seperate child context from main context). Use that specific context instead
        let context = workoutToDelete.managedObjectContext!
        context.delete(workoutToDelete)
        do {
            try context.save()
            delegate?.logTableViewController(self, didDeleteWorkout: workoutToDelete)
        } catch {
            print("Failed to delete workout: \(error)")
        }
        // Remove locally
        pastWorkouts[monthYear]?.remove(at: indexPath.row)
    }
}

extension LogTableViewController: WorkoutDetailTableViewControllerDelegate {
    func workoutDetailTableViewController(_ viewController: WorkoutDetailTableViewController, didCreateWorkout workout: Workout) {
        return
    }
    
    func workoutDetailTableViewController(_ viewController: WorkoutDetailTableViewController, didUpdateWorkout workout: Workout) {
        return
    }
    
    func workoutDetailTableViewController(_ viewController: WorkoutDetailTableViewController, didFinishWorkout workout: Workout) {
        updateUI()
    }

    func workoutDetailTableViewController(_ viewController: WorkoutDetailTableViewController, didUpdateLog workout: Workout) {
        // note: we could've optimize by updating the rows and sections of the workout but i got lazy so i just refetched data
        updateUI()
    }
}

var monthYearDateFormatter: DateFormatter {
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "MMMM yyyy"
    return dateFormatter
}

func getMonthYear(from date: Date) -> String {
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "MMMM yyyy"
    return dateFormatter.string(from: date)
}
