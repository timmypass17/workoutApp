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
    @ObservedObject var recentData: ExerciseData
    @AppStorage("weightUnit") var weightUnit: WeightType = Settings.shared.weightUnit
    
    var chartData: [(offset: Int, element: Double)] {
        return Array(recentData.exerciseSets.map {
            weightUnit == .lbs ? $0.weight : $0.weight.lbsToKg
        }.enumerated())
    }
    
    var body: some View {
        HStack(alignment: .center) {
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Image(systemName: "dumbbell.fill")
                        .foregroundColor(.accentColor)
                    Text(recentData.name)
                }
                .font(.system(.headline, weight: .bold))
                
                VStack(alignment: .leading) {
                    
                    Text("Best: \(Settings.shared.weightUnit == .lbs ? recentData.bestLift.lbsString : recentData.bestLift.kgString) \(Settings.shared.weightUnit.rawValue)")
                        .font(.subheadline)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 2)
                        .background(.regularMaterial)
                        .clipShape(RoundedRectangle(cornerRadius: 4))
                    
                    HStack(alignment: .firstTextBaseline) {
                        Text("Latest: \(Settings.shared.weightUnit == .lbs ? recentData.latestLift.lbsString : recentData.latestLift.kgString) \(Settings.shared.weightUnit.rawValue)")
                            .foregroundColor(.secondary)
                            .font(.caption)
                    }
                    
                    Text("Updated: \(Date().formatted(date: .abbreviated, time: .omitted))")
                        .foregroundColor(.secondary)
                        .font(.caption2)

                }
            }
            
            Spacer(minLength: 20)
            
            // TODO: Bug if switching between lbs/kg (and tapping into detail)
            Chart(chartData, id: \.0) { index, weight in
                LineMark(
                    x: .value("Position", index),
                    y: .value("Weight", weight)
                )
                .symbol(Circle().strokeBorder(lineWidth: 2))
                .symbolSize(CGSize(width: 6, height: 6))
            }
            .chartXAxis(.hidden)
            .chartYScale(domain: .automatic(includesZero: false))
            .padding(.vertical, 8)
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
    var weights: [Double]
    
    var body: some View {
        Chart(Array(weights.enumerated()), id: \.0) { index, weight in
            LineMark(
                x: .value("Position", index),
                y: .value("Weight", weight)
            )
            .symbol(Circle().strokeBorder(lineWidth: 2))
            .symbolSize(CGSize(width: 6, height: 6))
        }
        .chartXAxis(.hidden)
//        .chartYAxis(.hidden)
        .chartYScale(domain: .automatic(includesZero: false))
        .padding(.vertical, 8)
    }
}
    
