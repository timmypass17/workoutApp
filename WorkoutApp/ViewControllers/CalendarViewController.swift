//
//  CalendarViewController.swift
//  WorkoutApp
//
//  Created by Timmy Nguyen on 2/1/24.
//

import UIKit

class CalendarViewController: UIViewController {
    var workout: Workout
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    init(workout: Workout) {
        self.workout = workout
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    var datePicker: UIDatePicker = {
        let datePicker = UIDatePicker()
        datePicker.locale = .current
        datePicker.preferredDatePickerStyle = .inline
        datePicker.translatesAutoresizingMaskIntoConstraints = false
        return datePicker
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Select Date & Time"
        view.backgroundColor = .systemBackground
        let cancelAction = UIAction { _ in
            self.navigationController?.dismiss(animated: true)
        }
        let doneAction = UIAction { [self] _ in
            workout.createdAt = datePicker.date
            navigationController?.dismiss(animated: true)
        }

        navigationItem.leftBarButtonItem = UIBarButtonItem(systemItem: .cancel, primaryAction: cancelAction)
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Confirm", primaryAction: doneAction)

        datePicker.date = workout.createdAt!
        view.addSubview(datePicker)
        NSLayoutConstraint.activate([
            datePicker.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            datePicker.topAnchor.constraint(equalTo: view.topAnchor)
        ])
    }
    
}
