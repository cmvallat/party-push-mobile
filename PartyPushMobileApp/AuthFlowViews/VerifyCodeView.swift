//
//  VerifyCodeView.swift
//  Song_Requester
//
//  Created by Christian Vallat on 8/3/24.
//

import SwiftUI
import Observation
import JWTDecode

struct VerifyCodeView: View {
    
    @EnvironmentObject var sessionManager: SessionManager
    let authUser: AuthUser
    @State var code = ""
    @State private var showResendCodeMessage = false
    @State private var resendCodeMessage: String = ""
    @StateObject var viewModel = ViewModel()

    var body: some View {
        NavigationStack
        {
            VStack
            {
                Spacer()
                
                VStack
                {
                    Text("Please enter the verification code from your email:")
                        .multilineTextAlignment(.center)
                        .padding([.top], 100)
                        .padding([.leading,.trailing], 15)
                    
                    TextField("Verification Code", text: $code)
                        .textFieldStyle(.roundedBorder)
                        .padding([.leading,.trailing], 15)
                    
                    Button(action:
                            {
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
                    })
                    {
                        Label("Verify", systemImage: "checkmark.seal.fill")
                            .tint(Color(red: 0, green: 0.65, blue: 0))
                    }
                    .padding([.top,.bottom], 5)
                    
                    Button(action:
                            {
                        // get message returned from the endpoint
                        resendCodeMessage = sessionManager.resendCode(authUser: authUser)
                        // if we are already displaying a resend code message, reset the display flag and show the animation again
                        if(showResendCodeMessage)
                        {
                            showResendCodeMessage = false
                        }
                        withAnimation(.easeInOut(duration: 1)) {
                            showResendCodeMessage.toggle()
                        }
                    })
                    {
                        Label("Resend code", systemImage: "envelope.fill")
                            .tint(Color(red: 0, green: 0, blue: 0.9))
                    }
                    
                    Text("\(resendCodeMessage)")
                        .multilineTextAlignment(.center)
                        .padding([.top], 10)
                        .padding([.leading,.trailing], 15)
                        .padding(.bottom, 10)
                    // green text for success, red for failure
                        .foregroundColor(resendCodeMessage == "Success! A new verification code has been sent to the email address \(authUser.email)" ? Color(red: 0, green: 0.65, blue: 0) : Color(red: 0.9, green: 0, blue: 0))
                        .opacity(showResendCodeMessage ? 1 : 0)
                }
                .glass(cornerRadius: 20.0)
                
                Spacer()
            }
            .padding([.leading, .trailing], 20)
            .background(Gradient(colors: [.blue, .pink]).opacity(0.2))
            .toolbarBackground(.clear, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbar {
                ToolbarItemGroup(placement: .navigationBarTrailing) {
                    Button("Login") 
                    {
                        // make them login again
                        // and clear the data so we don't have a mix-up
                        authUser.email = ""
                        authUser.password = ""
                        authUser.username = ""
                        sessionManager.showLogin(authUser: authUser)
                    }
                    .tint(Color(red: 0, green: 0, blue: 0.9))
                    Button("Sign up") 
                    {
                        // make them sign up again
                        // and clear the data so we don't have a mix-up
                        authUser.email = ""
                        authUser.password = ""
                        authUser.username = ""
                        sessionManager.showSignUp()
                    }
                    .tint(Color(red: 0, green: 0, blue: 0.9))
                }
            }
        }
    }
}

extension View {
    func glass(cornerRadius: CGFloat, fill: Color = .white, opacity: CGFloat = 0.5, shadowRadius: CGFloat = 10.0) -> some View {
        modifier(StyleHelpers.GlassModifier(cornerRadius: cornerRadius, fill: fill, opacity: opacity, shadowRadius: shadowRadius))
    }
}

extension VerifyCodeView{
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
    VerifyCodeView(authUser: AuthUser())
}
