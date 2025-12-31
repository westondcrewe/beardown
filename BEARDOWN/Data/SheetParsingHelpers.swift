//
//  SheetParsingHelpers.swift
//  BEARDOWN
//
//  Created by Weston Crewe on 12/30/25.
//

import Foundation

// MARK: - String helpers
extension String {
    var trimmed: String { trimmingCharacters(in: .whitespacesAndNewlines) }
    var nonEmpty: String? { trimmed.isEmpty ? nil : trimmed }
}

// MARK: - Safe indexing
extension Array {
    subscript(safe idx: Int) -> Element? {
        guard idx >= 0 && idx < count else { return nil }
        return self[idx]
    }
}
