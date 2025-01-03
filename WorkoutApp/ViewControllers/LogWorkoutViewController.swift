//
//  LogWorkoutViewController.swift
//  BuiltDiff
//
//  Created by Timmy Nguyen on 1/2/25.
//

import UIKit

class LogWorkoutViewController: WorkoutDetailViewController {

    init(log: Workout) {
        super.init(nibName: nil, bundle: nil)
        self.workout = log
    }
    
    @MainActor required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Save", primaryAction: nil)
    }

}
