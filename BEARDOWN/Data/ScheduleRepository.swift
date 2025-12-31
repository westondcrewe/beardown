//
//  ScheduleRepository.swift
//  BEARDOWN
//
//  Created by Weston Crewe on 12/29/25.
//

import Foundation
import Combine

@MainActor
final class ScheduleRepository: ObservableObject {
    let spreadsheetId: String = "1tFdB9HE-NbNYzmCEpiwrxWs9hvLYcFY3bId9J8-356s"

    let splitScheduleRange: String = "Split!B1:H5"
    let workoutsRange: String = "Workouts!A1:E500"

    // ✅ Morning routine as a single column list
    let morningRoutineRange: String = "Morning Routine!A1:A200"

    @Published private(set) var scheduleByDay: [Weekday: [WorkoutActivity]] = [:]
    @Published private(set) var detailsByKey: [String: ActivityDetail] = [:]

    func refresh(accessToken: String) async throws {
        let client = GoogleSheetsClient(accessToken: accessToken)

        // Schedule
        let scheduleRows = try await client.readValues(spreadsheetId: spreadsheetId, range: splitScheduleRange)
        scheduleByDay = SheetsParsers.parseWeeklyScheduleGrid(scheduleRows)

        // Workouts details
        let workoutsRows = try await client.readValues(spreadsheetId: spreadsheetId, range: workoutsRange)
        var merged: [String: ActivityDetail] = [:]
        let workoutDetails = SheetsParsers.parseWorkoutsTab(workoutsRows)
        merged.merge(workoutDetails) { _, new in new }

        // Morning Routine timed intervals (30s each)
        let morningRows = try await client.readValues(spreadsheetId: spreadsheetId, range: morningRoutineRange)
        let moves = SheetsParsers.parseSingleColumnList(morningRows)
        if !moves.isEmpty {
            let title = "Morning Routine"
            merged[TitleNormalization.key(title)] = ActivityDetail(
                title: title,
                durationMinutes: Int(ceil(Double(moves.count * 30) / 60.0)),
                items: moves,
                kind: .timedIntervals(secondsPerItem: 30)
            )
        }

        detailsByKey = merged
    }

    func activities(for weekday: Weekday) -> [WorkoutActivity] {
        scheduleByDay[weekday] ?? []
    }

    func detail(for activity: WorkoutActivity) -> ActivityDetail {
        let k = TitleNormalization.key(activity.title)
        return detailsByKey[k] ?? ActivityDetail(title: activity.title, durationMinutes: nil, items: [], kind: .list)
    }
}
