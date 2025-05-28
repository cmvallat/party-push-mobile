//
//  LoginPageViewModel.swift
//  PartyPushMobileApp
//
//  Created by Christian Vallat on 5/16/25.
//

import Foundation

final class LoginPageViewModel: ObservableObject {
    @Published var username = ""
    @Published var password = ""
    @Published var errorMessage: String?

    func login(sessionManager: SessionManager) {
        guard !username.isEmpty, !password.isEmpty else {
            errorMessage = "Please fill out all fields."
            return
        }
        errorMessage = nil
        
        sessionManager.login(username: username, password: password) { result in
            switch result {
            case .success(let authUser):
                sessionManager.showSession(authUser: authUser)
            case .failure(let error):
                DispatchQueue.main.async {
                    self.errorMessage = error.localizedDescription
                }
            }
        }
    }
}
