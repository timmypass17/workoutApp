//
//  ExerciseDetailViewController.swift
//  BuiltDiff
//
//  Created by Timmy Nguyen on 12/29/24.
//

import UIKit

class ExerciseDetailViewController: UIViewController {

    let pickerView: UIPickerView = {
        let pickerView = UIPickerView()
        pickerView.translatesAutoresizingMaskIntoConstraints = false
        return pickerView
    }()

    let setsData = Array(1...20)
    let repsData = Array(1...50)
    var exercise: String
    
    let sets: Int
    let reps: Int
    
    init(exercise: String, sets: Int = 4, reps: Int = 12) {
        self.exercise = exercise
        self.sets = sets
        self.reps = reps
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
        
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = exercise
        view.backgroundColor = .systemBackground
        navigationItem.leftBarButtonItem = UIBarButtonItem(systemItem: .cancel, primaryAction: didTapCancelButton())

        pickerView.delegate = self
        pickerView.dataSource = self
        view.addSubview(pickerView)

        NSLayoutConstraint.activate([
            pickerView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            pickerView.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
        
        pickerView.selectRow(sets - 1, inComponent: 0, animated: true)
        pickerView.selectRow(reps - 1, inComponent: 1, animated: true)
        
        let setsLabel = UILabel(frame: CGRect(x: 95, y: pickerView.frame.midY - 15, width: 75, height: 30)) // (height / 2) = 15
        setsLabel.font = .systemFont(ofSize: 18, weight: .semibold)
        setsLabel.text = "sets"
        pickerView.addSubview(setsLabel)
        
        let repsLabel = UILabel(frame: CGRect(x: 252, y: pickerView.frame.midY - 15, width: 75, height: 30))
        repsLabel.font = .systemFont(ofSize: 18, weight: .semibold)
        repsLabel.text = "reps"
        pickerView.addSubview(repsLabel)
    }
    
    func didTapCancelButton() -> UIAction {
        return UIAction { _ in
            self.navigationController?.dismiss(animated: true)
        }
    }

}

extension ExerciseDetailViewController: UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 2 // Two fields: Sets and Reps
    }

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if component == 0 {
            return setsData.count
        } else {
            return repsData.count
        }
    }
}

extension ExerciseDetailViewController: UIPickerViewDelegate {
    
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        let label = UILabel()
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 21)

        // Customize the label text based on the component
        if component == 0 {
            label.text = "\(setsData[row])"
        } else {
            label.text = "\(repsData[row])"
        }

        return label
    }

    //    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
//        let selectedSets = setsData[pickerView.selectedRow(inComponent: 0)]
//        let selectedReps = repsData[pickerView.selectedRow(inComponent: 1)]
//
//        print("Selected: \(selectedSets) Sets, \(selectedReps) Reps")
//    }
}
