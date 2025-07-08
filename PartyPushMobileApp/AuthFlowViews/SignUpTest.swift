//
//  SignUpTest.swift
//  PartyPushMobileApp
//
//  Created by Christian Vallat on 7/8/25.
//

import SwiftUI

struct SignUpTest: View {
    @EnvironmentObject var sessionManager: SessionManager
    @State var authUser = AuthUser()
    @State var code = ""
    @State private var showSheet = false
    @State private var showResendCodeMessage = false
    @State private var resendCodeMessage: String = ""
    @StateObject var viewModel = SignUpPageViewModel()
    
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
                
                // Centered Title
                VStack(spacing: 6) {
                    Text("Create Account")
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
                            text: $viewModel.email,
                            placeholder: "Email",
                        )
                        CustomTextField(
                            text: $viewModel.username,
                            placeholder: "Username",
                        )
                        CustomTextField(
                            text: $viewModel.password,
                            placeholder: "Password",
                            secure: true
                        )
                    }
                    .padding(.horizontal, 20)
                    SubmitButton(
                        title: "Get started",
                        isLoading: false,
                        action: {
                            viewModel.signUp(sessionManager: sessionManager)
                            showSheet = true
                        }
                    )
                    .sheet(isPresented: $showSheet){
                        VerifyEmailSheet(code: $code, isPresented: $showSheet, showResendCodeMessage: $showResendCodeMessage, resendCodeMessage: $resendCodeMessage, authUser: authUser, sessionManager: sessionManager, viewModel: viewModel)
                    }
                }
                .padding(.top, 30)
                .padding(.horizontal, 30)
                
                Spacer()
                
                // redirect to login
                VStack(spacing: 8) {
                    Button("Log in") {
                        sessionManager.showLogin()
                    }
                    .font(.body)
                    .foregroundColor(.white.opacity(0.8))
                }
                .padding(.bottom, 30)
            }
            .onChange(of: viewModel.verificationStatus, initial: false) { oldValue, newValue in
                if newValue == "Success" {
                    // TODO: change to operate in DispatchGroup?
                    viewModel.addUser(authUser: viewModel.authUser)
                    sessionManager.showHome(authUser: viewModel.authUser)
                }
            }
            .onChange(of: viewModel.errorMessage, initial: false) { _, newMessage in
                if let message = newMessage {
                    // Handle or display error
                    print("Error: \(message)")
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
    SignUpTest()
}
