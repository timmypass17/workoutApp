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
    let allExercises = ["Bench Press", "Squat", "Deadlift", "Shoulder Press", "Dumbbell Bench Press", "Pull Ups", "Dumbbell Curl", "Barbell Curl", "Push Ups", "Sled Leg Press", "Dumbbell Shoulder Press", "Bent Over Row", "Incline Bench Press", "Incline Dumbbell Bench Press", "Front Squat", "Dips", "Lat Pulldown", "Hex Bar Deadlift", "Power Clean", "Dumbbell Lateral Raise", "Hip Thrust", "Military Press", "Chin Ups", "Leg Extension", "Sumo Deadlift", "Horizontal Leg Press", "Romanian Deadlift", "Dumbbell Row", "Chest Press", "Tricep Pushdown", "Hammer Curl", "Seated Cable Row", "Clean and Jerk", "Snatch", "Close Grip Bench Press", "Hack Squat", "Seated Leg Curl", "EZ Bar Curl", "Clean", "Dumbbell Bulgarian Split Squat", "Seated Shoulder Press", "Barbell Shrug", "Machine Chest Fly", "Push Press", "Lying Tricep Extension", "Machine Shoulder Press", "Decline Bench Press", "Dumbbell Fly", "Lying Leg Curl", "Goblet Squat", "T Bar Row", "Machine Calf Raise", "Seated Dumbbell Shoulder Press", "Preacher Curl", "Dumbbell Shrug", "Tricep Rope Pushdown", "Dumbbell Lunge", "Clean and Press", "Dumbbell Tricep Extension", "Rack Pull", "Pendlay Row", "Cable Bicep Curl", "Smith Machine Bench Press", "Vertical Leg Press", "Box Squat", "Dumbbell Concentration Curl", "Upright Row", "Bodyweight Squat", "Dumbbell Front Raise", "Bulgarian Split Squat", "Tricep Extension", "Dumbbell Romanian Deadlift", "Sit Ups", "Seated Calf Raise", "Incline Dumbbell Curl", "Cable Lateral Raise", "Machine Row", "Smith Machine Squat", "Arnold Press", "Cable Fly", "Hang Clean", "Stiff Leg Deadlift", "Floor Press", "Muscle Ups", "Good Morning", "Hip Abduction", "Face Pull", "Zercher Squat", "Incline Dumbbell Fly", "Dumbbell Pullover", "Lying Dumbbell Tricep Extension", "Barbell Lunge", "Dumbbell Floor Press", "Wrist Curl", "Dumbbell Reverse Fly", "Seated Dip Machine", "Hip Adduction", "Chest Supported Dumbbell Row", "Cable Crunch", "Overhead Squat", "Machine Seated Crunch", "Thruster", "Dumbbell Tricep Kickback", "Power Snatch", "Barbell Calf Raise", "Dumbbell Squat", "Machine Bicep Curl", "Push Jerk", "Split Squat", "Reverse Barbell Curl", "Crunches", "Decline Dumbbell Bench Press", "Close Grip Lat Pulldown", "Machine Reverse Fly", "Reverse Wrist Curl", "Cable Overhead Tricep Extension", "Dumbbell Calf Raise", "One Arm Cable Bicep Curl", "One Arm Push Ups", "Strict Curl", "Reverse Grip Bench Press", "Cable Pull Through", "Dumbbell Deadlift", "Standing Leg Curl", "Machine Tricep Extension", "Landmine Squat", "Barbell Reverse Lunge", "Barbell Glute Bridge", "Dumbbell Wrist Curl", "Diamond Push Ups", "Reverse Grip Lat Pulldown", "Sled Press Calf Raise", "Single Leg Press", "Single Leg Squat", "Deficit Deadlift", "Neck Curl", "One Arm Dumbbell Preacher Curl", "Dumbbell Upright Row", "Belt Squat", "Straight Arm Pulldown", "Neutral Grip Pull Ups", "Safety Bar Squat", "Machine Lateral Raise", "Cable Reverse Fly", "Close Grip Dumbbell Bench PRess", "Behind The Neck Press", "Seated Dumbbell Tricep Extension", "Handstand Push Ups", "Yates Row", "Barbell Front Raise", "Barbell Hack Squat", "Pistol Squat", "Bent Over Dumbbell Row", "Back Extension", "Bench Pull", "Log Press", "Machine Back Extension", "Single Leg Romanian Deadlift", "Hang Power Clean", "Sumo Squat", "Split Jerk", "Dumbbell Side Bend", "Burpees", "Clean High Pull", "Snatch Deadlift", "Dumbbell Snatch", "Incline Hammer Curl", "Barbell Pullover", "Clean Pull", "Cable Kickback", "Landmine Press", "Spider Curl", "Reverse Grip Tricep Pushdown", "One Arm Pull Ups", "Wide Grip Bench Press", "Muscle Snatch", "Bodyweight Calf Raise", "Hanging Leg Raise", "Lunge", "Dumbbell Bench Pull", "Inverted Rows", "Seated Dumbbell Curl", "Walking Lunge", "Farmers Walk", "Calf Raise", "Leg Press"]
    
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
        navigationItem.rightBarButtonItems = [
            UIBarButtonItem(title: "Add", primaryAction: addAction),
            UIBarButtonItem(image: UIImage(systemName: "square.and.pencil"), style: .plain, target: self, action: #selector(createButtonTapped))
        ]
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
    
    @objc func createButtonTapped() {
        let alert = UIAlertController(title: "Add Exercise", message: "Enter exercise name below", preferredStyle: .alert)
        
        alert.addTextField { textField in
            textField.placeholder = "Ex. Bench Press"
            textField.autocapitalizationType = .sentences
            let textChangedAction = UIAction { _ in
                alert.actions[1].isEnabled = textField.text!.count > 0
            }
            textField.addAction(textChangedAction, for: .allEditingEvents)
        }

        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.addAction(UIAlertAction(title: "Done", style: .default, handler: { _ in
            guard let exercise = alert.textFields?[0].text else { return }
            self.selectedExercises.removeAll()
            self.selectedExercises.append(exercise)
            self.delegate?.exercisesTableViewController(self, didSelectExercises: self.selectedExercises)
            self.navigationController?.dismiss(animated: true)
        }))
        
        self.present(alert, animated: true, completion: nil)
    }
}
