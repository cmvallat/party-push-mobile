//
//  SignUpPageViewModel.swift
//  PartyPushMobileApp
//
//  Created by Christian Vallat on 5/16/25.
//

import Foundation

final class SignUpPageViewModel: ObservableObject {
    @Published var username = ""
    @Published var password = ""
    @Published var email = ""
    @Published var errorMessage: String?
    @Published var showModal: Bool = false
    @Published var verificationStatus: String? = nil
    @Published var authUser = AuthUser()

    func signUp(sessionManager: SessionManager) {
        guard !username.isEmpty, !password.isEmpty, !email.isEmpty else {
            errorMessage = "Please fill out all fields"
            return
        }
        
        errorMessage = nil
        sessionManager.signUp(email: email, password: password, username: username) { result in
            switch result {
            case .success(let returnedAuthUser):
                // set authUser so when we prompt for verify email, we have updated info
                DispatchQueue.main.async {
                    self.authUser = returnedAuthUser
                    self.showModal = true
                }
            case .failure(let error):
                DispatchQueue.main.async {
                    self.errorMessage = error.localizedDescription
                }
            }
        }
    }

    func verifyEmail(sessionManager: SessionManager, authUser: AuthUser, confirmationCode: String) {
        sessionManager.verifyEmail(authUser: authUser, confirmationCode: confirmationCode) { result in
            switch result {
            case .success(let returnedAuthUser):
                DispatchQueue.main.async {
                    self.authUser = returnedAuthUser
                    self.verificationStatus = "Success"
                }
            case .failure(let responseString):
                DispatchQueue.main.async {
                    self.errorMessage = responseString.localizedDescription
                }
            }
        }
    }
    
    func addUser(authUser: AuthUser)
    {
        APIService.addUser(authUser: authUser) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success:
                    print(authUser.username + " successfully added to database")
                case .failure(let error):
                    self?.errorMessage = error.localizedDescription
                }
            }
        }
        

    }
}
