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
            AppBackground(style: .week) {
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
                    let orderedDays = Weekday.allCases.rotatedStarting(at: Weekday.today())

                    ForEach(orderedDays) { day in
                        Section(day.shortName) {
                            let acts = vm.scheduleByDay[day] ?? []
                            if acts.isEmpty {
                                Text("—")
                                    .foregroundStyle(.secondary)
                            } else {
                                ForEach(Array(acts.enumerated()), id: \.element.id) { _, a in
                                    NavigationLink {
                                        ActivityDetailView(
                                            activity: a,
                                            detail: vm.repository().detail(for: a),
                                            mode: .preview
                                        )
                                    } label: {
                                        HStack(spacing: 10) {
                                            Circle()
                                                .fill(ActivityTheme.fromTitle(a.title).color.opacity(0.7))
                                                .frame(width: 10, height: 10)
                                            Text(a.title).foregroundColor(.black).tint(.clear)
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
                .scrollContentBackground(.hidden)
            }
            .navigationTitle("Week")
            .task { await vm.load() }
            .refreshable { await vm.load() }
        }
    }
}
