//
//  ActivityDetail.swift
//  BEARDOWN
//
//  Created by Weston Crewe on 12/29/25.
//

import Foundation

enum ActivityDetailKind: Hashable {
    case list
    case timedIntervals(secondsPerItem: Int)
}

struct ActivityDetail: Hashable {
    let title: String
    let durationMinutes: Int?
    let items: [String]
    let kind: ActivityDetailKind
}

