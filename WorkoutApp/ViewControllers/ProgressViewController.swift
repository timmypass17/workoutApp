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

    init(workoutService: WorkoutService) {
        self.workoutService = workoutService
        super.init(nibName: nil, bundle: nil)
//        updateData()
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
        setupSortMenu()
        
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
                                               name: WeightType.valueChangedNotification, object: nil
        )
        
        updateData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if let selectedIndexPath = tableView.indexPathForSelectedRow {
            tableView.deselectRow(at: selectedIndexPath, animated: true)
        }
    }
    
    func updateData() {
        Task {
            exerciseData.removeAll()
            
            let exerciseNames: [String] = await workoutService.fetchExerciseNames()
            for exerciseName in exerciseNames {
                let exerciseSets: [ExerciseSet] = await workoutService.fetchExerciseSets(exerciseName: exerciseName)
                let bestLift: Double = await workoutService.fetchPR(exerciseName: exerciseName)
                
                exerciseData.append(ExerciseData(name: exerciseName, exerciseSets: exerciseSets, bestLift: bestLift, lastUpdated: .now, latestLift: exerciseSets.last?.weight ?? 0))
            }
            
            switch Settings.shared.sortingPreference {
            case .alphabetically:
                self.exerciseData.sort { $0.name < $1.name }
            case .weight:
                self.exerciseData.sort { $0.bestLift > $1.bestLift }
            case .recent:
                self.exerciseData.sort { $0.lastUpdated > $1.lastUpdated }
            }
            
            contentUnavailableView.isHidden = !exerciseData.isEmpty
            tableView.reloadData()
        }
    }
    
    
    func setupSortMenu() {
        let menuItems: [UIAction] = [
                UIAction(title: "Alphabetical (A-Z)", image: UIImage(systemName: "a.square.fill")) { _ in
                    print("alpha")
                    self.exerciseData.sort { $0.name < $1.name }
                    self.tableView.reloadData()
                    Settings.shared.sortingPreference = .alphabetically
                },
                UIAction(title: "Weight", image: UIImage(systemName: "scalemass.fill")) { _ in
                    self.exerciseData.sort { $0.bestLift > $1.bestLift }
                    self.tableView.reloadData()
                    Settings.shared.sortingPreference = .weight
                },
                UIAction(title: "Recently Updated", image: UIImage(systemName: "clock")) { _ in
                    self.exerciseData.sort { $0.lastUpdated > $1.lastUpdated }
                    self.tableView.reloadData()
                    Settings.shared.sortingPreference = .recent
                }
        ]

        let sortMenu = UIMenu(title: "Sort By", image: nil, identifier: nil, options: [], children: menuItems)

        navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "line.3.horizontal.decrease"), menu: sortMenu)
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
            ProgressViewCell(recentData: data)
        }
        
        return cell
    }
}

extension ProgressViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return exerciseData.isEmpty ? nil : "Exercises"
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        Task {
            let data = exerciseData[indexPath.row]
            let allSets = await workoutService.fetchExerciseSets(exerciseName: data.name, ascending: false)
            allSets.forEach { set in
                if Settings.shared.weightUnit == .lbs {
                    set.weight = set.weight.lbs
                } else {
                    set.weight = set.weight.lbsToKg
                }
            }
            
            let allExerciseData = ExerciseData(name: data.name, exerciseSets: allSets, bestLift: data.bestLift, lastUpdated: data.lastUpdated, latestLift: data.latestLift)
            let progressDetailView = ProgressDetailView(data: allExerciseData)
            let hostingController = UIHostingController(rootView: progressDetailView)
            hostingController.navigationItem.title = data.name
            navigationController?.pushViewController(hostingController, animated: true)
        }
    }
}

extension ProgressViewController: LogViewControllerDelegate {
    func logViewController(_ viewController: LogViewController, didDeleteLog workout: Workout) {
        updateData()
    }
    
    func logViewController(_ viewController: LogViewController, didSaveLog log: Workout) {
        updateData()
    }
}

extension ProgressViewController: StartWorkoutViewControllerDelegate {
    func startWorkoutViewController(_ viewController: StartWorkoutViewController, didFinishWorkout workout: Workout) {
        updateData()
    }
}
