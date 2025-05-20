//
//  SignUpPage.swift
//  Song_Requester
//
//  Created by Christian Vallat on 8/3/24.
//

import SwiftUI

struct SignUpPage: View {
    
    @EnvironmentObject var sessionManager: SessionManager
    @State var authUser = AuthUser()
    @State var code = ""
    @State private var showSheet = false
    @State private var showResendCodeMessage = false
    @State private var resendCodeMessage: String = ""
    @StateObject var viewModel = SignUpPageViewModel()
    
    var body: some View {
        ZStack {
            VStack {
                Section(header: Text("Party Push Sign Up").font(.largeTitle)) {
                    Divider()
                        .padding(.vertical)
                    
                    AuthFlowTextField(
                        label: "Email Address",
                        value: $viewModel.email,
                        secure: false
                    )
                    AuthFlowTextField(
                        label: "Username",
                        value: $viewModel.username,
                        secure: false
                    )
                    AuthFlowTextField(
                        label: "Password",
                        value: $viewModel.password,
                        secure: true
                    )
                    AuthFlowButton(
                        label: "Get Started",
                        isPrimary: false,
                        color: .blue,
                        onClick: {
                            // viewModel.signUp(sessionManager: sessionManager)
                            showSheet = true
                        }
                    )
                    .sheet(
                        //"Please enter the verification code from your email:",
                        isPresented: $showSheet
                    ) {
                        AuthFlowTextField(
                            label: "Code",
                            value: $code,
                            secure: false
                        )
                        AuthFlowButton(
                            label: "Verify",
                            isPrimary: true,
                            color: .blue,
                            onClick: {
                                viewModel.verifyEmail(sessionManager: sessionManager, authUser: viewModel.authUser, confirmationCode: code)
                            }
                        )
                        Button("Resend Code") {
                            // get message returned from the endpoint
                            resendCodeMessage = sessionManager.resendCode(authUser: viewModel.authUser)
                            // if we are already displaying a resend code message, reset the display flag and show the animation again
                            if(showResendCodeMessage)
                            {
                                showResendCodeMessage = false
                            }
                            withAnimation(.easeInOut(duration: 5)) {
                                showResendCodeMessage.toggle()
                            }
                        }.alert(
                            "Success! A new verification code has been sent to the email address",
                            isPresented: $showResendCodeMessage
                        ) {
                            Button ("Ok") {
                                showResendCodeMessage = false
                            }
                        }
                        
                    }
                    AuthFlowButton(
                        label: "Already have an account? Log in",
                        isPrimary: false,
                        color: .blue,
                        onClick: {
                            sessionManager.showLogin()
                        }
                    )
                    if let error = viewModel.errorMessage {
                        Text(error)
                            .foregroundColor(.red)
                            .frame(width: 300)
                    }
                }
            }
            .onChange(of: viewModel.verificationStatus, initial: false) { oldValue, newValue in
                if newValue == "Success" {
                    viewModel.addUser(authUser: viewModel.authUser)
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
            .background(Color(uiColor: UIColor.systemGray6))
        }
    }
}


#Preview {
    SignUpPage()
}
