//
//  ActivityDetailListView.swift
//  BEARDOWN
//
//  Created by Weston Crewe on 12/30/25.
//

import SwiftUI

struct ActivityDetailListView: View {
    let detail: ActivityDetail

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 14) {
                Text(detail.title)
                    .font(.title2).bold()
                    .foregroundColor(.black)

                switch detail.kind {
                case .timed(let steps):
                    if steps.isEmpty {
                        emptyState
                    } else {
                        let totalSeconds = steps.map(\.seconds).reduce(0, +)
                        Text("\(format(totalSeconds)) total")
                            .foregroundStyle(.secondary)

                        VStack(alignment: .leading, spacing: 10) {
                            ForEach(Array(steps.enumerated()), id: \.offset) { idx, step in
                                HStack(alignment: .top, spacing: 10) {
                                    Text("\(idx + 1).")
                                        .foregroundStyle(.secondary)

                                    Text(step.name)
                                        .foregroundColor(.black)

                                    Spacer()

                                    Text("\(step.seconds)s")
                                        .foregroundStyle(.secondary)
                                }
                            }
                        }
                        .padding(.top, 6)
                    }

                case .list:
                    if detail.items.isEmpty {
                        emptyState
                    } else {
                        if let mins = detail.durationMinutes {
                            Text("\(mins) min")
                                .foregroundStyle(.secondary)
                        }

                        VStack(alignment: .leading, spacing: 10) {
                            ForEach(Array(detail.items.enumerated()), id: \.offset) { idx, item in
                                HStack(alignment: .top, spacing: 10) {
                                    Text("\(idx + 1).")
                                        .foregroundStyle(.secondary)

                                    Text(item)
                                        .foregroundColor(.black)
                                }
                            }
                        }
                        .padding(.top, 6)
                    }
                }
            }
            .padding()
        }
    }

    private var emptyState: some View {
        Text("No details found yet for this activity.")
            .foregroundStyle(.secondary)
            .padding(.top, 8)
    }

    private func format(_ seconds: Int) -> String {
        let m = seconds / 60
        let s = seconds % 60
        if m == 0 { return "\(s)s" }
        return String(format: "%dm %02ds", m, s)
    }
}
