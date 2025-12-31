//
//  ActivityCardView.swift
//  BEARDOWN
//
//  Created by Weston Crewe on 12/29/25.
//

import SwiftUI

struct ActivityCardView: View {
    let title: String
    let color: Color
    let isCompleted: Bool

    var body: some View {
        HStack(spacing: 12) {
            VStack(alignment: .leading, spacing: 6) {
                Text(title)
                    .font(.headline)
                    .foregroundColor(.black)

                Text(isCompleted ? "Completed" : "Tap to view")
                    .font(.subheadline)
                    .foregroundColor(.black.opacity(0.65))
            }

            Spacer()

            Image(systemName: isCompleted ? "checkmark.circle.fill" : "chevron.right")
                .foregroundColor(.black)
                .font(.title3)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(color.opacity(0.22))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .stroke(color.opacity(0.35), lineWidth: 1)
        )
    }
}

