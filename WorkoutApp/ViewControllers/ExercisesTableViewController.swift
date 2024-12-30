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

class ExercisesTableViewController: UIViewController {

    private let tableView: UITableView = {
        let tableView = UITableView()
        tableView.translatesAutoresizingMaskIntoConstraints = false
        return tableView
    }()
    
    struct Section {
        let letter: String
        let exercises: [String]
    }

    static let allExercises = ["Bench Press", "Squat", "Deadlift"]
    
    var selectedExercises: [String] = []
    
    var sections: [Section] = {
        let groupedDictionary = Dictionary(grouping: allExercises, by: { String($0.prefix(1)) })
        let keys = groupedDictionary.keys.sorted()
        return keys.map { Section(letter: $0, exercises: groupedDictionary[$0]!.sorted()) }
    }()
    
    var searchController = UISearchController(searchResultsController: nil)
    weak var delegate: AddExerciseDetailViewControllerDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "Exercises"

        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "ExerciseCell")
        tableView.reloadData()

        // Top bar buttons
        navigationItem.leftBarButtonItem = UIBarButtonItem(systemItem: .cancel, primaryAction: didTapCancelButton())
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Custom", primaryAction: didTapAddButton())
        
        // Search bar
        searchController.searchResultsUpdater = self
        searchController.searchBar.placeholder = "Search Exercises"
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = false
        
        view.addSubview(tableView)

        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
    }
    
    private func didTapCancelButton() -> UIAction {
        return UIAction { _ in
            self.navigationController?.dismiss(animated: true)
        }
    }
    
    private func didTapAddButton() -> UIAction {
        return UIAction { _ in
            
        }
    }
}

extension ExercisesTableViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return sections.count
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sections[section].exercises.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ExerciseCell", for: indexPath)
        let exercise = sections[indexPath.section].exercises[indexPath.row]
        var content = cell.defaultContentConfiguration()
        content.text = exercise
        cell.accessoryType = .disclosureIndicator
        cell.contentConfiguration = content
        if selectedExercises.contains(exercise) {
            tableView.selectRow(at: indexPath, animated: true, scrollPosition: .none)
        }
        return cell
    }
    
}

extension ExercisesTableViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let exercise = sections[indexPath.section].exercises[indexPath.row]
        let exerciseDetailViewController = AddExerciseDetailViewController(exercise: exercise)
        exerciseDetailViewController.delegate = self
        let vc = UINavigationController(rootViewController: exerciseDetailViewController)
        if let sheet = vc.sheetPresentationController {
            sheet.detents = [.medium()]
        }
        
        present(vc, animated: true)
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        let exercise = sections[indexPath.section].exercises[indexPath.row]
        selectedExercises.removeAll { $0 == exercise }
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return sections[section].letter
    }
    
}

extension ExercisesTableViewController: UISearchResultsUpdating {
    
    func sectionIndexTitles(for tableView: UITableView) -> [String]? {
        return sections.map{$0.letter}
    }
    
    func updateSearchResults(for searchController: UISearchController) {
        
        if let searchText = searchController.searchBar.text, !searchText.isEmpty {
            // Filter the allExercises array based on the search text
            let filteredExercises = ExercisesTableViewController.allExercises.filter { $0.localizedCaseInsensitiveContains(searchText) }

            // Update the sections with the filtered exercises
            let groupedDictionary = Dictionary(grouping: filteredExercises, by: { String($0.prefix(1)) })
            let keys = groupedDictionary.keys.sorted()
            sections = keys.map { Section(letter: $0, exercises: groupedDictionary[$0]!.sorted()) }
        } else {
            // If the search text is empty, show all exercises
            let groupedDictionary = Dictionary(grouping: ExercisesTableViewController.allExercises, by: { String($0.prefix(1)) })
            let keys = groupedDictionary.keys.sorted()
            sections = keys.map { Section(letter: $0, exercises: groupedDictionary[$0]!.sorted()) }
        }

        tableView.reloadData()
    }
}

extension ExercisesTableViewController: AddExerciseDetailViewControllerDelegate {
    func addExerciseDetailViewControllerDelegate(_ viewController: AddExerciseDetailViewController, didAddExercise exercise: String, sets: Int, reps: Int) {
        print("didAddExercise")
        delegate?.addExerciseDetailViewControllerDelegate(viewController, didAddExercise: exercise, sets: sets, reps: reps)
        presentingViewController?.dismiss(animated: true)
    }
    
    func addExerciseDetailViewControllerDelegate(_ viewController: AddExerciseDetailViewController, didDismiss: Bool) {
        guard let selectedIndexPath = tableView.indexPathForSelectedRow else { return }
        tableView.deselectRow(at: selectedIndexPath, animated: true)
    }
}
