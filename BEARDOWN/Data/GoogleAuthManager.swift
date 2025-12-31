//
//  GoogleAuthManager.swift
//  BEARDOWN
//
//  Created by Weston Crewe on 12/29/25.
//

import Foundation
import Combine
import GoogleSignIn
import UIKit

@MainActor
final class GoogleAuthManager: ObservableObject {
    @Published private(set) var isSignedIn: Bool = false
    @Published private(set) var accessToken: String?

    func restorePreviousSignInIfPossible() async {
        if let user = GIDSignIn.sharedInstance.currentUser {
            isSignedIn = true
            await refreshTokenIfNeeded(user: user)
            return
        }

        do {
            let user = try await GIDSignIn.sharedInstance.restorePreviousSignIn()
            isSignedIn = true
            await refreshTokenIfNeeded(user: user)
        } catch {
            isSignedIn = false
            accessToken = nil
        }
    }

    func signIn() async throws {
        guard let root = UIApplication.shared.connectedScenes
            .compactMap({ $0 as? UIWindowScene })
            .first?.windows.first?.rootViewController else {
            throw NSError(domain: "Auth", code: 0, userInfo: [NSLocalizedDescriptionKey: "No root view controller"])
        }

        // Request Sheets scope (read-only is safest)
        let scopes = ["https://www.googleapis.com/auth/spreadsheets.readonly"]

        let result = try await GIDSignIn.sharedInstance.signIn(
            withPresenting: root,
            hint: nil,
            additionalScopes: scopes
        )

        isSignedIn = true
        await refreshTokenIfNeeded(user: result.user)
    }

    func signOut() {
        GIDSignIn.sharedInstance.signOut()
        isSignedIn = false
        accessToken = nil
    }

    private func refreshTokenIfNeeded(user: GIDGoogleUser) async {
        do {
            let tokens = try await user.refreshTokensIfNeeded()
            self.accessToken = tokens.accessToken.tokenString
        } catch {
            self.accessToken = nil
        }
    }
}
