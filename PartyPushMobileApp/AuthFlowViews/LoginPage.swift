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
    @State private var showSheet = false
    @State private var email: String = ""
    @State private var showResetCodeMessage = false
    
    var body: some View {
        ZStack {
            LinearGradient(
                colors: Palette.gradientColors,
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            VStack {
                Spacer()
                
                // Centered Title and Rectangle
                VStack(spacing: 6) {
                    Text("Login")
                        .font(.system(size: 38, weight: .black, design: .rounded))
                        .foregroundColor(Palette.deepTextColor)
                    
                    Rectangle()
                        .frame(width: 80, height: 3)
                        .foregroundColor(Palette.accentRed)
                        .cornerRadius(1.5)
                }
                
                // Input fields
                VStack(spacing: 16) {
                    Group{
                        CustomTextField(
                            text: $viewModel.username,
                            placeholder: "Username",
//                            secure: false
                        )
                        CustomTextField(
                            text: $viewModel.password,
                            placeholder: "Password",
                            secure: true
                        )
                    }
                    .padding(.horizontal, 20)
                    SubmitButton(
                        title: "Log in",
                        isLoading: false,
                        action: {
                            viewModel.login(sessionManager: sessionManager)
                        }
                    )
                }
                .padding(.top, 30)
                .padding(.horizontal, 30)
                
                Spacer()
                
                // Forgot Password & Sign Up
                VStack(spacing: 8) {
                    Button("Forgot Password") {
                        showSheet = true
                    }
                    .font(.body)
                    .foregroundColor(.white.opacity(0.8))
                    .sheet(isPresented: $showSheet) {
                        ForgotPasswordSheet(
                            email: $email,
                            isPresented: $showSheet,
                            showResetCodeMessage: $showResetCodeMessage,
                            sessionManager: sessionManager
                        )
                        .presentationDetents([.medium, .large])
                    }
                    
                    Button("Sign Up") {
                        sessionManager.showSignUp()
                    }
                    .font(.body)
                    .foregroundColor(.white.opacity(0.8))
                }
                .padding(.bottom, 30)
            }
            .alert("Error", isPresented: Binding<Bool>(
                get: { viewModel.errorMessage != nil },
                set: { _ in viewModel.errorMessage = nil }
            )) {
                Button("OK", role: .cancel) {}
            } message: {
                Text(viewModel.errorMessage ?? "Unknown error")
            }
        }
    }
}


#Preview {
    LoginPage()
}
