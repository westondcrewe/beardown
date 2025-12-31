//
//  ActivityDetailView.swift
//  BEARDOWN
//
//  Created by Weston Crewe on 12/29/25.
//

import SwiftUI
import SwiftData

enum ActivityDetailMode: Hashable {
    case today(isNextToDo: Bool, isCompleted: Bool)
    case preview
}

struct ActivityDetailView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    let activity: WorkoutActivity
    let detail: ActivityDetail
    let mode: ActivityDetailMode

    var body: some View {
        let store = CompletionStore(modelContext: modelContext)
        let vm = ActivityDetailViewModel(store: store)

        switch mode {
        case .preview:
            ActivityDetailListView(detail: detail)
                .navigationTitle("Details")
                .navigationBarTitleDisplayMode(.inline)

        case .today(let isNextToDo, let isCompleted):
            if isCompleted || !isNextToDo {
                ActivityDetailListView(detail: detail)
                    .navigationTitle("Details")
                    .navigationBarTitleDisplayMode(.inline)
            } else {
                Group {
                    if case .timed(let steps) = detail.kind {
                        TimedIntervalRunnerView(
                            title: detail.title,
                            steps: steps
                        ) {
                            vm.complete(activity)
                            dismiss()
                        }
                    } else {
                        VStack(spacing: 0) {
                            ActivityDetailListView(detail: detail)

                            Button {
                                vm.complete(activity)
                                dismiss()
                            } label: {
                                Text("Mark as Completed")
                                    .frame(maxWidth: .infinity)
                            }
                            .buttonStyle(.borderedProminent)
                            .padding()
                        }
                    }
                }
                .navigationTitle("Activity")
                .navigationBarTitleDisplayMode(.inline)
            }
        }
    }
}
