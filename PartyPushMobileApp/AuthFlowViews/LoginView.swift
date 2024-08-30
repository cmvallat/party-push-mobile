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
    @State private var showEmailPopover: Bool = false
    @State private var showPasswordPopover: Bool = false
    @State private var showForgotPasswordMessage: Bool = false
    @State private var forgotPasswordMessage: String = ""
    
    var body: some View {
        NavigationView {
            VStack {
                Spacer()
                
                VStack{
                    Text("Welcome to PartyPush! Please log in below:")
                        .multilineTextAlignment(.center)
                        .padding([.top], 100)
                        .padding([.leading,.trailing], 15)
                    
                    LabeledContent {
                        TextField("Email address", text: $email)
                            .textFieldStyle(.roundedBorder)
                    } label: {
                        Button("", systemImage: "info.circle")
                        {
                            showEmailPopover.toggle()
                        }
                        .tint(.black)
                        .popover(isPresented: $showEmailPopover, attachmentAnchor: .point(.topTrailing), content: {
                            Text("The email address associated with your account.")
                                .presentationCompactAdaptation(.popover)
                                .padding([.leading, .trailing], 5)
                        })
                    }
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
                            Text("The password associated with your account.")
                                .presentationCompactAdaptation(.popover)
                                .padding([.leading, .trailing], 5)
                        })
                    }
                    .padding([.leading,.trailing], 15)
                    
                    Button(action:{
                        authUser.email = email
                        authUser.password = password
                        sessionManager.login(authUser: authUser)
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
                .tint(Color(red: 0, green: 0, blue: 0.9))
            }
            .padding()
            .background(Gradient(colors: [.blue, .pink]).opacity(0.2))
        }
    }
}

#Preview {
    LoginView(authUser: AuthUser())
}
