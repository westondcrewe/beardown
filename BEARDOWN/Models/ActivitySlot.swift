//
//  ActivitySlot.swift
//  BEARDOWN
//
//  Created by Weston Crewe on 12/29/25.
//

import SwiftUI

struct ActivitySlot: Identifiable, Hashable {
    let index: Int
    var id: Int { index }

    var color: Color {
        switch index {
        case 0: return .yellow
        case 1: return .green
        case 2: return .blue
        default: return .purple
        }
    }

    var displayName: String {
        // optional label, you can change this later
        switch index {
        case 0: return "Slot 1"
        case 1: return "Slot 2"
        case 2: return "Slot 3"
        default: return "Slot 4"
        }
    }
}
