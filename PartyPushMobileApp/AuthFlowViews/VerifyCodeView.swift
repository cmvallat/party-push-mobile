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
        NavigationStack{
            VStack{
                Spacer()
                VStack{
                    Text("Looks like you haven't verified your account yet. Please enter the verification code from your email below:")
                        .multilineTextAlignment(.center)
                        .padding([.top], 100)
                        .padding([.leading,.trailing], 15)
                    
                    TextField("Verification Code", text: $code)
                        .textFieldStyle(.roundedBorder)
                        .padding([.leading,.trailing], 15)
                    
                    Button(action:
                            {
                        let response = sessionManager.verifyEmail(authUser: authUser, confirmationCode: code)
                        // if email is verified, add the user to the db and
                        // move to the user management page
                        if(response == "Success")
                        {
                                viewModel.addUser(authUser: authUser)
                            sessionManager.showSession(authUser: authUser)
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
            setCognitoUsername(authUser: authUser)
            
            let path = "https://dlnhzdvr74.execute-api.us-east-1.amazonaws.com/Test/"
            var request = URLRequest(url: URL(string: path)!)
            request.httpMethod = "POST"
            
            let userToAdd = User(username: authUser.username, email: authUser.email, cognito_username: authUser.cognito_username)
            if let userData = try? JSONEncoder().encode(userToAdd){
                request.httpBody = userData
            }
            
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
        
        func setCognitoUsername(authUser: AuthUser)
        {
            // check if the email on the idToken matches
            // the email we assigned at login/sign up
            let accessToken = try? decode(jwt: authUser.accessToken)
            let idToken = try? decode(jwt: authUser.idToken)
            let cognito_username_from_accessToken = accessToken?["username"].string ?? "defaultAccessToken"
            let cognito_username_from_idToken = idToken?["cognito:username"].string ?? "defaultIdToken"
            
            if(cognito_username_from_accessToken != cognito_username_from_idToken)
            {
                // if the cognito username of the tokens don't match,
                // then we have a problem and shouldn't be accessing this API
                // Todo: handle here
            }
            else
            {
                // if they do match, we're good to call the API
                // for the requested user's objects
                
                // either cognito_username variable works here
                // since they would be the same in this check
                authUser.cognito_username = UUID(uuidString: cognito_username_from_accessToken) ?? UUID()
            }
        }
        
    }
}
    
#Preview {
    VerifyCodeView(authUser: AuthUser())
}
