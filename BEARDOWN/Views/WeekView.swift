//
//  WeekView.swift
//  BEARDOWN
//
//  Created by Weston Crewe on 12/29/25.
//

import SwiftUI

struct WeekView: View {
    @StateObject private var vm = WeekViewModel()

    var body: some View {
        NavigationStack {
            List {
                if !vm.authManager().isSignedIn {
                    Section {
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
                    }
                }

                ForEach(Weekday.allCases) { day in
                    Section(day.shortName) {
                        let acts = vm.scheduleByDay[day] ?? []
                        if acts.isEmpty {
                            Text("—")
                                .foregroundStyle(.secondary)
                        } else {
                            ForEach(Array(acts.enumerated()), id: \.element.id) { idx, a in
                                HStack {
                                    Circle()
                                        .fill(ActivitySlot(index: min(idx, 3)).color.opacity(0.6))
                                        .frame(width: 10, height: 10)
                                    Text(a.title)
                                }
                            }
                        }
                    }
                }
            }
            .navigationTitle("Week")
            .task { await vm.load() }
            .refreshable { await vm.load() }
        }
    }
}
