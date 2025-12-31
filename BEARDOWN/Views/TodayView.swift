//
//  TodayView.swift
//  BEARDOWN
//
//  Created by Weston Crewe on 12/29/25.
//

import SwiftUI
import SwiftData

struct TodayView: View {
    @Environment(\.modelContext) private var modelContext

    @StateObject private var vm = TodayViewModel()

    var body: some View {
        NavigationStack {
            Group {
                if !vm.authManager().isSignedIn {
                    signInView
                } else {
                    todayContent
                }
            }
            .navigationTitle("Today")
            .task {
                await vm.load()
            }
            .onReceive(NotificationCenter.default.publisher(for: UIApplication.significantTimeChangeNotification)) { _ in
                // Handles midnight/day changes
                vm.refreshForToday()
            }
        }
    }

    private var signInView: some View {
        VStack(spacing: 16) {
            Text("Sign in to load the schedule")
                .font(.headline)

            Button("Sign in with Google") {
                Task {
                    do {
                        try await vm.authManager().signIn()
                        await vm.load()
                    } catch {
                        vm.errorMessage = error.localizedDescription
                    }
                }
            }
            .buttonStyle(.borderedProminent)

            if let err = vm.errorMessage {
                Text(err).foregroundStyle(.red).font(.footnote)
            }
        }
        .padding()
    }

    private var todayContent: some View {
        let store = CompletionStore(modelContext: modelContext)
        let date = Date()

        // Gating: only first incomplete is enabled
        let firstIncompleteIndex = vm.activities.firstIndex(where: { !store.isCompleted(activityId: $0.id, on: date) })

        return ScrollView {
            VStack(spacing: 12) {
                if vm.isLoading {
                    ProgressView().padding(.top, 12)
                }

                if let err = vm.errorMessage {
                    Text(err).foregroundStyle(.red).font(.footnote)
                }

                ForEach(Array(vm.activities.enumerated()), id: \.element.id) { (idx, activity) in
                    let isCompleted = store.isCompleted(activityId: activity.id, on: date)
                    let isEnabled = (firstIncompleteIndex == idx) && !isCompleted

                    NavigationLink {
                        ActivityDetailView(activity: activity, detail: vm.repository().detail(for: activity))
                    } label: {
                        ActivityCardView(
                            title: activity.title,
                            slotIndex: idx, // color by visible order for the day
                            isCompleted: isCompleted,
                            isEnabled: isEnabled
                        )
                    }
                    .disabled(!isEnabled)
                }

                if vm.activities.isEmpty && !vm.isLoading {
                    Text("No activities found for today.")
                        .foregroundStyle(.secondary)
                        .padding(.top, 24)
                }
            }
            .padding()
        }
        .refreshable {
            await vm.load()
        }
    }
}
