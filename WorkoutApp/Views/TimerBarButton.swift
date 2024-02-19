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
        title = "0:00"
        style = .plain
        target = self
        action = #selector(buttonTapped)
        tintColor = .secondaryLabel
        timer.delegate = self
        timer.startTimer()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc func buttonTapped() {
        if timer.isRunning {
            timer.stopTimer()
            tintColor = .darkGray
        } else {
            timer.startTimer()
            tintColor = .secondaryLabel
        }
    }
    
    func workoutTimer(_ sender: WorkoutTimer, elapsedTimeDidChange: TimeInterval) {
        let tmv = timeval(tv_sec: Int(elapsedTimeDidChange), tv_usec: 0)
        title = Duration(tmv).formatted(.time(pattern: .minuteSecond))  // "2:05"
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
    }
    
    func stopTimer() {
        timer?.invalidate()
    }
}

protocol WorkoutTimerDelegate: AnyObject {
    func workoutTimer(_ sender: WorkoutTimer, elapsedTimeDidChange: TimeInterval)
}

extension UIColor {
    static var accentColor = UIColor(Color.accentColor)
}
