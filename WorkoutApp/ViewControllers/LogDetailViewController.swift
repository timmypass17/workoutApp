//
//  LogWorkoutViewController.swift
//  BuiltDiff
//
//  Created by Timmy Nguyen on 1/2/25.
//

import UIKit

protocol LogDetailViewControllerDelegate: AnyObject {
    func logDetailViewController(_ viewController: LogDetailViewController, didSaveLog log: Workout)
}

class LogDetailViewController: WorkoutDetailViewController {

    weak var delegate: LogDetailViewControllerDelegate?    // log handles

    init(log: Workout, workoutService: WorkoutService) {
        super.init(workoutService: workoutService)
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
        
        let saveButton = UIBarButtonItem(title: "Save", primaryAction: didTapSaveButton())
        let calendarButton = UIBarButtonItem(image: UIImage(systemName: "calendar"), primaryAction: didTapCalendarButton())
        navigationItem.rightBarButtonItems = [saveButton, calendarButton]
    }
    
    func didTapSaveButton() -> UIAction {
        return UIAction { [weak self] _ in
            guard let self else { return }
            
            do {
                try childContext.save()
            } catch {
                print("Error saving reordered items: \(error)")
            }

            CoreDataStack.shared.saveContext()

            self.delegate?.logDetailViewController(self, didSaveLog: workout)
            navigationController?.popViewController(animated: true)
        }
    }
    
    func didTapCalendarButton() -> UIAction {
        return UIAction { [weak self] _ in
            guard let self = self else { return }

            let calendarViewController = CalendarViewController(date: workout.createdAt)
            calendarViewController.delegate = self
            let navigationController = UINavigationController(rootViewController: calendarViewController)
            if let sheet = navigationController.sheetPresentationController {
                sheet.detents = [.custom(resolver: { context in
                    return self.view.frame.height * 0.6
                })]
            }
            self.present(navigationController, animated: true)
        }
    }

}

extension LogDetailViewController: CalendarViewControllerDelegate {
    func calendarViewControllerDelegate(_ viewController: CalendarViewController, didSelectDate date: Date) {
        workout.createdAt = date
    }
}
