//
//  RootTabView.swift
//  BEARDOWN
//
//  Created by Weston Crewe on 12/30/25.
//

import SwiftUI

struct RootTabView: View {
    var body: some View {
        TabView {
            TodayView()
                .tabItem { Label("Today", systemImage: "sun.max") }

            WeekView()
                .tabItem { Label("Week", systemImage: "calendar") }
        }
    }
}
