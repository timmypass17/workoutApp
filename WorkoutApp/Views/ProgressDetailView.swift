//
//  ProgressDetailView.swift
//  WorkoutApp
//
//  Created by Timmy Nguyen on 2/9/24.
//

import SwiftUI
import Charts


struct ProgressDetailView: View {
    @ObservedObject var data: ProgressData

//    @ObservedObject var data: ProgressData
    @State private var selectedFilter: SelectedFilter = .all

    var filteredData: [ExerciseSet] {
        switch selectedFilter {
        case .all:
            return data.sets
        case .week:
            let oneWeekAgo = Calendar.current.date(byAdding: .day, value: -7, to: Date())!
            return data.sets.filter { $0.exercise!.workout!.createdAt >= oneWeekAgo }
        case .month:
            let oneMonthAgo = Calendar.current.date(byAdding: .month, value: -1, to: Date())!
            return data.sets.filter { $0.exercise!.workout!.createdAt >= oneMonthAgo }
        case .sixMonth:
            let sixMonthsAgo = Calendar.current.date(byAdding: .month, value: -6, to: Date())!
            return data.sets.filter { $0.exercise!.workout!.createdAt >= sixMonthsAgo }
        case .year:
            let oneYearAgo = Calendar.current.date(byAdding: .year, value: -1, to: Date())!
            return data.sets.filter { $0.exercise!.workout!.createdAt >= oneYearAgo }
        }
    }
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading) {
                FilterSegmentedView(selectedFilter: $selectedFilter)
                
                ProgressHeaderView(filteredData: filteredData)

//                ProgressChartView(filteredData: filteredData)
                
                Divider()
                    .padding(.bottom, 12)
                
                ProgressListView(filteredData: filteredData)
            }
            .padding([.horizontal, .bottom])
            .animation(.default, value: filteredData.count) // animation trigger when value changes
        }
    }
}

struct FilterSegmentedView: View {
    @Binding var selectedFilter: SelectedFilter
    
    var body: some View {
        Picker("Time", selection: $selectedFilter) {
            ForEach(SelectedFilter.allCases) { time in
                Text(time.rawValue.capitalized)
            }
        }
        .pickerStyle(.segmented)
    }
}

struct ProgressHeaderView: View {
    @AppStorage("weightUnit") var weightUnit: WeightType = Settings.shared.weightUnit
    var filteredData: [ExerciseSet]
    
    var personalRecordWeight: String {
        return filteredData
            .max { Float($0.weight) ?? 0.0 < Float($1.weight) ?? 0.0 }?.weightString ?? "-"
    }
    
    var dateRangeString: String {
        let startDate = filteredData.last?.exercise!.workout!.createdAt ?? Date()
        let endDate = filteredData.first?.exercise!.workout!.createdAt ?? Date()
        return "\(formatDateMonthDayYear(startDate)) - \(formatDateMonthDayYear(endDate))"
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("Personal Record".uppercased())
                .foregroundColor(.secondary)
                .font(.subheadline)
            
            HStack(alignment: .firstTextBaseline, spacing: 4) {
                Text(personalRecordWeight)
                    .font(.title)
                Text("\(weightUnit.rawValue)")
                    .foregroundColor(.secondary)
            }
            
            Text(dateRangeString)
                .foregroundColor(.secondary)
                .font(.subheadline)
        }
        .padding(.vertical, 4)
    }
}

struct ProgressListView: View {
    @Environment(\.colorScheme) var colorScheme

    var filteredData: [ExerciseSet]
    var footerSecondaryText: String {
        filteredData.count == 1 ? "Workout" : "Workouts"
    }

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Text("History".uppercased())
                
                Spacer()
                
                Text("\(filteredData.count) \(footerSecondaryText)".uppercased())
            }
            .foregroundColor(.secondary)
            .font(.caption)
            .padding(.bottom, 4)
            
            LazyVStack(spacing: 0) {
                ForEach(Array(filteredData.enumerated()), id: \.offset) { i, exercise in
                    ProgressDetailViewCell(filteredData: filteredData, i: i, exercise: exercise)
                }
            }
            .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 4))
        }
    }
}

struct ProgressDetailViewCell: View {
    @AppStorage("weightUnit") var weightUnit: WeightType = Settings.shared.weightUnit
    @Environment(\.colorScheme) var colorScheme
    var filteredData: [ExerciseSet]
    let i: Int
    let exercise: ExerciseSet
    
    func weightStringFormat(weight: Float) -> String {
        let numberFormatter = NumberFormatter()
        numberFormatter.minimumFractionDigits = 0
        numberFormatter.maximumFractionDigits = weight.truncatingRemainder(dividingBy: 1) == 0 ? 0 : 2
        return numberFormatter.string(from: NSNumber(value: weight)) ?? ""
    }
    
    var body: some View {
        VStack(spacing: 0) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("\(exercise.weightString) \(weightUnit.rawValue)")
                        .font(.headline)
                    
                    //"60lbs 3x5 Sep 20, 2023"
                    Text("\(filteredData[i].exercise!.getExerciseSets().count)x\(filteredData[i].reps) \(filteredData[i].exercise!.name) at \(formatDateMonthDayYear(filteredData[i].exercise!.workout!.createdAt))")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .lineLimit(1)
                }
                
                Spacer()
                
                // last element case (first workout done)
                if i == filteredData.count - 1 {
                    Text("-")
                        .foregroundColor(.secondary)
                } else {
//                    let weight = Float(filteredData[i].weight)!
//                    let previousWeight = Float(filteredData[i + 1].weight)!
//                    let difference = weight - previousWeight
//                    Group {
//                        if difference > 0 {
//                            // More weight
//                            Text("+\(weightStringFormat(weight: difference)) \(weightUnit.rawValue)")
//                                .foregroundStyle(.white)
//                                .padding(.horizontal, 8)
//                                .padding(.vertical, 2)
//                                .background(Color(Settings.shared.accentColor.color), in: RoundedRectangle(cornerRadius: 4))
//                        } else if difference < 0 {
//                            // Less weight
//                            Text("\(weightStringFormat(weight: difference)) \(weightUnit.rawValue)")
//                                .foregroundStyle(colorScheme == .dark ? .white : .secondary)
//                                .padding(.horizontal, 8)
//                                .padding(.vertical, 2)
//                                .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 4))
//                        } else {
//                            // No weight gain
//                            Text("+0 \(weightUnit.rawValue)")
//                                .foregroundStyle(.white)
//                                .padding(.horizontal, 8)
//                                .padding(.vertical, 2)
//                                .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 4))
//                        }
//                    }
                }
            }
            .padding()
            
            Divider()
                .opacity(i < filteredData.count - 1 ? 1 : 0)
        }
    }
}

//struct ProgressChartView: View {
//    var filteredData: [ExerciseSet]
//
//    var body: some View {
//        Chart(filteredData) { exercise in
//            LineMark(x: .value("Time", exercise.exercise?.workout?.createdAt ?? Date()),
//                     y: .value("Beats Per Minute", Float(exercise.weight)!))
//            .symbol(Circle().strokeBorder(lineWidth: 2))
//            .symbolSize(CGSize(width: 6, height: 6))
//        }
//        .chartYScale(domain: .automatic(includesZero: false))
//        .frame(height: 300)
//    }
//}


enum SelectedFilter: String, CaseIterable, Identifiable {
    case all = "all"
    case week
    case month
    case sixMonth = "6M"
    case year
    var id: Self { self }
}

func formatDateMonthDayYear(_ date: Date) -> String {
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "MMM d, yyyy"
    return dateFormatter.string(from: date)
}
