//
//  TodayViewModel.swift
//  BEARDOWN
//
//  Created by Weston Crewe on 12/30/25.
//

import Foundation
import Combine
import SwiftUI
import SwiftData

@MainActor
final class TodayViewModel: ObservableObject {
    @Published var isLoading = false
    @Published var errorMessage: String?

    @Published var todayWeekday: Weekday = .today()
    @Published var activities: [WorkoutActivity] = []

    private let auth = GoogleAuthManager()
    private let repo = ScheduleRepository()

    func authManager() -> GoogleAuthManager { auth }
    func repository() -> ScheduleRepository { repo }

    func load() async {
        errorMessage = nil
        isLoading = true
        defer { isLoading = false }

        await auth.restorePreviousSignInIfPossible()
        guard let token = auth.accessToken else { return }

        do {
            try await repo.refresh(accessToken: token)
            refreshForToday()
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func refreshForToday() {
        todayWeekday = .today()
        activities = repo.activities(for: Weekday.today())
    }
}
