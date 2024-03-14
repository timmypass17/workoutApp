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

    var sortMenu: UIMenu {
        var menuItems: [UIAction] = [
                UIAction(title: "Alphabetical (A-Z)", image: UIImage(systemName: "a.square.fill")) { _ in
                    // Handle sorting alphabetically
                    self.data.sort { $0.name < $1.name }
                    self.tableView.reloadData()
                    Settings.shared.sortingPreference = .alphabetically
                },
                UIAction(title: "Weight", image: UIImage(systemName: "scalemass.fill")) { _ in
                    // Handle sorting by weight
                    self.data.sort { data1, data2 in
                        let weight1 = Float(data1.sets.max { Float($0.weight)! < Float($1.weight)! }!.weight)!
                        let weight2 = Float(data2.sets.max { Float($0.weight)! < Float($1.weight)! }!.weight)!
                        return weight1 > weight2
                    }
                    self.tableView.reloadData()
                    Settings.shared.sortingPreference = .weight
                },
                UIAction(title: "Recently Updated", image: UIImage(systemName: "clock")) { _ in
                    self.data.sort { $0.sets.first?.exercise?.workout?.createdAt ?? Date() >  $1.sets.first?.exercise?.workout?.createdAt ?? Date() }
                    self.tableView.reloadData()
                    Settings.shared.sortingPreference = .recent
                }
        ]
        return UIMenu(title: "Sort By", image: nil, identifier: nil, options: [], children: menuItems)
    }
    
    init(workoutService: WorkoutService) {
        // Load data
        self.data = workoutService.fetchProgressData()
            .sorted(by: { $0.name < $1.name})
        self.workoutService = workoutService
        super.init(style: .insetGrouped)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self,
            selector: #selector(updateUI),
            name: WeightType.valueChangedNotification, object: nil)
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "line.3.horizontal.decrease"), menu: sortMenu)
        updateUI()
    }
    
    @objc func updateUI() {
        navigationItem.title = "Progress"
        navigationController?.navigationBar.prefersLargeTitles = true
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: ProgressViewCell.reuseIdentifier)
        data = workoutService.fetchProgressData()
        switch Settings.shared.sortingPreference {
        case .alphabetically:
            data.sort { $0.name < $1.name }
        case .weight:
            data.sort { data1, data2 in
                let weight1 = Float(data1.sets.max { Float($0.weight)! < Float($1.weight)! }!.weight)!
                let weight2 = Float(data2.sets.max { Float($0.weight)! < Float($1.weight)! }!.weight)!
                return weight1 > weight2
            }
        case .recent:
            data.sort { $0.sets.first?.exercise?.workout?.createdAt ?? Date() >  $1.sets.first?.exercise?.workout?.createdAt ?? Date() }
        }
        tableView.reloadData()
        tableView.backgroundView = EmptyLabel(text: "Your workout data will appear here")
        tableView.backgroundView?.isHidden = data.isEmpty ? false : true
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
            ProgressViewCell(data: setsInSection) // SwiftUI cell
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        guard !data.isEmpty else{ return nil }
        return "Exercises"
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let progressData = data[indexPath.row]
        // Filter data by best set per day
        var res: [ExerciseSet] = []
        var setsByDate: [Date: [ExerciseSet]] = [:]
        for set in progressData.sets {
            guard let createdAt = set.exercise?.workout?.createdAt else { continue }
            setsByDate[createdAt, default: []].append(set)
        }
        let sortedDates = setsByDate.keys.sorted(by: >)  // descending
        for date in sortedDates {
            guard let bestSet = setsByDate[date]?.max(by: { set, otherSet in
                guard let weight = Float(set.weight),
                      let otherWeight = Float(otherSet.weight) else { return false }
                return weight < otherWeight
            }) else { continue }
            
            res.append(bestSet)
        }
        let filteredData = ProgressData(name: progressData.name, sets: res)
        let progressDetailView = ProgressDetailView(data: filteredData) // swiftui view
        let hostingController = UIHostingController(rootView: progressDetailView) // uihostingcontroller is a view controller (that contains swiftui view)
        hostingController.navigationItem.title = progressData.name // set title here, wierd delay if setting in swiftui
        navigationController?.pushViewController(hostingController, animated: true)
    }
    
}

extension ProgressTableViewController: WorkoutDetailTableViewControllerDelegate {
    func workoutDetailTableViewController(_ viewController: WorkoutDetailTableViewController, didCreateWorkout workout: Workout) {
        // Creating workout template shouldn't update log
        return
    }
    
    func workoutDetailTableViewController(_ viewController: WorkoutDetailTableViewController, didUpdateWorkout workout: Workout) {
        return
    }
    
    func workoutDetailTableViewController(_ viewController: WorkoutDetailTableViewController, didFinishWorkout workout: Workout) {
        var setDict: [String : [ExerciseSet]] = [:]
        let exercises = workout.getExercises()
        for exercise in exercises {
            setDict[exercise.title, default: []].append(contentsOf: exercise.getExerciseSets())
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
        updateUI()
    }
    
    func workoutDetailTableViewController(_ viewController: WorkoutDetailTableViewController, didUpdateLog workout: Workout) {
        updateUI()
    }
    
}

extension ProgressTableViewController: LogTableViewControllerDelegate {
    func logTableViewController(_ viewController: LogTableViewController, didDeleteWorkout workout: Workout) {
        updateUI()
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
