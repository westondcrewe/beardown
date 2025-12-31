//
//  ActivityDetail.swift
//  BEARDOWN
//
//  Created by Weston Crewe on 12/29/25.
//

import Foundation

struct TimedStep: Hashable {
    let name: String
    let seconds: Int
}

enum ActivityDetailKind: Hashable {
    case list
    case timed(steps: [TimedStep])
}

struct ActivityDetail: Hashable {
    let title: String
    let durationMinutes: Int?
    let items: [String]          // used for list-style workouts
    let kind: ActivityDetailKind
}
