//
//  ActivityDetailViewModel.swift
//  BEARDOWN
//
//  Created by Weston Crewe on 12/30/25.
//
import Foundation
import Combine
import SwiftData

@MainActor
final class ActivityDetailViewModel: ObservableObject {
    private let store: CompletionStore
    private let date: Date

    init(store: CompletionStore, date: Date = Date()) {
        self.store = store
        self.date = date
    }

    func isCompleted(_ activity: WorkoutActivity) -> Bool {
        store.isCompleted(activityId: activity.id, on: date)
    }

    func complete(_ activity: WorkoutActivity) {
        store.markCompleted(activity: activity, on: date)
    }
}
