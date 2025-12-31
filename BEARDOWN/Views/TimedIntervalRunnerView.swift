//
//  TimedIntervalRunnerView.swift
//  BEARDOWN
//
//  Created by Weston Crewe on 12/30/25.
//

import SwiftUI
import Combine
import AVFoundation

struct TimedIntervalRunnerView: View {
    let title: String
    let items: [String]
    let secondsPerItem: Int
    let onFinished: () -> Void

    @State private var index: Int = 0
    @State private var secondsRemaining: Int = 0
    @State private var hasStarted: Bool = false
    @State private var isFinished: Bool = false

    private let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()

    var body: some View {
        VStack(spacing: 16) {
            Text(title)
                .font(.title2).bold()
                .padding(.top, 8)

            if items.isEmpty {
                Text("No exercises found.")
                    .foregroundStyle(.secondary)
                Spacer()
            } else {
                workoutContent
            }
        }
        .padding()
        .onAppear {
            secondsRemaining = secondsPerItem
        }
        .onReceive(timer) { _ in
            guard hasStarted, !isFinished, !items.isEmpty else { return }
            tick()
        }
    }

    private var workoutContent: some View {
        VStack(spacing: 16) {
            VStack(spacing: 10) {
                Text("Move \(index + 1) of \(items.count)")
                    .foregroundStyle(.secondary)

                Text(items[index])
                    .font(.title)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)

                Text(timeString(secondsRemaining))
                    .font(.system(size: 56, weight: .semibold, design: .rounded))
                    .monospacedDigit()
                    .foregroundStyle(hasStarted ? .primary : .secondary)
            }
            .padding()
            .frame(maxWidth: .infinity)
            .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 20, style: .continuous))

            Button {
                start()
            } label: {
                Text(hasStarted ? "In Progress…" : "Start")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .disabled(hasStarted || items.isEmpty)

            Spacer()
        }
    }

    private func start() {
        guard !items.isEmpty else { return }
        hasStarted = true
        isFinished = false
        index = 0
        secondsRemaining = secondsPerItem
    }

    private func tick() {
        if secondsRemaining > 1 {
            secondsRemaining -= 1
            return
        }

        playChime()
        UIImpactFeedbackGenerator(style: .light).impactOccurred()

        if index < items.count - 1 {
            index += 1
            secondsRemaining = secondsPerItem
        } else {
            isFinished = true
            secondsRemaining = 0

            DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
                onFinished()
            }
        }
    }

    private func timeString(_ seconds: Int) -> String {
        let m = seconds / 60
        let s = seconds % 60
        return String(format: "%01d:%02d", m, s)
    }

    private func playChime() {
        AudioServicesPlaySystemSound(1104)
    }
}

