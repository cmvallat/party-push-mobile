//
//  PasswordResetPrompt.swift
//  Song_Requester
//
//  Created by Christian Vallat on 8/29/24.
//

import SwiftUI

struct PasswordResetPrompt: View {
    @EnvironmentObject var sessionManager: SessionManager
    
    let authUser: AuthUser
    @State var email = ""
    @State private var advanceToNextView: Int? = 0
    
    var body: some View {
            NavigationView{
                VStack {
                    Spacer()
                    VStack{
                        Text("Please enter the email connected to your account to send a password reset code:")
                            .multilineTextAlignment(.center)
                            .padding([.top], 100)
                            .padding([.leading,.trailing], 15)
                        
                        TextField("Email address", text: $email)
                            .textFieldStyle(.roundedBorder)
                            .padding([.leading,.trailing], 15)
                        
                        NavigationLink(destination: PasswordResetView(authUser: authUser),
                                       tag: 1, selection: $advanceToNextView){
                        }
                                       .navigationTitle("Send new code")
                                       .navigationBarHidden(true)
                                       .padding(.top, 5)
                        
                        Button(action:{
                            // update the email from the TextField to send the reset code to
                            authUser.email = email
                            var resetStatus = sessionManager.sendPasswordResetCode(authUser: authUser)
                            // if the code was successfully sent, advance to next view
                            if(resetStatus == "Success")
                            {
                                self.advanceToNextView = 1
                            }
                        })
                        {
                            Label("Send reset code", systemImage: "arrowshape.turn.up.forward.fill")
                                .tint(Color(red: 0, green: 0.65, blue: 0))
                        }
                        .padding(.top, 5)
                        .padding(.bottom, 100)
                    }
                    .glass(cornerRadius: 20.0)
                    
                    Spacer()
                }
                .padding()
                .background(Gradient(colors: [.blue, .pink]).opacity(0.2))
                .toolbarBackground(Color.black.opacity(0.2), for: .navigationBar)
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

#Preview {
    PasswordResetPrompt(authUser: AuthUser())
}
