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

    // Ranges
    let splitScheduleRange = "'Split'!B1:H5"
    let workoutsRange = "'Workouts'!A1:E38"
    let morningMobilityRange = "'Morning Mobility'!A1:B20"
    let coreStrengthRange = "'Core'!A1:B9"
    let nighttimeStretchRange = "'Nighttime Stretch'!A1:B12"

    @Published private(set) var scheduleByDay: [Weekday: [WorkoutActivity]] = [:]
    @Published private(set) var detailsByKey: [String: ActivityDetail] = [:]

    func refresh(accessToken: String) async throws {
        let client = GoogleSheetsClient(accessToken: accessToken)

        // 1️⃣ Fetch schedule (Split)
        let scheduleRows = try await client.readValues(
            spreadsheetId: spreadsheetId,
            range: splitScheduleRange
        )
        scheduleByDay = SheetsParsers.parseWeeklyScheduleGrid(scheduleRows)

        // 2️⃣ Fetch workouts table (THIS is where workoutsRows comes from)
        let workoutsRows = try await client.readValues(
            spreadsheetId: spreadsheetId,
            range: workoutsRange
        )

        // Parse workouts into details
        var merged: [String: ActivityDetail] =
            SheetsParsers.parseWorkoutsTab(workoutsRows)

        // 3️⃣ Morning Mobility (timed)
        let morningRows = try await client.readValues(
            spreadsheetId: spreadsheetId,
            range: morningMobilityRange
        )
        let morningSteps = SheetsParsers.parseTimedSteps(morningRows, defaultSeconds: 30)
        if !morningSteps.isEmpty {
            let title = "Morning Mobility"
            merged[TitleNormalization.key(title)] = ActivityDetail(
                title: title,
                durationMinutes: Int(ceil(Double(morningSteps.map(\.seconds).reduce(0, +)) / 60.0)),
                items: [],
                kind: .timed(steps: morningSteps)
            )
        }

        // 4️⃣ Core Strength (timed)
        let coreRows = try await client.readValues(
            spreadsheetId: spreadsheetId,
            range: coreStrengthRange
        )
        let coreSteps = SheetsParsers.parseTimedSteps(coreRows, defaultSeconds: 30)
        if !coreSteps.isEmpty {
            let title = "Core Strength"
            merged[TitleNormalization.key(title)] = ActivityDetail(
                title: title,
                durationMinutes: Int(ceil(Double(coreSteps.map(\.seconds).reduce(0, +)) / 60.0)),
                items: [],
                kind: .timed(steps: coreSteps)
            )
        }

        // 5️⃣ Nighttime Stretch (timed)
        let nightRows = try await client.readValues(
            spreadsheetId: spreadsheetId,
            range: nighttimeStretchRange
        )
        let nightSteps = SheetsParsers.parseTimedSteps(nightRows, defaultSeconds: 60)
        if !nightSteps.isEmpty {
            let title = "Nightime Stretch+Phone Off"
            merged[TitleNormalization.key(title)] = ActivityDetail(
                title: title,
                durationMinutes: Int(ceil(Double(nightSteps.map(\.seconds).reduce(0, +)) / 60.0)),
                items: [],
                kind: .timed(steps: nightSteps)
            )
        }

        // 6️⃣ Publish details
        detailsByKey = merged
    }

    func detail(for activity: WorkoutActivity) -> ActivityDetail {
        detailsByKey[TitleNormalization.key(activity.title)]
        ?? ActivityDetail(
            title: activity.title,
            durationMinutes: nil,
            items: [],
            kind: .list
        )
    }
    func activities(for weekday: Weekday) -> [WorkoutActivity] {
        scheduleByDay[weekday] ?? []
    }
}
