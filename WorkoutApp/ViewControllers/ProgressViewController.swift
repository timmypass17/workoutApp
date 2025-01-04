//
//  ProgressTableViewController.swift
//  WorkoutApp
//
//  Created by Timmy Nguyen on 2/7/24.
//

import Foundation
import UIKit
import SwiftUI


class ProgressViewController: UIViewController {
    
    let tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .insetGrouped)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        return tableView
    }()
    
    var contentUnavailableView: UIView = {
        var configuration = UIContentUnavailableConfiguration.empty()
        configuration.text = "No Progress Yet"
        configuration.secondaryText = "Your progress will appear here once you finish a workout."
        configuration.image = UIImage(systemName: "chart.bar.fill")

        let view = UIContentUnavailableView(configuration: configuration)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.isHidden = true
        return view
    }()
    
    var exerciseData: [ExerciseData] = []
    let workoutService: WorkoutService
//    var data: [ProgressData]
    
    init(workoutService: WorkoutService) {
        self.workoutService = workoutService
        let exerciseNames: [String] = workoutService.fetchUniqueExerciseNames()
        for exerciseName in exerciseNames {
            let weights: [Double] = workoutService.fetchWeights(exerciseName: exerciseName)
            let bestLift: Double = workoutService.fetchMaxWeight(exerciseName: exerciseName)
            exerciseData.append(ExerciseData(name: exerciseName, weights: weights, bestLift: bestLift, lastUpdated: .now, latestLift: weights.last ?? 0))
        }
        contentUnavailableView.isHidden = !exerciseData.isEmpty
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "Progress"
        navigationController?.navigationBar.prefersLargeTitles = true
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: ProgressViewCell.reuseIdentifier)
//        setupSortMenu()
        
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
        
        NotificationCenter.default.addObserver(self,
            selector: #selector(updateUI),
            name: WeightType.valueChangedNotification, object: nil)
        
        
        updateUI()
    }
    
    @objc func updateUI() {
//        data = workoutService.fetchProgressData()
//        switch Settings.shared.sortingPreference {
//        case .alphabetically:
//            data.sort { $0.name < $1.name }
//        case .weight:
//            break
////            data.sort { data1, data2 in
////                let weight1 = Float(data1.sets.max { Float($0.weight)! < Float($1.weight)! }!.weight)!
////                let weight2 = Float(data2.sets.max { Float($0.weight)! < Float($1.weight)! }!.weight)!
////                return weight1 > weight2
////            }
//        case .recent:
//            data.sort { $0.sets.first?.exercise?.workout?.createdAt ?? Date() >  $1.sets.first?.exercise?.workout?.createdAt ?? Date() }
//        }
//        tableView.reloadData()
////        tableView.backgroundView = EmptyLabel(text: "Your workout data will appear here")
////        tableView.backgroundView?.isHidden = data.isEmpty ? false : true
//        contentUnavailableView.isHidden = !data.isEmpty
    }
    
}

extension ProgressViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return exerciseData.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: ProgressViewCell.reuseIdentifier, for: indexPath)
        let data = exerciseData[indexPath.row]
        
        cell.contentConfiguration = UIHostingConfiguration {
            ProgressViewCell(recentData: data) // SwiftUI cell
        }
        
        return cell
    }
}

extension ProgressViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return !exerciseData.isEmpty ? "Exercises" : nil
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        let data = exerciseData[indexPath.row]
//        let progressDetailView = ProgressDetailView(data: data)
//        let hostingController = UIHostingController(rootView: progressDetailView) // uihostingcontroller is a view controller (that contains swiftui view)
//        hostingController.navigationItem.title = data.name // set title here, wierd delay if setting in swiftui
//        navigationController?.pushViewController(hostingController, animated: true)
//        
//        let progressData = data[indexPath.row]
//        // Filter data by best set per day
//        var res: [ExerciseSet] = []
//        var setsByDate: [Date: [ExerciseSet]] = [:]
//        for set in progressData.sets {
//            guard let createdAt = set.exercise?.workout?.createdAt else { continue }
//            setsByDate[createdAt, default: []].append(set)
//        }
//        let sortedDates = setsByDate.keys.sorted(by: >)  // descending
//        for date in sortedDates {
//            guard let bestSet = setsByDate[date]?.max(by: { set, otherSet in
//                guard let weight = Float(set.weight),
//                      let otherWeight = Float(otherSet.weight) else { return false }
//                return weight < otherWeight
//            }) else { continue }
//            
//            res.append(bestSet)
//        }
//        let filteredData = ProgressData(name: progressData.name, sets: res)
//        let progressDetailView = ProgressDetailView(data: filteredData) // swiftui view
//        let hostingController = UIHostingController(rootView: progressDetailView) // uihostingcontroller is a view controller (that contains swiftui view)
//        hostingController.navigationItem.title = progressData.name // set title here, wierd delay if setting in swiftui
//        navigationController?.pushViewController(hostingController, animated: true)
    }
}

