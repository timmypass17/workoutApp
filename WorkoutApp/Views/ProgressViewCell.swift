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
    var data: ProgressData
    
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
    var sets: [ExerciseSet]
    var highestWeight: String {
        return sets.max { set, otherSet in
            let weight = Float(set.weight ?? "0") ?? 0.0
            let otherWeight = Float(otherSet.weight ?? "0") ?? 0.0
            return weight > otherWeight
        }!.weight!
    }
    
    var latestSet: ExerciseSet {
        return sets.first!
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("Best: \(highestWeight) lbs")
                .font(.subheadline)
                .padding(.horizontal, 8)
                .padding(.vertical, 2)
                .background(.secondary.opacity(0.15))
                .clipShape(RoundedRectangle(cornerRadius: 4))
            
            HStack(alignment: .firstTextBaseline) {
                Text("Latest: \(latestSet.weight!) lbs")
                    .foregroundColor(.secondary)
                    .font(.caption)
            }
            
            Text("Updated: \(latestSet.exercise!.workout!.createdAt!.formatted())")
                .foregroundColor(.secondary)
                .font(.caption2)

        }
    }
}

struct ExerciseChartView: View {
    var sets: [ExerciseSet]
    
    var body: some View {
        // Show only 7 recent exercises (graph looks funny with 100s of plots)
        Chart(sets.prefix(7)) { set in
            LineMark(x: .value("Date", set.exercise?.workout?.createdAt ?? Date()),
                     y: .value("Weight", Float(set.weight ?? "0") ?? 0.0))
            .symbol(Circle().strokeBorder(lineWidth: 2))
            .symbolSize(CGSize(width: 6, height: 6))
        }
        .chartXAxis(.hidden)
        .chartYAxis(.hidden)
        .chartYScale(domain: .automatic(includesZero: false))
        .padding(.vertical, 8)
    }
}
    
