//
//  ActivityTheme.swift
//  BEARDOWN
//
//  Created by Weston Crewe on 12/30/25.
//

import SwiftUI

enum ActivityTheme {
    case yellow
    case red
    case orange
    case blue

    var color: Color {
        switch self {
        case .yellow: return .yellow
        case .red: return .red
        case .orange: return .orange
        case .blue: return .blue
        }
    }

    // ✅ Canonical mapping (your source of truth)
    private static let mapping: [String: ActivityTheme] = {
        func k(_ s: String) -> String { TitleNormalization.key(s) }

        var m: [String: ActivityTheme] = [:]

        // Yellow
        m[k("Morning Mobility")] = .yellow

        // Red
        ["Run", "Pickleball", "Lower Body Strength", "Upper Body Strength", "Full Body Strength"]
            .forEach { m[k($0)] = .red }

        // Orange
        ["Yoga", "Core Strength", "Breathing"]
            .forEach { m[k($0)] = .orange }

        // Blue  (note: your text says "Nightime" — keep EXACT)
        m[k("Nightime Stretch+Phone Off")] = .blue

        return m
    }()

    static func fromTitle(_ title: String) -> ActivityTheme {
        mapping[TitleNormalization.key(title)] ?? .red  // default red, per your spec
    }
}
