//
//  LoginPage.swift
//  Song_Requester
//
//  Created by Christian Vallat on 8/3/24.
//

import SwiftUI

struct LoginPage: View {
    @EnvironmentObject var sessionManager: SessionManager
    @StateObject private var viewModel = LoginPageViewModel()
    
    var body: some View {
        VStack {
            Section(header: Text("Log In to My Account").font(.largeTitle)) {
                Divider()
                    .padding(.vertical)
                
                TextField("Email", text: $viewModel.email)
                  .textFieldStyle(.roundedBorder)
                  .font(.title)
                  .frame(width: 300)
                  .autocapitalization(.none)
                
                SecureField("Password", text: $viewModel.password)
                  .textFieldStyle(.roundedBorder)
                  .font(.title)
                  .frame(width: 300)
                  .autocapitalization(.none)
                
                Button("Log In") {
                    viewModel.login(sessionManager: sessionManager)
                }
                  
                Button("Forgot Password?") {
                    let user = AuthUser()
                    user.username = viewModel.email
                    sessionManager.showPasswordReset(authUser: user)
                }
                  .foregroundColor(.blue)
                  .frame(maxWidth: 300, maxHeight: 45)
                  .clipShape(RoundedRectangle(cornerRadius: 5))
                  .overlay(
                      RoundedRectangle(cornerRadius: 6)
                          .stroke(.blue, lineWidth: 2))
                
                Button("Sign Up") {
                    sessionManager.showSignUp()
                }
                  .foregroundColor(.blue)
                  .frame(maxWidth: 300, maxHeight: 45)
                  .clipShape(RoundedRectangle(cornerRadius: 5))
                  .overlay(
                      RoundedRectangle(cornerRadius: 6)
                          .stroke(.blue, lineWidth: 2))
                
                if let error = viewModel.errorMessage {
                    Text(error)
                        .foregroundColor(.red)
                        .frame(width: 300)
                }
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

//#Preview {
//    LoginPage()
//}
