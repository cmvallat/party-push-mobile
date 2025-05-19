//
//  LoginPageViewModel.swift
//  PartyPushMobileApp
//
//  Created by Christian Vallat on 5/16/25.
//

import Foundation

final class LoginPageViewModel: ObservableObject {
    @Published var email = ""
    @Published var password = ""
    @Published var errorMessage: String?

    func login(sessionManager: SessionManager) {
        guard !email.isEmpty, !password.isEmpty else {
            errorMessage = "Please fill out all fields."
            return
        }
        errorMessage = nil
        
        sessionManager.login(email: email, password: password) { result in
            switch result {
            case .success(let authUser): // make this var to mutate
                print("success clause: " + authUser.cognito_username.uuidString)
                DispatchQueue.main.async {
                    fetchUsername(cognitoUsername: authUser.cognito_username) { un in
                        if let username = un {
                            authUser.username = username
                            sessionManager.showSession(authUser: authUser)
                        } else {
                            print("User not found.")
                        }
                    }
                }
                
                
                
//                DispatchQueue.main.async {
//                    fetchUsername(cognito_username: authUser.cognito_username) { un in
//                        authUser.username = un
//                        sessionManager.showSession(authUser: authUser)
//                    }
//                }
            case .failure(let error):
                DispatchQueue.main.async {
                    self.errorMessage = error.localizedDescription
                }
            }
        }
        
        func fetchUsername(cognitoUsername: UUID, completion: @escaping (String?) -> Void) {
            print("FU: " + cognitoUsername.uuidString)
            APIService.getUser(cognito_username: cognitoUsername) { user in
                DispatchQueue.main.async {
                    if let user = user {
                        completion(user.username)
                    } else {
                        completion(nil)
                    }
                }
            }
        }

        
//        sessionManager.login(email: email, password: password) { result in
//            switch result {
//            case .success(let authUser):
//                sessionManager.showSession(authUser: authUser)
//            case .failure(let error):
//                self.errorMessage = error.localizedDescription
//            }
//        }
    }
}
