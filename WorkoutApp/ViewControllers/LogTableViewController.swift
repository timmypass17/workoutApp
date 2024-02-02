//
//  LogTableViewController.swift
//  WorkoutApp
//
//  Created by Timmy Nguyen on 1/17/24.
//

import UIKit

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
    let workoutService = WorkoutService()
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.title = "Log"
        tableView.register(LogTableViewCell.self, forCellReuseIdentifier: LogTableViewCell.reuseIdentifier)
        
        // Sort workouts by month/year
        let workouts: [Workout] = workoutService.fetchLoggedWorkouts()
        for workout in workouts {
            guard let createdAt = workout.createdAt else { continue }
            let monthYear = getMonthYear(from: createdAt)
            pastWorkouts[monthYear, default: []].append(workout)
        }
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        print("numberOfSections: \(sortedMonthYears.count)")
        return sortedMonthYears.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let month = sortedMonthYears[section]
        print("numberOfRowsInSection \(section): \(pastWorkouts[month]!.count)")
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
        navigationController?.pushViewController(workoutDetailViewController, animated: true)
    }
    
    private func deleteWorkout(forRowAt indexPath: IndexPath) {
        // Remove from core data
        let monthYear = sortedMonthYears[indexPath.section]
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
    func workoutDetailTableViewController(_ viewController: WorkoutDetailTableViewController, didCreateWorkout workout: Workout) {
        return
    }
    
    func workoutDetailTableViewController(_ viewController: WorkoutDetailTableViewController, didFinishWorkout workout: Workout) {
        guard let createdAt = workout.createdAt else { return }
        let monthYear = getMonthYear(from: createdAt)
        if pastWorkouts[monthYear] == nil {
            pastWorkouts[monthYear] = []
            tableView.insertSections(IndexSet(integer: 0), with: .automatic)
        }
        pastWorkouts[monthYear]!.insert(workout, at: 0)
        
        tableView.insertRows(at: [IndexPath(row: 0, section: 0)], with: .automatic)
        tableView.reloadSections(IndexSet(integer: 0), with: .automatic)
    }

    func workoutDetailTableViewController(_ viewController: WorkoutDetailTableViewController, didUpdateLog workout: Workout) {
        // note: we could've optimize by updating the rows and sections of the workout but i got lazy so i just refetched data
        pastWorkouts.removeAll()
        
        let workouts: [Workout] = workoutService.fetchLoggedWorkouts()
        for workout in workouts {
            guard let createdAt = workout.createdAt else { continue }
            let monthYear = getMonthYear(from: createdAt)
            pastWorkouts[monthYear, default: []].append(workout)
        }
        
        tableView.reloadData()
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
