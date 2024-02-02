//
//  CalendarViewController.swift
//  WorkoutApp
//
//  Created by Timmy Nguyen on 2/1/24.
//

import UIKit

protocol CalendarViewControllerDelegate: AnyObject {
    func calendarViewController(_ viewController: CalendarViewController, datePickerValueChanged: Date)
}

class CalendarViewController: UIViewController {
    
    var selectedDate: Date
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    weak var delegate: CalendarViewControllerDelegate?
    
    init(selectedDate: Date) {
        print(selectedDate.formatted())
        self.selectedDate = selectedDate
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
            selectedDate = datePicker.date
            delegate?.calendarViewController(self, datePickerValueChanged: selectedDate)
            navigationController?.dismiss(animated: true)
        }

        navigationItem.leftBarButtonItem = UIBarButtonItem(systemItem: .cancel, primaryAction: cancelAction)
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Done", primaryAction: doneAction)

        datePicker.date = selectedDate
        view.addSubview(datePicker)
        NSLayoutConstraint.activate([
            datePicker.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            datePicker.topAnchor.constraint(equalTo: view.topAnchor)
        ])
    }
    
}
