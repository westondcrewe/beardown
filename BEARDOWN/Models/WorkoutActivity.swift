//
//  WorkoutActivity.swift
//  BEARDOWN
//
//  Created by Weston Crewe on 12/29/25.
//

import Foundation

struct WorkoutActivity: Identifiable, Hashable {
    /// Stable identity based on where it came from in the schedule grid:
    /// weekday + rowIndex.
    let weekday: Weekday
    let rowIndex: Int

    let title: String

    var id: String { "\(weekday.rawValue)-\(rowIndex)" }

    /// Slot index determines color (0..3)
    var slotIndex: Int { rowIndex }
}
