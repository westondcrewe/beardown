//
//  WeekViewModel.swift
//  BEARDOWN
//
//  Created by Weston Crewe on 12/30/25.
//

import Foundation
import Combine

@MainActor
final class WeekViewModel: ObservableObject {
    @Published var isLoading = false
    @Published var errorMessage: String?

    @Published var scheduleByDay: [Weekday: [WorkoutActivity]] = [:]

    private let auth = GoogleAuthManager()
    private let repo = ScheduleRepository()
    
    func repository() -> ScheduleRepository { repo }

    func load() async {
        errorMessage = nil
        isLoading = true
        defer { isLoading = false }

        await auth.restorePreviousSignInIfPossible()
        guard let token = auth.accessToken else { return }

        do {
            try await repo.refresh(accessToken: token)
            scheduleByDay = repo.scheduleByDay
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func authManager() -> GoogleAuthManager { auth }
}
