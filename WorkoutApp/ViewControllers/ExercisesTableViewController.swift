//
//  ExercisesTableViewController.swift
//  WorkoutApp
//
//  Created by Timmy Nguyen on 1/22/24.
//

import UIKit

protocol ExercisesTableViewControllerDelegate: AnyObject {
    func exercisesTableViewController(_ viewController: ExercisesTableViewController, didSelectExercises exercises: [String])
}

class ExercisesTableViewController: UITableViewController, UISearchResultsUpdating {

    struct Section {
        let letter: String
        let exercises: [String]
    }

    // TODO: Maybe make this Exercise enum
    let allExercises = ["Squat", "Deadlift", "Bench Press", "Overhead Press", "Bent Over Rows", "Pull-Ups", "Lat Pulldowns", "Barbell Curl", "Tricep Dips", "Lunges", "Leg Press", "Leg Extension", "Leg Curl", "Calf Raises", "Dumbbell Rows", "Dumbbell Flyes", "Dumbbell Lateral Raises", "Dumbbell Hammer Curls", "Plank", "Russian Twists", "Arnold Press", "Front Squat", "Romanian Deadlift", "Incline Bench Press", "Cable Rows", "Face Pulls", "Close-Grip Bench Press", "Preacher Curl", "Skull Crushers", "Sumo Deadlift", "Bulgarian Split Squat", "Seated Overhead Press", "Wide Grip Pull-Ups", "Underhand Grip Pull-Ups", "Tricep Kickbacks", "Lying Leg Curl", "Leg Raises", "Side Plank", "Farmers Walk", "Reverse Flyes", "Cable Crunches", "Side Lateral Raises", "Decline Bench Press", "Hack Squat", "Seated Cable Rows", "Hammer Curl", "Close-Grip Lat Pulldowns"]
    
    var selectedExercises: [String] = []
    var sections = [Section]()
    
    var searchController = UISearchController(searchResultsController: nil)
    weak var delegate: ExercisesTableViewControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let groupedDictionary = Dictionary(grouping: allExercises, by: { String($0.prefix(1)) })
        let keys = groupedDictionary.keys.sorted()
        sections = keys.map { Section(letter: $0, exercises: groupedDictionary[$0]!.sorted()) }
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "ExerciseCell")
        tableView.reloadData()
        tableView.allowsMultipleSelectionDuringEditing = true
        tableView.setEditing(true, animated: false)
        navigationItem.title = "Exercises"
        let cancelAction = UIAction { _ in
            self.navigationController?.dismiss(animated: true)
        }
        let addAction = UIAction { _ in
            self.delegate?.exercisesTableViewController(self, didSelectExercises: self.selectedExercises)
            self.navigationController?.dismiss(animated: true)
        }
        
        // Top bar buttons
        navigationItem.leftBarButtonItem = UIBarButtonItem(systemItem: .cancel, primaryAction: cancelAction)
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Add", primaryAction: addAction)
        navigationItem.rightBarButtonItem?.isEnabled = false
        
        // Search bar
        searchController.searchResultsUpdater = self
        searchController.searchBar.placeholder = "Search Exercises"
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = false
        
        // Toolbar
        toolbarItems = [
            UIBarButtonItem(systemItem: .flexibleSpace),
            UIBarButtonItem(title: "0 selected"),
            UIBarButtonItem(systemItem: .flexibleSpace)
        ]
        
        navigationController?.setToolbarHidden(false, animated: false)
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return sections.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sections[section].exercises.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ExerciseCell", for: indexPath)
        let exercise = sections[indexPath.section].exercises[indexPath.row]
        var content = cell.defaultContentConfiguration()
        content.text = exercise
        cell.contentConfiguration = content
        if selectedExercises.contains(exercise) {
            tableView.selectRow(at: indexPath, animated: true, scrollPosition: .none)
        }
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print(indexPath)
        let exercise = sections[indexPath.section].exercises[indexPath.row]
        selectedExercises.append(exercise)
        updateUI()
    }
    
    override func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        let exercise = sections[indexPath.section].exercises[indexPath.row]
        selectedExercises.removeAll { $0 == exercise }
        updateUI()
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return sections[section].letter
    }
    
    override func sectionIndexTitles(for tableView: UITableView) -> [String]? {
        return sections.map{$0.letter}
    }
    
    func updateSearchResults(for searchController: UISearchController) {
        
        if let searchText = searchController.searchBar.text, !searchText.isEmpty {
            // Filter the allExercises array based on the search text
            let filteredExercises = allExercises.filter { $0.localizedCaseInsensitiveContains(searchText) }

            // Update the sections with the filtered exercises
            let groupedDictionary = Dictionary(grouping: filteredExercises, by: { String($0.prefix(1)) })
            let keys = groupedDictionary.keys.sorted()
            sections = keys.map { Section(letter: $0, exercises: groupedDictionary[$0]!.sorted()) }
        } else {
            // If the search text is empty, show all exercises
            let groupedDictionary = Dictionary(grouping: allExercises, by: { String($0.prefix(1)) })
            let keys = groupedDictionary.keys.sorted()
            sections = keys.map { Section(letter: $0, exercises: groupedDictionary[$0]!.sorted()) }
        }

        tableView.reloadData()
    }
    
    func updateUI() {
        navigationItem.rightBarButtonItem?.isEnabled = selectedExercises.count > 0
        toolbarItems?[1].title = "\(selectedExercises.count) selected"
    }
    
}
