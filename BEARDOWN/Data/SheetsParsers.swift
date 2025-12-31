//
//  SheetsParsers.swift
//  BEARDOWN
//
//  Created by Weston Crewe on 12/29/25.
//
import Foundation

enum SheetsParsers {

    /// For Split!B1:H5:
    /// - Row 0: ["Sun","Mon","Tue","Wed","Thu","Fri","Sat"]
    /// - Row 1..: activities (slots) in order for each day
    static func parseWeeklyScheduleGrid(_ rows: [[String]]) -> [Weekday: [WorkoutActivity]] {
        guard rows.count >= 2 else { return [:] }

        let header = rows[0]
        var colToWeekday: [Int: Weekday] = [:]

        for (col, name) in header.enumerated() {
            let norm = name.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
            switch norm {
            case "sun", "sunday": colToWeekday[col] = .sunday
            case "mon", "monday": colToWeekday[col] = .monday
            case "tue", "tues", "tuesday": colToWeekday[col] = .tuesday
            case "wed", "wednesday": colToWeekday[col] = .wednesday
            case "thu", "thur", "thurs", "thursday": colToWeekday[col] = .thursday
            case "fri", "friday": colToWeekday[col] = .friday
            case "sat", "saturday": colToWeekday[col] = .saturday
            default: continue
            }
        }

        var out: [Weekday: [WorkoutActivity]] = [:]

        // Slot rows start at index 1
        for rowIndex in 1..<rows.count {
            let row = rows[rowIndex]
            for (colIndex, cell) in row.enumerated() {
                guard let weekday = colToWeekday[colIndex] else { continue }
                let title = cell.trimmingCharacters(in: .whitespacesAndNewlines)
                guard !title.isEmpty else { continue }

                let activity = WorkoutActivity(
                    weekday: weekday,
                    rowIndex: rowIndex - 1, // slot 0..3
                    title: title
                )
                out[weekday, default: []].append(activity)
            }
        }

        for (k, v) in out {
            out[k] = v.sorted(by: { $0.rowIndex < $1.rowIndex })
        }
        return out
    }

    /// Details table format:
    /// A: Title, B: DurationMinutes (optional), C..: Steps
    static func parseActivityDetailsTable(_ rows: [[String]]) -> [String: ActivityDetail] {
        guard rows.count >= 2 else { return [:] }
        var out: [String: ActivityDetail] = [:]

        for i in 1..<rows.count {
            let r = rows[i]
            let title = r[safe: 0]?.trimmed ?? ""
            guard !title.isEmpty else { continue }

            let duration = Int(r[safe: 1]?.trimmed ?? "")
            let items = Array(r.dropFirst(2)).map { $0.trimmed }.filter { !$0.isEmpty }

            out[title] = ActivityDetail(title: title, durationMinutes: duration, items: items, kind: .list)
        }
        return out
    }
    /// Parses Workouts tab format:
    /// Workout Day | Workout Section | Rounds | Exercise | Reps per Exercise per Round
    /// "Workout Day" is sparse; we carry forward the last non-empty value.
    static func parseWorkoutsTab(_ rows: [[String]]) -> [String: ActivityDetail] {
            guard rows.count >= 2 else { return [:] }

            let header = rows[0].map { $0.trimmed.lowercased() }

            func colIndex(_ names: [String]) -> Int? {
                for (i, h) in header.enumerated() {
                    if names.contains(h) { return i }
                }
                return nil
            }

            let dayCol = colIndex(["workout day"]) ?? 0
            let sectionCol = colIndex(["workout section"]) ?? 1
            let roundsCol = colIndex(["rounds"]) ?? 2
            let exerciseCol = colIndex(["exercise"]) ?? 3
            let repsCol = colIndex(["reps per exercise per round"]) ?? 4

            var currentDay: String = ""
            var grouped: [String: [String: (rounds: String?, lines: [String])]] = [:]
            var sectionOrder: [String: [String]] = [:]

            for r in rows.dropFirst() {
                let dayCell = r[safe: dayCol]?.nonEmpty
                if let dayCell { currentDay = dayCell }
                guard !currentDay.isEmpty else { continue }

                let section = r[safe: sectionCol]?.nonEmpty ?? "Workout"
                let rounds = r[safe: roundsCol]?.nonEmpty
                let exercise = r[safe: exerciseCol]?.nonEmpty
                let reps = r[safe: repsCol]?.nonEmpty

                guard let ex = exercise else { continue }

                let line = (reps != nil) ? "• \(ex) — \(reps!)" : "• \(ex)"

                if grouped[currentDay] == nil { grouped[currentDay] = [:] }
                if grouped[currentDay]![section] == nil {
                    grouped[currentDay]![section] = (rounds: rounds, lines: [])
                    sectionOrder[currentDay, default: []].append(section)
                } else if grouped[currentDay]![section]!.rounds == nil, let rounds {
                    grouped[currentDay]![section]!.rounds = rounds
                }

                grouped[currentDay]![section]!.lines.append(line)
            }

            var out: [String: ActivityDetail] = [:]

            for (day, sections) in grouped {
                var items: [String] = []
                let orderedSections = sectionOrder[day] ?? Array(sections.keys)

                for sectionName in orderedSections {
                    guard let pack = sections[sectionName] else { continue }

                    if let r = pack.rounds, !r.isEmpty {
                        items.append("\(sectionName) (\(r) rounds)")
                    } else {
                        items.append(sectionName)
                    }
                    items.append(contentsOf: pack.lines)
                }

                out[TitleNormalization.key(day)] = ActivityDetail(
                    title: day,
                    durationMinutes: nil,
                    items: items,
                    kind: .list
                )
            }

            return out
        }
    static func parseSingleColumnList(_ rows: [[String]]) -> [String] {
        // rows like [["Move 1"], ["Move 2"], ...]
        return rows
            .compactMap { $0.first?.trimmed }
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }
    }
    static func parseTimedSteps(_ rows: [[String]], defaultSeconds: Int = 30) -> [TimedStep] {
            var steps: [TimedStep] = []

            for row in rows {
                // Find a name: first non-empty cell
                let name = row.first(where: { !$0.trimmed.isEmpty })?.trimmed
                guard let name, !name.isEmpty else { continue }

                // Find seconds: first cell that parses as Int
                let seconds = row.compactMap { Int($0.trimmed) }.first ?? defaultSeconds

                steps.append(TimedStep(name: name, seconds: seconds))
            }

            return steps
        }
}