extension ProgressViewController: LogViewControllerDelegate {
    func logViewController(_ viewController: LogViewController, didDeleteLog workout: Workout) {
        exerciseData.removeAll()
        
        let exerciseNames: [String] = workoutService.fetchUniqueExerciseNames()
        for exerciseName in exerciseNames {
            let weights: [Double] = workoutService.fetchWeights(exerciseName: exerciseName)
            let bestLift: Double = workoutService.fetchMaxWeight(exerciseName: exerciseName)
            exerciseData.append(ExerciseData(name: exerciseName, weights: weights, bestLift: bestLift, lastUpdated: .now, latestLift: weights.last ?? 0))
        }
        contentUnavailableView.isHidden = !exerciseData.isEmpty
        tableView.reloadData()  // reload data not necessary for swiftui cell but sometimes doesnt work? just use it
    }
    
    func logViewController(_ viewController: LogViewController, didSaveLog log: Workout) {
        // Bug: Don't know why first save doesn't work
        exerciseData.removeAll()
        
        let exerciseNames: [String] = workoutService.fetchUniqueExerciseNames()
        for exerciseName in exerciseNames {
            let weights: [Double] = workoutService.fetchWeights(exerciseName: exerciseName)
            let bestLift: Double = workoutService.fetchMaxWeight(exerciseName: exerciseName)
            exerciseData.append(ExerciseData(name: exerciseName, weights: weights, bestLift: bestLift, lastUpdated: .now, latestLift: weights.last ?? 0))
        }
        contentUnavailableView.isHidden = !exerciseData.isEmpty
        tableView.reloadData()  // reload data not necessary for swiftui cell but sometimes doesnt work?
    }
}

extension ProgressViewController: StartWorkoutViewControllerDelegate {
    func startWorkoutViewController(_ viewController: StartWorkoutViewController, didFinishWorkout workout: Workout) {
                
        for exercise in workout.getExercises() {
            if let row = exerciseData.firstIndex(where: { $0.name == exercise.name }) {
                print("Updating existing row")
                // Update existing row
                exerciseData[row].weights.append(exercise.maxWeight ?? 0)
                if exerciseData[row].weights.count > 7 {
                    exerciseData[row].weights.remove(at: 0)
                }
                exerciseData[row].bestLift = max(exerciseData[row].bestLift, exercise.maxWeight ?? 0)
                exerciseData[row].lastUpdated = workout.createdAt
            } else {
                // Init new row
                print("Inserting new row")
                let weights: [Double] = [exercise.maxWeight ?? 0]
                let bestLift: Double = exercise.maxWeight ?? 0
                exerciseData.append(ExerciseData(name: exercise.name, weights: weights, bestLift: bestLift, lastUpdated: .now, latestLift: exercise.maxWeight ?? 0))
            }
        }
        
        contentUnavailableView.isHidden = !exerciseData.isEmpty
        tableView.reloadData()
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

class ExerciseData: ObservableObject {
    @Published var name: String
    @Published var weights: [Double]
    @Published var bestLift: Double
    @Published var lastUpdated: Date
    @Published var latestLift: Double
    
//    var latestLift: Double {
//        weights.last ?? 0
//    }
    
    init(name: String, weights: [Double], bestLift: Double, lastUpdated: Date, latestLift: Double) {
        self.name = name
        self.weights = weights
        self.bestLift = bestLift
        self.lastUpdated = lastUpdated
        self.latestLift = latestLift
    }
}
