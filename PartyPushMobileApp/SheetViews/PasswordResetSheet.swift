//
//  PasswordResetView.swift
//  Song_Requester
//
//  Created by Christian Vallat on 8/28/24.
//

import SwiftUI

struct PasswordResetSheet: View {
    @EnvironmentObject var sessionManager: SessionManager
    let authUser: AuthUser
    @Binding var showPasswordResetView: Bool
    @State var errorMessage: String? = nil

    @State private var verificationCode: String = ""
    @State private var password: String = ""
    @State private var showSuccessMessage: Bool = false
    
    var body: some View {
        ZStack {
            LinearGradient(
                colors: Palette.gradientColors,
                startPoint: .topLeading,
                endPoint: .bottomTrailing)
            .ignoresSafeArea()

            VStack(spacing: 15) {
                HStack {
                    Spacer()
                    DismissSheetButton(onDismiss: {
                        showPasswordResetView.toggle()
                    })
                }
                .padding(.top, 8)
                .padding(.trailing, 8)

                Text("Password Reset")
                    .font(.system(size: 28, weight: .semibold, design: .rounded))
                    .foregroundColor(Palette.deepTextColor)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 20)

                Group {
                    CustomTextField(text: $verificationCode, placeholder: "Verification Code")
                    CustomTextField(text: $password, placeholder: "New Password", secure: true)
                }
                .padding(.horizontal, 20)
                
                SubmitButton(title: "Reset password", action: {
                    // call reset password
                    let result = sessionManager.resetPassword(authUser: authUser, newPassword: password, confirmationCode: verificationCode)
                    if result == "We've correctly reset your password for email \(authUser.email)." {
                        showSuccessMessage = true
                    } else {
                        errorMessage = result
                    }
                })
                .alert(
                    "Success! Password has been reset",
                    isPresented: $showSuccessMessage
                ) {
                    Button ("Ok") {
                        showSuccessMessage = false
                        sessionManager.showLogin()
                    }
                }
                if let error = errorMessage {
                    Text(error)
                        .foregroundColor(.red)
                        .frame(width: 300)
                }
                Spacer()
            }
        }
    }
}

#Preview {
    PasswordResetSheet(authUser: AuthUser(), showPasswordResetView: .constant(true))
}
