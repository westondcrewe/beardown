//
//  AppBackground.swift
//  BEARDOWN
//
//  Created by Weston Crewe on 12/30/25.
//

import SwiftUI

enum AppBackgroundStyle {
    case today
    case week
}

struct AppBackground<Content: View>: View {
    let style: AppBackgroundStyle
    @ViewBuilder let content: Content

    var body: some View {
        ZStack {
            background
                .ignoresSafeArea()

            content
        }
    }

    @ViewBuilder
    private var background: some View {
        switch style {
        case .today:
            LinearGradient(
                colors: [.white, Color(hex: "87B1FA")],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )

        case .week:
            LinearGradient(
                colors: [.white, Color(hex: "F5BD6C")],
                startPoint: .top,
                endPoint: .bottom
            )
        }
    }
}
