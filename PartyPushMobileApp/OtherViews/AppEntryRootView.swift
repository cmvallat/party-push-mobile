//  AppEntryRootView.swift
//  PartyPushMobileApp
//
//  Created by Assistant on 6/30/25.
//

import SwiftUI

struct AppEntryRootView: View {
    @State private var showLaunchScreen = true
    @EnvironmentObject var sessionManager: SessionManager
    @StateObject var appState = AppState()
    
    var body: some View {
        Group {
            if showLaunchScreen {
                LaunchScreenView()
                    .onAppear {
                        // Skip the launch screen if already logged in (session exists)
                        if case .session = sessionManager.authState {
                            showLaunchScreen = false
                        } else {
                            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                                withAnimation(.easeOut(duration: 1)) {
                                    showLaunchScreen = false
                                }
                            }
                        }
                    }
            } else {
                switch sessionManager.authState {
                case .unauthorized(let flow):
                    switch flow {
                    case .login:
                        LoginPage()
                            .environmentObject(sessionManager)
                    case .signUp:
                        SignUpPage()
                            .environmentObject(sessionManager)
                    }
                case .resetPassword(let authUser):
                    PasswordResetPrompt(authUser: authUser)
                        .environmentObject(sessionManager)
                case .session(let authUser):
                    UserManagementPage(authUser: authUser, appState: appState)
                        .environmentObject(sessionManager)
                }
            }
        }
    }
}
