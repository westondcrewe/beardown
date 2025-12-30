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

            out[title] = ActivityDetail(title: title, durationMinutes: duration, items: items)
        }
        return out
    }
}

private extension String {
    var trimmed: String { trimmingCharacters(in: .whitespacesAndNewlines) }
}

private extension Array {
    subscript(safe idx: Int) -> Element? {
        guard idx >= 0 && idx < count else { return nil }
        return self[idx]
    }
}
