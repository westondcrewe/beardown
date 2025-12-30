//
//  ScheduleRepository.swift
//  BEARDOWN
//
//  Created by Weston Crewe on 12/29/25.
//

import Foundation

@MainActor
final class ScheduleRepository: ObservableObject {
    // ✅ Fill this in once you know it (from the sheet URL)
    // https://docs.google.com/spreadsheets/d/<SPREADSHEET_ID>/edit#gid=...
    let spreadsheetId: String = "1tFdB9HE-NbNYzmCEpiwrxWs9hvLYcFY3bId9J8-356s"

    // ✅ Your stated schedule range
    let splitScheduleRange: String = "Split!B1:H5"

    // Details tabs (we'll search these for the activity title)
    let workoutsRange: String = "Workouts!A1:Z200"
    let morningRoutineRange: String = "Morning Routine!A1:Z200"
    let nighttimeStretchRange: String = "Nighttime Stretch!A1:Z200"

    @Published private(set) var scheduleByDay: [Weekday: [WorkoutActivity]] = [:]

    // Title -> detail
    @Published private(set) var detailsByTitle: [String: ActivityDetail] = [:]

    func refresh(accessToken: String) async throws {
        let client = GoogleSheetsClient(accessToken: accessToken)

        // 1) Schedule (Split tab)
        let scheduleRows = try await client.readValues(
            spreadsheetId: spreadsheetId,
            range: splitScheduleRange
        )
        scheduleByDay = SheetsParsers.parseWeeklyScheduleGrid(scheduleRows)

        // 2) Details: merge from three tabs
        // Later sheets overwrite earlier if same title exists.
        let workoutsRows = try await client.readValues(spreadsheetId: spreadsheetId, range: workoutsRange)
        let morningRows = try await client.readValues(spreadsheetId: spreadsheetId, range: morningRoutineRange)
        let nightRows = try await client.readValues(spreadsheetId: spreadsheetId, range: nighttimeStretchRange)

        var merged: [String: ActivityDetail] = [:]
        merged.merge(SheetsParsers.parseActivityDetailsTable(workoutsRows)) { _, new in new }
        merged.merge(SheetsParsers.parseActivityDetailsTable(morningRows)) { _, new in new }
        merged.merge(SheetsParsers.parseActivityDetailsTable(nightRows)) { _, new in new }

        detailsByTitle = merged
    }

    func activities(for weekday: Weekday) -> [WorkoutActivity] {
        scheduleByDay[weekday] ?? []
    }

    func detail(for activity: WorkoutActivity) -> ActivityDetail {
        detailsByTitle[activity.title] ?? ActivityDetail(title: activity.title, durationMinutes: nil, items: [])
    }
}
