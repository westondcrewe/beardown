//
//  ActivityDetailView.swift
//  BEARDOWN
//
//  Created by Weston Crewe on 12/29/25.
//

import SwiftUI
import SwiftData

struct ActivityDetailView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    let activity: WorkoutActivity
    let detail: ActivityDetail

    var body: some View {
        let store = CompletionStore(modelContext: modelContext)
        let vm = ActivityDetailViewModel(store: store)

        Group {
            switch detail.kind {
            case .timedIntervals(let seconds):
                TimedIntervalRunnerView(
                    title: detail.title,
                    items: detail.items,
                    secondsPerItem: seconds
                ) {
                    // ✅ auto mark complete + return to Today
                    if !vm.isCompleted(activity) {
                        vm.complete(activity)
                    }
                    dismiss()
                }

            case .list:
                ScrollView {
                    VStack(alignment: .leading, spacing: 16) {
                        Text(detail.title)
                            .font(.title2).bold()

                        if let mins = detail.durationMinutes {
                            Label("\(mins) min", systemImage: "clock")
                                .foregroundStyle(.secondary)
                        }

                        if !detail.items.isEmpty {
                            VStack(alignment: .leading, spacing: 10) {
                                Text("Steps")
                                    .font(.headline)

                                ForEach(Array(detail.items.enumerated()), id: \.offset) { idx, item in
                                    Text(item)
                                }
                            }
                        } else {
                            Text("No details found yet for this activity.")
                                .foregroundStyle(.secondary)
                        }

                        Button {
                            vm.complete(activity)
                            dismiss()
                        } label: {
                            Text(vm.isCompleted(activity) ? "Completed" : "Mark as Completed")
                                .frame(maxWidth: .infinity)
                        }
                        .buttonStyle(.borderedProminent)
                        .disabled(vm.isCompleted(activity))
                        .padding(.top, 8)
                    }
                    .padding()
                }
            }
        }
        .navigationTitle("Activity")
        .navigationBarTitleDisplayMode(.inline)
    }
}
