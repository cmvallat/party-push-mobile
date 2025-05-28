//
//  PasswordResetView.swift
//  Song_Requester
//
//  Created by Christian Vallat on 8/28/24.
//

import SwiftUI

struct PasswordResetView: View {
    @EnvironmentObject var sessionManager: SessionManager
    @StateObject private var viewModel = LoginPageViewModel()
    @State private var verificationCode: String = ""
    @State private var password: String = ""
    @State private var confirmPassword: String = ""
    @State private var showResetCodeMessage: Bool = false
    
    var body: some View {
        VStack {
            Section(header: Text("Password Reset").font(.largeTitle)) {
                Divider()
                    .padding(.vertical)
                AuthFlowTextField(
                    label: "Verification Code",
                    value: $verificationCode,
                    secure: false
                )
                AuthFlowTextField(
                    label: "Password",
                    value: $password,
                    secure: true
                )
                AuthFlowButton(
                    label: "Reset password",
                    isPrimary: true,
                    color: .blue,
                    onClick: {
                        // view action
                    }
                ).alert(
                    "Success! Password has been reset",
                    isPresented: $showResetCodeMessage
                ) {
                    Button ("Ok") {
                        showResetCodeMessage = false
                        sessionManager.showLogin()
                    }
                }
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

#Preview {
    PasswordResetView()
}
