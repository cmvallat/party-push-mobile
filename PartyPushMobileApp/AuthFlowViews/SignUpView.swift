//
//  LoginView.swift
//  Song_Requester
//
//  Created by Christian Vallat on 8/3/24.
//

import SwiftUI

struct SignUpView: View {
    
    @EnvironmentObject var sessionManager: SessionManager
    @State var authUser = AuthUser()
    @State var email = ""
    @State var username = ""
    @State var password = ""
    @State var code = ""
    @State var showModal: Bool = false
    @State private var showUsernamePopover: Bool = false
    @State private var showResendCodeMessage = false
    @State private var resendCodeMessage: String = ""
    @StateObject var viewModel = ViewModel()
    
    var body: some View {
        ZStack {
            VStack {
                Section(header: Text("Party Push Sign Up").font(.largeTitle)) {
                    Divider()
                        .padding(.vertical)
                    AuthFlowTextField(
                        label: "Email Address",
                        value: $email,
                        secure: false
                    )
                    AuthFlowTextField(
                        label: "Username",
                        value: $username,
                        secure: false
                    )
                    AuthFlowTextField(
                        label: "Password",
                        value: $password,
                        secure: true
                    )
                    AuthFlowButton(
                        label: "Get Started",
                        isPrimary: false,
                        color: .blue,
                        onClick: {
                            // try to sign in
                            authUser.email = email
                            authUser.password = password
                            authUser.username = username
                            let res = sessionManager.signUp(authUser: authUser)
                            // if we get "Success" back, it means we signed up AND logged in correctly
                            // otherwise, we will automatically go to VerifyCodeView
                            if(res == "Success")
                            {
                                // sessionManager.showSession(authUser: authUser)
                                withAnimation {
                                    showModal = true
                                }
                            }
                            else
                            {
                                // Todo: handle failed sign up
                                withAnimation {
                                    showModal = true
                                }
                            }
                        }
                    )
                    .sheet(
                        //"Please enter the verification code from your email:",
                        isPresented: $showModal
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
                                let response = sessionManager.verifyEmail(authUser: authUser, confirmationCode: code)
                                if(response == "Success")
                                {
                                    // if email is verified, add the user to the db and move to the user management page
                                    viewModel.addUser(authUser: authUser)
                                    sessionManager.showSession(authUser: authUser)
                                }
                                else
                                {
                                   // Todo: handle failed verification
                                }
                            }
                        )
                        Button("Resend Code") {
                            // get message returned from the endpoint
                            resendCodeMessage = sessionManager.resendCode(authUser: authUser)
//                            // if we are already displaying a resend code message, reset the display flag and show the animation again
//                            if(showResendCodeMessage)
//                            {
//                                showResendCodeMessage = false
//                            }
                            withAnimation() {
                                showResendCodeMessage = true
                            }
//                            withAnimation(.easeInOut(duration: 1)) {
//                                showResendCodeMessage.toggle()
//                            }
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
                            sessionManager.showLogin(authUser: authUser)
                        }
                    )
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

extension SignUpView {
    class ViewModel: ObservableObject{
        @Published var response = ""
        
        func addUser(authUser: AuthUser)
        {
            let authorizeUser = authorizeCall(authUser: authUser)
            // Todo: store url somewhere?
            let path = "https://dlnhzdvr74.execute-api.us-east-1.amazonaws.com/Test/"
            // Todo: don't use force unwrap
            var request = URLRequest(url: URL(string: path)!)
            request.httpMethod = "POST"
            
            let userToAdd = User(
                username: authorizeUser.username,
                email: authorizeUser.email,
                cognito_username: authorizeUser.cognito_username)
            
            if let userData = try? JSONEncoder().encode(userToAdd){
                request.httpBody = userData
            }
            
            // Todo: standardize error handling here and in other API calls
            let task = URLSession.shared.dataTask(with: request){
                if let error = $2
                {
                    print(error)
                }
                else if let data = $0
                {
                    let apiResponse = try? JSONDecoder().decode(ApiResponseFormat.self, from: data)
                    DispatchQueue.main.async{ [weak self] in
                        self?.response = apiResponse?.body ?? "failed to decode"
                    }
                }
                else
                {
                    self.response = "Something went wrong in addUser call"
                }
                print("response: " + self.response)
            }
            task.resume()
        }
    }
}

#Preview {
    SignUpView()
}
