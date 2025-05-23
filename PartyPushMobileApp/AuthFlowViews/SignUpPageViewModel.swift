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
    @Published var response = ""
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
                    self.authUser.username = returnedAuthUser.username
                    self.authUser.email = returnedAuthUser.email
                    self.authUser.password = returnedAuthUser.password
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
            case .success:
                DispatchQueue.main.async {
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
        let authorizeUser = authorizeCall(authUser: authUser)
        // Todo: store url somewhere?
        let path = "https://dlnhzdvr74.execute-api.us-east-1.amazonaws.com/Test/"
        
        // Todo: don't use force unwrap
        var request = URLRequest(url: URL(string: path)!)
        request.httpMethod = "POST"
        
        let userToAdd = User(
            username: authorizeUser.username,
            email: authorizeUser.email)
        
        if let userData = try? JSONEncoder().encode(userToAdd){
            request.httpBody = userData
        }
        
        // Todo: standardize error handling here and in other API calls
        let task = URLSession.shared.dataTask(with: request){
            if let error = $2
            {
                print(error)
            }
            else if let data = $0
            {
                let apiResponse = try? JSONDecoder().decode(ApiResponseFormat.self, from: data)
                DispatchQueue.main.async{ [weak self] in
                    self?.response = apiResponse?.body ?? "failed to decode"
                }
            }
            else
            {
                self.response = "Something went wrong in addUser call"
            }
            print("response: " + self.response)
        }
        task.resume()
    }
}
