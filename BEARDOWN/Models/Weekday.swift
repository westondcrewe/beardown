//
//  Weekday.swift
//  BEARDOWN
//
//  Created by Weston Crewe on 12/29/25.
//

import Foundation

enum Weekday: Int, CaseIterable, Identifiable {
    // Sun = 1 ... Sat = 7 matches Calendar.component(.weekday, from:)
    case sunday = 1, monday, tuesday, wednesday, thursday, friday, saturday

    var id: Int { rawValue }

    var shortName: String {
        switch self {
        case .sunday: return "Sun"
        case .monday: return "Mon"
        case .tuesday: return "Tue"
        case .wednesday: return "Wed"
        case .thursday: return "Thu"
        case .friday: return "Fri"
        case .saturday: return "Sat"
        }
    }

    static func today(calendar: Calendar = .current) -> Weekday {
        let wd = calendar.component(.weekday, from: Date())
        return Weekday(rawValue: wd) ?? .monday
    }
}
