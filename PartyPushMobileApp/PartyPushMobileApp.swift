//
//  Song_RequesterApp.swift
//  Song_Requester
//
//  Created by Christian Vallat on 12/21/23.
//

import SwiftUI

@main
struct PartyPushMobileApp: App {
    
    @ObservedObject var sessionManager = SessionManager()
    
    var body: some Scene {
        WindowGroup {
            switch sessionManager.authState{
                
            case .login(let authUser):
                LoginView(authUser: authUser)
                    .environmentObject(sessionManager)
                
            case .signUp:
                SignUpView()
                    .environmentObject(sessionManager)
                
            case .verifyCode(let authUser):
                VerifyCodeView(authUser: authUser)
                    .environmentObject(sessionManager)
                
            case .session(let authUser):
                UserManagementPage(authUser: authUser)
                    .environmentObject(sessionManager)
                
            case .resetPassword(let authUser):
                PasswordResetPrompt(authUser: authUser)
                    .environmentObject(sessionManager)
            }
        }
    }
}
