//
//  BEARDOWNApp.swift
//  BEARDOWN
//
//  Created by Weston Crewe on 12/29/25.
//

import SwiftUI
import SwiftData
import GoogleSignIn

@main
struct MomWorkoutAppApp: App {
    var body: some Scene {
        WindowGroup {
            RootTabView()
                .onOpenURL { url in
                    GIDSignIn.sharedInstance.handle(url)
                }
        }
        .modelContainer(for: [CompletionLog.self])
    }
}
