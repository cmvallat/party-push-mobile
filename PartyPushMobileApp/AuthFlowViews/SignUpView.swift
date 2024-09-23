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
    @State private var showUsernamePopover: Bool = false

    var body: some View {
        NavigationView {
            VStack{
                
                Spacer()
                
                VStack{
                    Text("Party Push Sign Up")
                        .multilineTextAlignment(.center)
                        .font(.title)
                        .padding(.top, 100)
                        .padding([.leading,.trailing], 15)
                    
                    TextField("Email address", text: $email)
                        .textFieldStyle(.roundedBorder)
                        .padding([.leading,.trailing], 15)
                    
                    SecureField("Password", text: $password)
                        .textFieldStyle(.roundedBorder)
                        .padding([.leading,.trailing], 15)
                    
                    LabeledContent {
                        TextField("Username", text: $username)
                            .textFieldStyle(.roundedBorder)
                    } label: {
                        Button("", systemImage: "info.circle")
                        {
                            showUsernamePopover.toggle()
                        }
                        .tint(.black)
                        .popover(isPresented: $showUsernamePopover, attachmentAnchor: .point(.top), content: {
                            Text("This will be displayed as your screen name throughout the app.")
                                .presentationCompactAdaptation(.popover)
                                .padding([.leading, .trailing], 5)
                        })
                    }
                    .padding([.leading,.trailing], 15)
                    
                    Button(action: {
                        // try to sign in
                        authUser.email = email
                        authUser.password = password
                        authUser.username = username
                        let res = sessionManager.signUp(authUser: authUser)
                        // if we get "Success" back, it means we signed up AND logged in correctly
                        // otherwise, we will automatically go to VerifyCodeView
                        if(res == "Success")
                        {
                            sessionManager.showSession(authUser: authUser)
                        }
                        else
                        {
                            // Todo: handle failed sign up
                        }
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

// Todo: investigate whether we need this (I don't think we do)
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
