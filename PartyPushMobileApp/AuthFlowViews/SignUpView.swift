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
    @State var phone = ""
    @State private var showPhonePopover: Bool = false
    @State private var showEmailPopover: Bool = false
    @State private var showVerificationView = false
    @State private var isSigningUp = false

    var body: some View {
        NavigationView {
            VStack{
                Spacer()
                
                VStack{
                    Text("Please sign up below (we do NOT collect any data):")
                        .multilineTextAlignment(.center)
                        .padding(.top, 100)
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
                            Text("The email address to sign up with. A verification code will be sent to this email.")
                                .presentationCompactAdaptation(.popover)
                                .padding([.leading, .trailing], 5)
                        })
                    }
                    .padding([.leading,.trailing], 15)
                    
                    TextField("Username", text: $username)
                        .textFieldStyle(.roundedBorder)
                        .padding([.leading,.trailing], 15)
                    
                    SecureField("Password", text: $password)
                        .textFieldStyle(.roundedBorder)
                        .padding([.leading,.trailing], 15)
                    
                    LabeledContent {
                        TextField("Phone number", text: $phone)
                            .textFieldStyle(.roundedBorder)
                    } label: {
                        Button("", systemImage: "info.circle")
                        {
                            showPhonePopover.toggle()
                        }
                        .tint(.black)
                        .popover(isPresented: $showPhonePopover, attachmentAnchor: .point(.top), content: {
                            Text("We will use this to send you text alerts from guests throughout the party. We will NEVER store or sell this data.")
                                .presentationCompactAdaptation(.popover)
                                .padding([.leading, .trailing], 5)
                        })
                    }
                    .padding([.leading,.trailing], 15)
                    
                    // code for if we want to implement NavLink instead of button
//                    NavigationLink(destination: VerifyCodeView(), label: {
//                        Label("Submit", systemImage: "arrowshape.turn.up.forward.fill")
//                            .tint(Color(red: 0, green: 0.65, blue: 0))
//                    })
//                    .navigationTitle("Sign up")
//                    .navigationBarHidden(true)
//                    .padding(.bottom, 100)
                    
                    Button(action: {
                        authUser.email = email
                        authUser.password = password
                        sessionManager.signUp(authUser: authUser)
                    }){
                        Label("Submit", systemImage: "arrowshape.turn.up.forward.fill")
                            .tint(Color(red: 0, green: 0.65, blue: 0))
                    }
                    .padding(.top, 5)
                    .padding(.bottom, 75)
                }
                .glass(cornerRadius: 20.0)
                
                Spacer()
                Button("Already have an account? Login here", action: {
                    sessionManager.showLogin(authUser: authUser)
                })
                .tint(Color(red: 0, green: 0, blue: 0.9))
            }
            .padding()
            .background(Gradient(colors: [.blue, .pink]).opacity(0.2))
        }
    }
}

extension Color {
    init(hex: Int, opacity: Double = 1) {
        self.init(
            .sRGB,
            red: Double((hex >> 16) & 0xff) / 255,
            green: Double((hex >> 08) & 0xff) / 255,
            blue: Double((hex >> 00) & 0xff) / 255,
            opacity: opacity
        )
    }
}

#Preview {
    SignUpView()
}
