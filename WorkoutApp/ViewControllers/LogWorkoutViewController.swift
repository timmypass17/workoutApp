//
//  LogWorkoutViewController.swift
//  BuiltDiff
//
//  Created by Timmy Nguyen on 1/2/25.
//

import UIKit

protocol LogWorkoutViewControllerDelegate: AnyObject {
    func logWorkoutViewController(_ viewController: LogWorkoutViewController, didSaveWorkout workout: Workout)
}

class LogWorkoutViewController: WorkoutDetailViewController {

    weak var delegate: LogWorkoutViewControllerDelegate?

    init(log: Workout) {
        super.init(nibName: nil, bundle: nil)
        // Use the objectID to fetch the object in the child context
        // - Allows you to work with object in child context, and discard any changes if needed or save changes to main context
        let objectInNewContext = childContext.object(with: log.objectID) as! Workout
        self.workout = objectInNewContext
    }
    
    @MainActor required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Save", primaryAction: didTapSaveButton())
    }
    
    func didTapSaveButton() -> UIAction {
        return UIAction { [weak self] _ in
            guard let self else { return }
            self.delegate?.logWorkoutViewController(self, didSaveWorkout: workout)
            
            do {
                try childContext.save()
            } catch {
                print("Error saving reordered items: \(error)")
            }

            CoreDataStack.shared.saveContext()
            
//            progressDelegate?.workoutDetailTableViewController(self, didFinishWorkout: workout)
            navigationController?.popViewController(animated: true)
        }
    }

}
