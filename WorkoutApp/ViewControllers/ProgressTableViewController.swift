//
//  ProgressTableViewController.swift
//  WorkoutApp
//
//  Created by Timmy Nguyen on 2/7/24.
//

import Foundation
import UIKit
import SwiftUI


class ProgressTableViewController: UITableViewController {
        
    var data: [ProgressData]
    let workoutService: WorkoutService

    init(workoutService: WorkoutService) {
        // Load data
        self.data = workoutService.fetchProgressData()
        self.workoutService = workoutService
        data.forEach { print($0.name, $0.sets.count)}
        super.init(style: .insetGrouped)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "Progress"
        navigationController?.navigationBar.prefersLargeTitles = true
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: ProgressViewCell.reuseIdentifier)
    }
    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: ProgressViewCell.reuseIdentifier, for: indexPath)
        let setsInSection = data[indexPath.row]
        
        cell.contentConfiguration = UIHostingConfiguration {
            ProgressViewCell(data: setsInSection)
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "Exercises"
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print(indexPath, data[indexPath.section].name)
    }

}

extension ProgressTableViewController: WorkoutDetailTableViewControllerDelegate {
    func workoutDetailTableViewController(_ viewController: WorkoutDetailTableViewController, didCreateWorkout workout: Workout) {
        // Creating workout template shouldn't update log
        return
    }
    
    func workoutDetailTableViewController(_ viewController: WorkoutDetailTableViewController, didFinishWorkout workout: Workout) {
        var setDict: [String : [ExerciseSet]] = [:]
        let exercises = workout.getExercises()
        for exercise in exercises {
            setDict[exercise.title!, default: []].append(contentsOf: exercise.getExerciseSets())
        }
        
        // Update progress data
        for (exerciseName, sets) in setDict {
            if let progressData = data.first(where: { $0.name == exerciseName }) {
                // Update section
                progressData.sets.append(contentsOf: sets)
            } else {
                // Create section
                data.append(ProgressData(name: exerciseName, sets: sets))
            }
        }
                
        tableView.reloadData()
        return
    }
    
    func workoutDetailTableViewController(_ viewController: WorkoutDetailTableViewController, didUpdateLog workout: Workout) {
        return
    }
    
}


enum ProgressError: Error {
    case missingCreatedAt
}

class ProgressData: ObservableObject {
    @Published var name: String
    @Published var sets: [ExerciseSet]
    
    init(name: String, sets: [ExerciseSet]) {
        self.name = name
        self.sets = sets
    }
}
