//
//  TitleNormalization.swift
//  BEARDOWN
//
//  Created by Weston Crewe on 12/30/25.
//

import Foundation

enum TitleNormalization {
    static func key(_ s: String) -> String {
        // Normalize common dash variants and whitespace/case
        let lowered = s.lowercased()
        let replacedDashes = lowered
            .replacingOccurrences(of: "–", with: "-")   // en dash -> hyphen
            .replacingOccurrences(of: "—", with: "-")   // em dash -> hyphen

        // Collapse multiple spaces and trim
        let collapsed = replacedDashes
            .components(separatedBy: .whitespacesAndNewlines)
            .filter { !$0.isEmpty }
            .joined(separator: " ")

        // Remove punctuation that tends to vary
        let allowed = collapsed.filter { ch in
            ch.isLetter || ch.isNumber || ch == " " || ch == "-"
        }

        return allowed.trimmingCharacters(in: .whitespacesAndNewlines)
    }
}
