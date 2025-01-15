//
//  CalendarViewController.swift
//  WorkoutApp
//
//  Created by Timmy Nguyen on 2/1/24.
//

import UIKit

protocol CalendarViewControllerDelegate: AnyObject {
    func calendarViewControllerDelegate(_ viewController: CalendarViewController, didSelectDate date: Date)
}

class CalendarViewController: UIViewController {
    var initialDate: Date
    weak var delegate: CalendarViewControllerDelegate?
    
    init(date: Date) {
        self.initialDate = date
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
        datePicker.date = initialDate

        navigationItem.leftBarButtonItem = UIBarButtonItem(systemItem: .cancel, primaryAction: didTapCancelButton())
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Save", primaryAction: didTapSaveButton())

        view.addSubview(datePicker)
        NSLayoutConstraint.activate([
            datePicker.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            datePicker.topAnchor.constraint(equalTo: view.topAnchor)
        ])
    }
    
    func didTapCancelButton() -> UIAction {
        return UIAction { _ in
            self.navigationController?.dismiss(animated: true)
        }
    }
    
    func didTapSaveButton() -> UIAction {
        return UIAction { _ in
            self.delegate?.calendarViewControllerDelegate(self, didSelectDate: self.datePicker.date)
            self.navigationController?.dismiss(animated: true)
        }
    }
}
