//
//  PasswordResetView.swift
//  Song_Requester
//
//  Created by Christian Vallat on 8/28/24.
//

import SwiftUI

struct PasswordResetView: View {
    
    @EnvironmentObject var sessionManager: SessionManager
    
    let authUser: AuthUser
    @State var code = ""
    @State var password = ""
    @State private var showVerificationPopover: Bool = false
    @State private var showPasswordPopover: Bool = false
    @State private var showResetPasswordMessage: Bool = false
    @State private var resetPasswordMessage: String = ""
    
    var body: some View {
        NavigationStack{
            VStack {
                Spacer()
                
                VStack{
                    Text("Please enter the verification code sent to your email and your desired new password:")
                        .multilineTextAlignment(.center)
                        .padding([.top], 100)
                        .padding([.leading,.trailing], 15)
                    
                    LabeledContent {
                        TextField("Verification Code", text: $code)
                            .textFieldStyle(.roundedBorder)
                    } label: {
                        Button("", systemImage: "info.circle")
                        {
                            showVerificationPopover.toggle()
                        }
                        .tint(.black)
                        .popover(isPresented: $showVerificationPopover, attachmentAnchor: .point(.topTrailing), content: {
                            Text("The verification code sent to your email to reset your password.")
                                .presentationCompactAdaptation(.popover)
                                .padding([.leading, .trailing], 5)
                        })
                    }
                    .padding([.leading,.trailing], 15)
                    
                    LabeledContent {
                        SecureField("New Password", text: $password)
                            .textFieldStyle(.roundedBorder)
                    } label: {
                        Button("", systemImage: "info.circle")
                        {
                            showPasswordPopover.toggle()
                        }
                        .tint(.black)
                        .popover(isPresented: $showPasswordPopover, attachmentAnchor: .point(.bottomTrailing), content: {
                            Text("This will be the new password associated with your account.")
                                .presentationCompactAdaptation(.popover)
                                .padding([.leading, .trailing], 5)
                        })
                    }
                    .padding([.leading,.trailing], 15)
                    
                    Button(action:{
                        resetPasswordMessage = sessionManager.resetPassword(authUser: authUser, newPassword: password, confirmationCode: code)
                        if(showResetPasswordMessage)
                        {
                            showResetPasswordMessage = false
                        }
                        withAnimation(.easeInOut(duration: 1)) {
                            showResetPasswordMessage.toggle()
                        }
                    })
                    {
                        Label("Reset password", systemImage: "arrow.clockwise.circle.fill")
                            .tint(Color(red: 0, green: 0, blue: 0.9))
                    }
                    .padding(.top, 5)
                    .padding(.bottom, 20)
                    
                    Text("\(resetPasswordMessage)")
                        .multilineTextAlignment(.center)
                        .padding([.top], 10)
                        .padding([.leading,.trailing], 15)
                        .padding(.bottom, 10)
                    // green text for success, red for failure
                        .foregroundColor(resetPasswordMessage == "We've correctly reset your password for email \(authUser.email)." ? Color(red: 0, green: 0.65, blue: 0) : Color(red: 0.9, green: 0, blue: 0))
                        .opacity(showResetPasswordMessage ? 1 : 0)
                        .padding(.bottom, 50)
                }
                .glass(cornerRadius: 20.0)
                
                Spacer()
            }
            .padding()
            .background(Gradient(colors: [.blue, .pink]).opacity(0.2))
//            .toolbarBackground(Color.black.opacity(0.2), for: .navigationBar)
//            .toolbarBackground(.visible, for: .navigationBar)
//            .toolbar {
//                ToolbarItemGroup(placement: .navigationBarTrailing) {
//                    Button("Login") {
//                        sessionManager.showLogin(authUser: authUser)
//                    }
//                    .tint(Color(red: 0, green: 0, blue: 0.9))
//                    Button("Sign up") {
//                        sessionManager.showSignUp()
//                    }
//                    .tint(Color(red: 0, green: 0, blue: 0.9))
//                }
//            }
        }
    }
}

#Preview {
    PasswordResetView(authUser: AuthUser())
}
