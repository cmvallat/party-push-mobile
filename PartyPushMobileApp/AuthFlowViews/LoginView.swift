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
        VStack {
            Section(header: Text("Log In to My Account").font(.largeTitle)) {
                Divider()
                    .padding(.vertical)
                TextField(
                    "Email Address",
                    text: $email
                )
                  .textFieldStyle(.roundedBorder)
                  .font(.title)
                  .frame(width: 300)
                  .autocapitalization(.none)
                SecureField(
                    "Password",
                    text: $password
                )
                  .textFieldStyle(.roundedBorder)
                  .font(.title)
                  .frame(width: 300)
                  .autocapitalization(.none)
                Button("Log In") {
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
                }
//                  .foregroundColor(.white)
//                  .frame(maxWidth: 300, maxHeight: 45)
//                  .font(.headline)
//                  .background(.blue)
//                  .clipShape(RoundedRectangle(cornerRadius: 5))
                  
                Button("Forgot Password?") {
                    sessionManager.showPasswordReset(authUser: authUser)
                }
                  .foregroundColor(.blue)
                  .frame(maxWidth: 300, maxHeight: 45)
                  .clipShape(RoundedRectangle(cornerRadius: 5))
                  .overlay(
                      RoundedRectangle(cornerRadius: 6)
                          .stroke(.blue, lineWidth: 2)
                  )
                Button("Sign Up") {
                    sessionManager.showSignUp()
                }
                  .foregroundColor(.blue)
                  .frame(maxWidth: 300, maxHeight: 45)
                  .clipShape(RoundedRectangle(cornerRadius: 5))
                  .overlay(
                      RoundedRectangle(cornerRadius: 6)
                          .stroke(.blue, lineWidth: 2)
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


#Preview {
    LoginView(authUser: AuthUser())
}
