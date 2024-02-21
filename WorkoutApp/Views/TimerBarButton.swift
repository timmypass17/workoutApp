//
//  TimerButton.swift
//  WorkoutApp
//
//  Created by Timmy Nguyen on 2/18/24.
//

import UIKit
import SwiftUI

class TimerBarButton: UIBarButtonItem, WorkoutTimerDelegate {
    var timer = WorkoutTimer()

    override init() {
        super.init()
        style = .plain
        target = self
        action = #selector(buttonTapped)
        tintColor = .secondaryLabel
        timer.delegate = self
        timer.startTimer()
        updateUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func updateUI() {
        let tmv = timeval(tv_sec: Int(timer.elapsedTime), tv_usec: 0)
        let timeElapsedString = Duration(tmv).formatted(.time(pattern: .minuteSecond))
        title = timer.isRunning ? timeElapsedString : "Paused"
    }
    
    @objc func buttonTapped() {
        if timer.isRunning {
            timer.stopTimer()
        } else {
            timer.startTimer()
        }
        updateUI()
    }
    
    func workoutTimer(_ sender: WorkoutTimer, elapsedTimeDidChange: TimeInterval) {
        updateUI()
    }
    
    func workoutTimer(_ sender: WorkoutTimer, elapsedTimeDidStart: TimeInterval) {
        updateUI()
    }
    
    func workoutTimer(_ sender: WorkoutTimer, elapsedTimeDidStop: TimeInterval) {
        updateUI()
    }
}

class WorkoutTimer {
    private var timer: Timer?
    var elapsedTime: TimeInterval = 0
    weak var delegate: WorkoutTimerDelegate?
    var isRunning: Bool {
        guard let timer else { return false }
        return timer.isValid
    }
    
    func startTimer() {
        // Have to create new timer (can't stop and start again)
        timer = Timer(timeInterval: 1.0, repeats: true) { [self] _ in
            elapsedTime += 1
            print(elapsedTime)
            delegate?.workoutTimer(self, elapsedTimeDidChange: elapsedTime)
        }
        
        RunLoop.current.add(timer!, forMode: .common)
        delegate?.workoutTimer(self, elapsedTimeDidStart: elapsedTime)
    }
    
    func stopTimer() {
        timer?.invalidate()
        delegate?.workoutTimer(self, elapsedTimeDidStop: elapsedTime)
    }
}

protocol WorkoutTimerDelegate: AnyObject {
    func workoutTimer(_ sender: WorkoutTimer, elapsedTimeDidChange: TimeInterval)
    func workoutTimer(_ sender: WorkoutTimer, elapsedTimeDidStop: TimeInterval)
    func workoutTimer(_ sender: WorkoutTimer, elapsedTimeDidStart: TimeInterval)
}

extension UIColor {
    static var accentColor = UIColor(Color.accentColor)
}
