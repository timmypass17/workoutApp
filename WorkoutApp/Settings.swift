//
//  Settings.swift
//  WorkoutApp
//
//  Created by Timmy Nguyen on 2/20/24.
//

import Foundation
import UIKit
import SwiftUI

struct Settings {
    static var shared = Settings()
    private let defaults = UserDefaults.standard
    
    private func archiveJSON<T: Encodable>(value: T, key: String) {
        let data = try! JSONEncoder().encode(value)
        let string = String(data: data, encoding: .utf8)
        defaults.set(string, forKey: key)
    }
    
    private func unarchiveJSON<T: Decodable>(key: String) -> T? {
        guard let string = defaults.string(forKey: key),
              let data = string.data(using: .utf8) else {
            return nil
        }

        return try? JSONDecoder().decode(T.self, from: data)
    }
    
    var weightUnit: WeightType {
        get {
            return unarchiveJSON(key: "weightUnit") ?? .lbs
        }
        set {
            archiveJSON(value: newValue, key: "weightUnit")
        }
    }
    
    var showTimer: Bool {
        get {
            return unarchiveJSON(key: "showTimer") ?? false
        }
        set {
            archiveJSON(value: newValue, key: "showTimer")
        }
    }
    
    var weightIncrement: Double {
        let lbs: Double = 5
        let kg: Double = 2.5
        return weightUnit == .lbs ? lbs : kg
    }
    
    var theme: UIUserInterfaceStyle {
        get {
            return unarchiveJSON(key: "theme") ?? .unspecified
        }
        set {
            archiveJSON(value: newValue, key: "theme")
        }
    }
    
    var selectedAccentColor: UIColor {
        return accentColor?.color ?? customAccentColor?.toUIColor() ?? .systemBlue
    }
    
    var accentColor: AccentColor? {
        get {
            return unarchiveJSON(key: "accentColor")
        }
        set {
            archiveJSON(value: newValue, key: "accentColor")
        }
    }
    
    var customAccentColor: CodableUIColor? {
        get {
            return unarchiveJSON(key: "customAccentColor")
        }
        set {
            archiveJSON(value: newValue, key: "customAccentColor")
        }
    }
    
    var sortingPreference: SortPreference {
        get {
            return unarchiveJSON(key: "sortPreference") ?? .weight
        }
        set {
            archiveJSON(value: newValue, key: "sortPreference")
        }
    }
    
    var showAddExercise: Bool {
        get {
            return unarchiveJSON(key: "showAddExercise") ?? false
        }
        set {
            archiveJSON(value: newValue, key: "showAddExercise")
        }
    }
    
    var enableHaptic: Bool {
        get {
            return unarchiveJSON(key: "enableHaptic") ?? true
        }
        set {
            archiveJSON(value: newValue, key: "enableHaptic")
        }
    }
    
    static let logBadgeValueChangedNotification = Notification.Name("logBadgeValueChanged")
    var logBadgeValue: Int { // can't use nil in user defaults
        get {
            return unarchiveJSON(key: "logBadge") ?? 0
        }
        set {
            archiveJSON(value: newValue, key: "logBadge")
        }
    }
    
}

enum SortPreference: Codable {
    case alphabetically, weight, recent
}

extension Color {
    static let ui = Color.UI()
    
    struct UI {
        // Asset colors
        let selectedSetNumber = UIColor(named: "SelectedSetNumber")!
        let unselectedSetNumber = UIColor(named: "UnselectedSetNumber")!
    }
}

struct CodableUIColor: Codable {
    let red: CGFloat
    let green: CGFloat
    let blue: CGFloat
    let alpha: CGFloat

    init(color: UIColor) {
        var r: CGFloat = 0
        var g: CGFloat = 0
        var b: CGFloat = 0
        var a: CGFloat = 0
        color.getRed(&r, green: &g, blue: &b, alpha: &a)
        
        self.red = r
        self.green = g
        self.blue = b
        self.alpha = a
    }

    func toUIColor() -> UIColor {
        return UIColor(red: red, green: green, blue: blue, alpha: alpha)
    }
}
