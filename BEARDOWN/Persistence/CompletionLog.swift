//
//  CompletionLog.swift
//  BEARDOWN
//
//  Created by Weston Crewe on 12/29/25.
//

import Foundation
import SwiftData

@Model
final class CompletionLog {
    var dateKey: String   // "YYYY-MM-DD" in local time
    var activityId: String
    var title: String
    var completedAt: Date

    init(dateKey: String, activityId: String, title: String, completedAt: Date) {
        self.dateKey = dateKey
        self.activityId = activityId
        self.title = title
        self.completedAt = completedAt
    }
}
