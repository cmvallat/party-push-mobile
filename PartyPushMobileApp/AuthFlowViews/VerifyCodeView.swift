//
//  VerifyCodeView.swift
//  Song_Requester
//
//  Created by Christian Vallat on 8/3/24.
//

import SwiftUI
import Observation

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
                        if(response == "Success")
                        {
                            viewModel.addUser()
                            sessionManager.login(authUser: authUser)
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
                    
                    // Todo: decide on/play around with button styles
                    
                    //                Button("Back to sign up", action:
                    //                        {
                    //                    sessionManager.showSignUp()
                    //                })
                    //                .foregroundColor(.white)
                    //                .frame(minWidth: 100, maxWidth: 200, minHeight: 44)
                    //                .background(Color(red: 0, green: 0, blue: 0.9))
                    //                .padding([.leading,.trailing], 15)
                    //                .padding([.top], 5)
                    //                .padding([.bottom], 50)
                    
//                    Button(action:
//                            {
//                        sessionManager.showSignUp()
//                    })
//                    {
//                        Label("Back to sign up", systemImage: "arrow.backward.circle.fill")
//                        
//                            .tint(.black)
//                    }
//                    .padding(.bottom, 5)
//                    
//                    Button(action:
//                            {
//                        sessionManager.showLogin(authUser: authUser)
//                    })
//                    {
//                        Label("Back to login", systemImage: "arrow.backward.circle.fill")
//                            .tint(.black)
//                    }
//                    .padding(.bottom, 50)
                    
                }
                .glass(cornerRadius: 20.0)
                
                Spacer()
            }
            .padding([.leading, .trailing], 20)
            .background(Gradient(colors: [.blue, .pink]).opacity(0.2))
            .toolbarBackground(Color.gray.opacity(0.3), for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbar {
                ToolbarItemGroup(placement: .navigationBarTrailing) {
                    Button("Login") {
                        sessionManager.showLogin(authUser: authUser)
                    }
                    .tint(Color(red: 0, green: 0, blue: 0.9))
                    Button("Sign up") {
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
        @Published var text = ""
        @Published var response = ""
        
        func addUser(){
            let path = "https://dlnhzdvr74.execute-api.us-east-1.amazonaws.com/Test/"
            var request = URLRequest(url: URL(string: path)!)
            request.httpMethod = "POST"
            
            // Todo: pass in data from AuthUser
            let movie = Movie(username: "pchoi", password: "philtest", phone_number: "567")
            if let movieData = try? JSONEncoder().encode(movie){
                request.httpBody = movieData
            }
            
            let task = URLSession.shared.dataTask(with: request){
                if let error = $2{
                    print(error)
                } else if let data = $0
                {
                    let movies = try? JSONDecoder().decode(ApiResponseFormat.self, from: data)
                    print(movies?.body)
                    DispatchQueue.main.async{ [weak self] in
                        self?.response = movies?.body ?? "failed to decode"
                        self?.text.removeAll()
                    }
                }
                else
                {
                    print("failed")
                }
            }
            task.resume()
        }
    }
}
    
#Preview {
    VerifyCodeView(authUser: AuthUser())
}
