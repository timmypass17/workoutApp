//
//  LogTableViewController.swift
//  WorkoutApp
//
//  Created by Timmy Nguyen on 1/17/24.
//

import UIKit

class LogTableViewController: UITableViewController {

    var pastWorkouts: [String: [Workout]] = [:]
    var sortedMonths: [String]  {
        return pastWorkouts.keys.sorted { (month1, month2) -> Bool in
            if let date1 = monthYearDateFormatter.date(from: month1), let date2 = monthYearDateFormatter.date(from: month2) {
                return date1 > date2
            }
            return false
        }
    }
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.title = "Log"
        tableView.register(LogTableViewCell.self, forCellReuseIdentifier: LogTableViewCell.reuseIdentifier)
        
        do {
            // Sort workouts by month/year
            let workouts: [Workout] = try context.fetch(Workout.fetchRequest())
            for workout in workouts {
                guard let createdAt = workout.createdAt else { continue }
                let monthYear = getMonthYear(from: createdAt)
                pastWorkouts[monthYear, default: []].append(workout)
            }
        } catch {
            print("Failed to get workout plans: \(error)")
        }
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return sortedMonths.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let month = sortedMonths[section]
        return pastWorkouts[month]?.count ?? 0
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: LogTableViewCell.reuseIdentifier, for: indexPath) as! LogTableViewCell
        let monthYear = sortedMonths[indexPath.section]
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
            let monthYear = sortedMonths[indexPath.section]
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
        let monthYear = sortedMonths[section]
        return LogSectionHeaderView(title: monthYear, workoutCount: pastWorkouts[monthYear]?.count ?? 0)
    }
    
    private func deleteWorkout(forRowAt indexPath: IndexPath) {
        // Remove from core data
        let monthYear = sortedMonths[indexPath.section]
        context.delete(pastWorkouts[monthYear]![indexPath.row])
        do {
            try context.save()
        } catch {
            print("Failed to delete workout: \(error)")
        }
        // Remove locally
        pastWorkouts[monthYear]?.remove(at: indexPath.row)
    }
}

extension LogTableViewController: WorkoutDetailTableViewControllerDelegate {
    func workoutDetailTableViewController(_ viewController: WorkoutDetailTableViewController, didSaveWorkout workout: Workout) {
        // Update data
        guard let createdAt = workout.createdAt else { return }
        let monthYear = getMonthYear(from: createdAt)
        if pastWorkouts[monthYear] == nil {
            pastWorkouts[monthYear] = []
            tableView.insertSections(IndexSet(integer: 0), with: .automatic)
        }
        pastWorkouts[monthYear]!.insert(workout, at: 0)
        
        // Update tableview
        tableView.insertRows(at: [IndexPath(row: 0, section: 0)], with: .automatic)
        tableView.reloadSections(IndexSet(integer: 0), with: .automatic)
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
