//
//  LoginPage.swift
//  Song_Requester
//
//  Created by Christian Vallat on 8/3/24.
//

import SwiftUI

struct LoginPage: View {
    @EnvironmentObject var sessionManager: SessionManager
    @StateObject private var viewModel = LoginPageViewModel()
    
    var body: some View {
        VStack {
            Section(header: Text("Log In to My Account").font(.largeTitle)) {
                Divider()
                    .padding(.vertical)
                AuthFlowTextField(
                    label: "Email Address",
                    value: $viewModel.email,
                    secure: false
                )
                AuthFlowTextField(
                    label: "Password",
                    value: $viewModel.password,
                    secure: true
                )
                AuthFlowButton(
                    label: "Log In",
                    isPrimary: true,
                    color: .blue,
                    onClick: {
                        viewModel.login(sessionManager: sessionManager)
                    }
                )
                AuthFlowButton(
                    label: "Forgot Password?",
                    isPrimary: false,
                    color: .blue,
                    onClick: {
                        let user = AuthUser()
                        user.username = viewModel.email
                        sessionManager.showPasswordReset(authUser: user)
                    }
                )
                AuthFlowButton(
                    label: "Sign Up",
                    isPrimary: false,
                    color: .blue,
                    onClick: {
                        sessionManager.showSignUp()
                    }
                )
                if let error = viewModel.errorMessage {
                    Text(error)
                        .foregroundColor(.red)
                        .frame(width: 300)
                }
            }
        }
        .frame(
              minWidth: 0,
              maxWidth: .infinity,
              minHeight: 0,
              maxHeight: .infinity,
              alignment: .topLeading
            )
        .padding(.vertical)
        .background(Color(uiColor: UIColor.systemGray6))
    }
}

//#Preview {
//    LoginPage()
//}
