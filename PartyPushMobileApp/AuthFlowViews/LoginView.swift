//
//  LoginView.swift
//  Song_Requester
//
//  Created by Christian Vallat on 8/3/24.
//

import SwiftUI

struct LoginView: View {
    
    @EnvironmentObject var sessionManager: SessionManager
    
    let authUser: AuthUser
    @State var email = ""
    @State var password = ""
    @State private var showPasswordPopover: Bool = false
    
    var body: some View {
        NavigationView {
            VStack {
                Spacer()
                
                VStack{
                    Text("Party Push Login")
                        .multilineTextAlignment(.center)
                        .font(.title)
                        .padding([.top], 100)
                        .padding([.leading,.trailing], 15)
                    
                    TextField("Email address", text: $email)
                        .textFieldStyle(.roundedBorder)
                        .padding([.leading,.trailing], 15)
                    
                    LabeledContent {
                        SecureField("Password", text: $password)
                            .textFieldStyle(.roundedBorder)
                    } label: {
                        Button("", systemImage: "info.circle")
                        {
                            showPasswordPopover.toggle()
                        }
                        .tint(.black)
                        .popover(isPresented: $showPasswordPopover, attachmentAnchor: .point(.bottomTrailing), content: {
                            Text("We will never store your password in order to protect your data.")
                                .presentationCompactAdaptation(.popover)
                                .padding([.leading, .trailing], 5)
                        })
                    }
                    .padding([.leading,.trailing], 15)
                    
                    Button(action:{
                        // try to login
                        authUser.email = email
                        authUser.password = password
                        let res = sessionManager.login(authUser: authUser)
                        if(res == "Success")
                        {
                            sessionManager.showSession(authUser: authUser)
                        }
                        else
                        {
                            // Todo: handle failed login
                        }
                    })
                    {
                        Label("Login", systemImage: "checkmark.seal.fill")
                            .tint(Color(red: 0, green: 0.65, blue: 0))
                    }
                    .padding([.top,.bottom], 5)

                    Button(action:{
                        // show the password reset view, logic will be handled there
                            sessionManager.showPasswordReset(authUser: authUser)
                    })
                    {
                        Label("Forgot password", systemImage: "envelope.fill")
                            .tint(Color(red: 0, green: 0, blue: 0.9))
                    }
                    .padding(.bottom, 75)
                    
                }
                .glass(cornerRadius: 20.0)
                
                Spacer()
                
                Button("Don't have an account? Sign up", action: {
                    sessionManager.showSignUp()
                })
                .tint(Color(red: 0, green: 0.5, blue: 0.9))
            }
            .padding()
            .background(Gradient(colors: [.blue, .pink]).opacity(0.2))
        }
    }
}


#Preview {
    LoginView(authUser: AuthUser())
}
