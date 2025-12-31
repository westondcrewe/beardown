//
//  CompletionStore.swift
//  BEARDOWN
//
//  Created by Weston Crewe on 12/29/25.
//

import Foundation
import SwiftData

@MainActor
final class CompletionStore {
    private let modelContext: ModelContext
    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }

    func dateKey(for date: Date, calendar: Calendar = .current) -> String {
        let comps = calendar.dateComponents([.year, .month, .day], from: date)
        let y = comps.year ?? 0
        let m = comps.month ?? 0
        let d = comps.day ?? 0
        return String(format: "%04d-%02d-%02d", y, m, d)
    }

    func isCompleted(activityId: String, on date: Date) -> Bool {
        let key = dateKey(for: date)
        let descriptor = FetchDescriptor<CompletionLog>(
            predicate: #Predicate { $0.dateKey == key && $0.activityId == activityId }
        )
        let count = (try? modelContext.fetchCount(descriptor)) ?? 0
        return count > 0
    }

    func markCompleted(activity: WorkoutActivity, on date: Date) {
        let key = dateKey(for: date)
        if isCompleted(activityId: activity.id, on: date) { return }
        modelContext.insert(CompletionLog(dateKey: key, activityId: activity.id, title: activity.title, completedAt: Date()))
        try? modelContext.save()
    }

    func completions(on date: Date) -> [CompletionLog] {
        let key = dateKey(for: date)
        let descriptor = FetchDescriptor<CompletionLog>(
            predicate: #Predicate { $0.dateKey == key },
            sortBy: [SortDescriptor(\.completedAt, order: .forward)]
        )
        return (try? modelContext.fetch(descriptor)) ?? []
    }
}
