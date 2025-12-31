//
//  ActivityCardView.swift
//  BEARDOWN
//
//  Created by Weston Crewe on 12/29/25.
//

import SwiftUI

struct ActivityCardView: View {
    let title: String
    let slotIndex: Int
    let isCompleted: Bool
    let isEnabled: Bool

    var body: some View {
        let color = ActivitySlot(index: min(slotIndex, 3)).color

        HStack(spacing: 12) {
            VStack(alignment: .leading, spacing: 6) {
                Text(title)
                    .font(.headline)
                    .foregroundStyle(.primary)

                Text(isCompleted ? "Completed" : (isEnabled ? "Tap to start" : "Locked"))
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            if isCompleted {
                Image(systemName: "checkmark.circle.fill")
                    .font(.title3)
            } else if !isEnabled {
                Image(systemName: "lock.fill")
                    .font(.title3)
            } else {
                Image(systemName: "chevron.right")
                    .font(.title3)
            }
        }
        .padding()
        .background(color.opacity(0.22), in: RoundedRectangle(cornerRadius: 16, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .stroke(color.opacity(0.35), lineWidth: 1)
        )
    }
}
