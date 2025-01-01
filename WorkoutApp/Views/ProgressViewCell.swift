//
//  ProgressViewCell.swift
//  WorkoutApp
//
//  Created by Timmy Nguyen on 2/7/24.
//

import SwiftUI
import Charts

struct ProgressViewCell: View {
    static let reuseIdentifier = "ProgressCell"
    @ObservedObject var data: ProgressData // automatically recreates views if data changes
    
    var body: some View {
        HStack(alignment: .center) {
            VStack(alignment: .leading, spacing: 4) {
                ExerciseTitleView(title: data.name)
                HighestWeightView(sets: data.sets)
            }
            
            Spacer(minLength: 20)
            ExerciseChartView(sets: data.sets)
                .padding(8)
        }
        .frame(height: 90)
    }
}

struct ExerciseTitleView: View {
    var title: String
    
    var body: some View {
        HStack {
            Image(systemName: "dumbbell.fill")
                .foregroundColor(.accentColor)
            Text(title)
        }
        .font(.system(.headline, weight: .bold))
    }
}

struct HighestWeightView: View {
    // special mark for UserDefaults
    @AppStorage("weightUnit") var weightUnit: WeightType = Settings.shared.weightUnit
    var sets: [ExerciseSet]
    
    var highestWeight: String {
        return sets.max { set, otherSet in
            let weight = Float(set.weight) ?? 0.0
            let otherWeight = Float(otherSet.weight) ?? 0.0
            return weight < otherWeight
        }!.weightString
    }
    
    var latestSet: ExerciseSet {
        // Get latest sets from same date
        let latestDate = sets.last?.exercise?.workout?.createdAt
        var latestSets: [ExerciseSet] = []
        var i = sets.count - 1;
        while i >= 0 && sets[i].exercise?.workout?.createdAt == latestDate {
            latestSets.append(sets[i])
            i -= 1
        }
        return latestSets.max { set, otherSet in
            let weight = Float(set.weight) ?? 0.0
            let otherWeight = Float(otherSet.weight) ?? 0.0
            return weight < otherWeight
        }!
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("Best: \(highestWeight) \(weightUnit.rawValue)")
                .font(.subheadline)
                .padding(.horizontal, 8)
                .padding(.vertical, 2)
                .background(.regularMaterial)
                .clipShape(RoundedRectangle(cornerRadius: 4))
            
            HStack(alignment: .firstTextBaseline) {
                Text("Latest: \(latestSet.weightString) \(weightUnit.rawValue)")
                    .foregroundColor(.secondary)
                    .font(.caption)
            }
            
            Text("Updated: \(latestSet.exercise?.workout?.createdAt.formatted(date: .abbreviated, time: .omitted) ?? Date().formatted(date: .abbreviated, time: .omitted))")
                .foregroundColor(.secondary)
                .font(.caption2)

        }
    }
}

struct ExerciseChartView: View {
    var sets: [ExerciseSet]
    
    var latestSet: [ExerciseSet] {
        // Get atleast 7 best set in each day
        var res: [ExerciseSet] = []
        var setsByDate: [Date: [ExerciseSet]] = [:]
        for set in sets {
            guard let createdAt = set.exercise?.workout?.createdAt else { continue }
            setsByDate[createdAt, default: []].append(set)
        }
        let sortedDates = setsByDate.keys.sorted()
        for date in sortedDates {
            if res.count >= 7 {
                break
            }
            guard let bestSet = setsByDate[date]?.max(by: { set, otherSet in
                guard let weight = Float(set.weight),
                      let otherWeight = Float(otherSet.weight) else { return false }
                return weight < otherWeight
            }) else { continue }
            
            res.append(bestSet)
        }
        return res
    }
    
    var body: some View {
        // Show only 7 recent exercises (graph looks funny with 100s of plots)
        Chart(latestSet) { set in
            LineMark(x: .value("Position", latestSet.firstIndex { $0 == set } ?? 0),
                     y: .value("Weight", Float(set.weight ) ?? 0.0))
            .symbol(Circle().strokeBorder(lineWidth: 2))
            .symbolSize(CGSize(width: 6, height: 6))
        }
        .chartXAxis(.hidden)
//        .chartYAxis(.hidden)
        .chartYScale(domain: .automatic(includesZero: false))
        .padding(.vertical, 8)
    }
}
    
