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
    @State private var showResendCodeMessage = false
    @State private var resendCodeMessage: String = ""
    @StateObject var viewModel = SignUpPageViewModel()
    
    var body: some View {
        ZStack {
            VStack {
                Section(header: Text("Party Push Sign Up").font(.largeTitle)) {
                    Divider()
                        .padding(.vertical)
                    
                    TextField("Email", text: $viewModel.email)
                        .textFieldStyle(.roundedBorder)
                        .font(.title)
                        .frame(width: 300)
                        .autocapitalization(.none)
                    
                    TextField("Username", text: $viewModel.username)
                        .textFieldStyle(.roundedBorder)
                        .font(.title)
                        .frame(width: 300)
                        .autocapitalization(.none)
                    
                    SecureField("Password", text: $viewModel.password)
                        .textFieldStyle(.roundedBorder)
                        .font(.title)
                        .frame(width: 300)
                        .autocapitalization(.none)
                    
                    Button("Get Started") {
                        // try to sign in
                        viewModel.signUp(sessionManager: sessionManager)
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: 300, maxHeight: 45)
                    .font(.headline)
                    .background(.blue)
                    .clipShape(RoundedRectangle(cornerRadius: 5))
                    .alert(
                        "Please enter the verification code from your email:",
                        isPresented: $viewModel.showModal
                    ) {
                        TextField(
                            "Code",
                            text: $code
                        )
                        Button("Verify") {
                            // verification status is a published variable and will automatically handle changes
                            viewModel.verifyEmail(sessionManager: sessionManager, authUser: viewModel.authUser, confirmationCode: code)
                        }
                        Button("Resend Code") {
                            // get message returned from the endpoint
                            resendCodeMessage = sessionManager.resendCode(authUser: viewModel.authUser)
//                            // if we are already displaying a resend code message, reset the display flag and show the animation again
                            if(showResendCodeMessage)
                            {
                                showResendCodeMessage = false
                            }
                            withAnimation(.easeInOut(duration: 5)) {
                                showResendCodeMessage.toggle()
                            }
                        }
                    }
                    
                    if let error = viewModel.errorMessage {
                        Text(error)
                            .foregroundColor(.red)
                            .frame(width: 300)
                    }
                    
                    Button("Already have an account? Log in") {
                        sessionManager.showLogin()
                    }
                    .foregroundColor(.blue)
                    .frame(maxWidth: 300, maxHeight: 45)
                    .clipShape(RoundedRectangle(cornerRadius: 5))
                    .overlay(
                        RoundedRectangle(cornerRadius: 6)
                            .stroke(.blue, lineWidth: 2)
                    )
                    
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
