//
//  SessionManager.swift
//  Song_Requester
//
//  Created by Christian Vallat on 8/4/24.
//

import Foundation

private let PARTY_ROLE_KEY = "lastPartyRole"
private let PARTY_HOST_KEY = "lastPartyHost"

enum AuthState {
    case unauthorized(LoginFlow)
    case home(authUser: AuthUser, appState: AppState)
    case guest(host: Host, authUser: AuthUser, appState: AppState)
    case host(host: Host, authUser: AuthUser, appState: AppState)

    enum LoginFlow {
        case login
        case signUp
    }
}


final class SessionManager : ObservableObject {
    @Published var authState: AuthState = .unauthorized(.login)

    // not sensitive so we don't need to store elsewhere
//    let clientId: String = "up7gikj8g2jb4lpvqekgdumap"
    let clientId: String = "2bvppaqrastqtsnilgpi6kttr5"
    
    let cognitoUrl: URL = URL(string: "https://cognito-idp.us-east-1.amazonaws.com/")!
    
    private func saveLastParty(role: String, host: Host) {
        if let hostData = try? JSONEncoder().encode(host) {
            UserDefaults.standard.set(role, forKey: PARTY_ROLE_KEY)
            UserDefaults.standard.set(hostData, forKey: PARTY_HOST_KEY)
        }
    }
    private func clearLastParty() {
        UserDefaults.standard.removeObject(forKey: PARTY_ROLE_KEY)
        UserDefaults.standard.removeObject(forKey: PARTY_HOST_KEY)
    }
    private func loadLastParty() -> (role: String, host: Host)? {
        guard let role = UserDefaults.standard.string(forKey: PARTY_ROLE_KEY),
              let data = UserDefaults.standard.data(forKey: PARTY_HOST_KEY),
              let host = try? JSONDecoder().decode(Host.self, from: data)
        else { return nil }
        return (role, host)
    }

    func showHome(authUser: AuthUser, appState: AppState) {
        print("show Home called")
        clearLastParty()
        authState = .home(authUser: authUser, appState: appState)
    }
    
    func showGuest(host: Host, authUser: AuthUser, appState: AppState) {
        saveLastParty(role: "guest", host: host)
        authState = .guest(host: host, authUser: authUser, appState: appState)
    }
    
    func showHost(host: Host, authUser: AuthUser, appState: AppState) {
        saveLastParty(role: "host", host: host)
        authState = .host(host: host, authUser: authUser, appState: appState)
    }

    func showLogin() {
        authState = .unauthorized(.login)
    }

    func showSignUp() {
        authState = .unauthorized(.signUp)
    }
    
    func checkForExistingSession() {
        let authUser = AuthUser()
        let appState = AppState()
        if authUser.loadTokensAndValidate() {
            if let (role, host) = loadLastParty() {
                if role == "host" {
                    showHost(host: host, authUser: authUser, appState: appState)
                } else if role == "guest" {
                    showGuest(host: host, authUser: authUser, appState: appState)
                } else {
                    showHome(authUser: authUser, appState: appState)
                }
            } else {
                showHome(authUser: authUser, appState: appState)
            }
        } else {
            showLogin()
        }
    }
    
    func signUp(email: String, password: String, username: String, completion: @escaping (Result<AuthUser, Error>) -> Void) {
        let authUser = AuthUser()
        authUser.username = username
        authUser.password = password
        authUser.email = email
        
//        print("Attempting sign up for \(email)")
        
        let parameters: [String: Any] = [
            "Username": authUser.username,
            "Password": authUser.password,
            "ClientId": clientId,
            "UserAttributes": [
                [
                    "Name": "email",
                    "Value": authUser.email
                ]
            ]
        ]

        let result = waitForRequest(authUser: authUser, url: "AWSCognitoIdentityProviderService.SignUp", method: "POST", parameters: parameters)
        
        if result.0 == "Success" {
            completion(.success(authUser))
        }
        else {
            let error = NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: result.0])
            completion(.failure(error))
        }
    }
    
    func login(username: String, password: String, completion: @escaping (Result<AuthUser, Error>) -> Void) {
        let authUser = AuthUser()
        authUser.username = username
        authUser.password = password
        
        let parameters: [String: Any] = [
            "AuthFlow": "USER_PASSWORD_AUTH",
            "AuthParameters": [
                "USERNAME" : authUser.username,
                "PASSWORD": authUser.password,
            ],
            "ClientId": clientId
        ]
        
        let result = waitForRequest(authUser: authUser, url: "AWSCognitoIdentityProviderService.InitiateAuth", method: "Post", parameters: parameters)
                
        // happy path
        if(result.0 == "Success")
        {
            authUser.accessToken = result.1.accessToken
            authUser.idToken = result.1.idToken
            authUser.refreshToken = result.1.refreshToken
            authUser.saveTokensToKeychain()
            
            completion(.success(authUser))
        }
        // if the user just signed up
        else if (result.0 == "User is not confirmed.") {
            // set tokens so we can use them to make api calls
            authUser.accessToken = result.1.accessToken
            authUser.idToken = result.1.idToken
            authUser.refreshToken = result.1.refreshToken
            
            completion(.success(authUser))
        }
        else {
            let error = NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: result.0])
            completion(.failure(error))
        }
    }

    func sendPasswordResetCode(authUser: AuthUser) -> String {
        print("sendPasswordResetCode: Username ( \(authUser.email) )")
        let parameters: [String: Any] = [
            "Username" : authUser.email,
            "ClientId": clientId
        ]
        let returnMessage = waitForRequest(authUser: authUser, url: "AWSCognitoIdentityProviderService.ForgotPassword", method: "Post", parameters: parameters)
        
        return returnMessage.0
    }
    
    func resetPassword(authUser: AuthUser, newPassword: String, confirmationCode: String) -> String {
        print("resetPassword: Username ( \(authUser.email) )")
        let parameters: [String: Any] = [
            "Username" : authUser.email,
            "Password" : newPassword,
            "ConfirmationCode": confirmationCode,
            "ClientId": clientId
        ]
        var returnMessage = waitForRequest(authUser: authUser, url: "AWSCognitoIdentityProviderService.ConfirmForgotPassword", method: "Post", parameters: parameters)
        if(returnMessage.0 == "Success")
        {
            returnMessage.0 = "We've correctly reset your password for email \(authUser.email)."
        }
        else
        {
            returnMessage.0 = "Something went wrong with resetting your password for email \(authUser.email)."
        }
        return returnMessage.0
    }
    
    func verifyEmail(authUser: AuthUser, confirmationCode: String, completion: @escaping (Result<AuthUser, Error>) -> Void) {
//        print("verifyEmail: Username ( \(authUser.email) )")

        let parameters: [String: Any] = [
            "ConfirmationCode": confirmationCode,
            "Username": authUser.username,
            "ClientId": clientId
        ]

        let result = waitForRequest(authUser: authUser, url: "AWSCognitoIdentityProviderService.ConfirmSignUp", method: "POST", parameters: parameters)

        if result.0 == "Success" {
            // Login if verification succeeded
            login(username: authUser.username, password: authUser.password) { loggedInUser in
                switch loggedInUser {
                case .success(let user):
                    DispatchQueue.main.async {
                        user.email = authUser.email
                        completion(.success(user))
                    }
                case .failure(let error):
                    DispatchQueue.main.async {
                        let err = NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: "Login failed after verification: \(error.localizedDescription)"])
                        completion(.failure(err))
                    }
                }
            }
        } else {
            // Verification failed
            DispatchQueue.main.async {
                let err = NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: "Verification failed: \(result.0)"])
                completion(.failure(err))
            }
        }
    }

    
    func resendCode(authUser: AuthUser) -> String {
        print("resendCode: Username ( \(authUser.email) )")
        let parameters: [String: Any] = [
            "Username": authUser.email,
            "ClientId": clientId
        ]
        var returnMessage = waitForRequest(authUser: authUser, url: "AWSCognitoIdentityProviderService.ResendConfirmationCode", method: "Post", parameters: parameters).0
        if(returnMessage == "Success")
        {
            returnMessage = "Success! A new verification code has been sent to the email address \(authUser.email)"
        }
        else
        {
            returnMessage = "Hmm, we could not re-send a verification code to the email address \(authUser.email). Maybe sign up again and check that your email is correct?"
        }
        return returnMessage
    }
    
    func waitForRequest(authUser: AuthUser, url: String, method: String, parameters: [String: Any]) -> (String, AuthUser) {
        var retCode = "Success"
        // BUILD REQUEST
        var request = URLRequest(url: cognitoUrl)
        request.httpMethod = method
        request.setValue(url, forHTTPHeaderField: "X-Amz-Target")
        request.setValue("application/x-amz-json-1.1", forHTTPHeaderField: "Content-Type")
        
        request.httpBody = try? JSONSerialization.data(withJSONObject: parameters)
        let sem = DispatchSemaphore(value: 0)

        // RUN REQUEST
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data, error == nil else {
                retCode = error?.localizedDescription ?? "Failure"
                sem.signal()
                return
            }
            let dataJSON = try? JSONSerialization.jsonObject(with: data, options: [])
            if let dataJSON = dataJSON as? [String: Any] {
                if dataJSON["message"] != nil {
                    retCode = dataJSON["message"] as? String ?? "Failure"
                }
                if dataJSON["AuthenticationResult"] != nil {
                    let authRes = dataJSON["AuthenticationResult"] as! [String: Any]
                    authUser.accessToken = authRes["AccessToken"] as? String ?? ""
                    authUser.idToken = authRes["IdToken"] as? String ?? ""
                    authUser.refreshToken = authRes["RefreshToken"] as? String ?? ""
                }
            }
            sem.signal()
        }
        task.resume()
        sem.wait()
        
        // RETURN
        // if authUser was changed, we will retain those changes
        return (retCode, authUser)
    }
    
    func logout(authUser: AuthUser) {
        clearLastParty()
        authUser.deleteTokensFromKeychain()
        authUser.accessToken = ""
        authUser.idToken = ""
        authUser.refreshToken = ""
        DispatchQueue.main.async {
            self.authState = .unauthorized(.login)
        }
    }
    
    func deleteCurrentUser(authUser: AuthUser, completion: @escaping (Result<Void, Error>) -> Void) {
        //print("[DeleteUser] Provided accessToken: \(authUser.accessToken)")
        guard !authUser.accessToken.isEmpty else {
            completion(.failure(NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: "Access token is missing. Please log in again."])))
            return
        }
        
        var request = URLRequest(url: cognitoUrl)
        request.httpMethod = "POST"
        request.setValue("AWSCognitoIdentityProviderService.DeleteUser", forHTTPHeaderField: "X-Amz-Target")
        request.setValue("application/x-amz-json-1.1", forHTTPHeaderField: "Content-Type")
        let body: [String: Any] = ["AccessToken": authUser.accessToken]
        request.httpBody = try? JSONSerialization.data(withJSONObject: body)
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                //print("[DeleteUser] Network error: \(error)")
                completion(.failure(error))
                return
            }
            if let httpResponse = response as? HTTPURLResponse {
                //print("[DeleteUser] HTTP Status: \(httpResponse.statusCode)")
                if let data = data, let body = String(data: data, encoding: .utf8) {
                    //print("[DeleteUser] Response body: \(body)")
                } else {
                    //print("[DeleteUser] No response body data.")
                }
                if !(200...299).contains(httpResponse.statusCode) {
                    completion(.failure(NSError(domain: "", code: httpResponse.statusCode, userInfo: [NSLocalizedDescriptionKey: "DeleteUser failed with status \(httpResponse.statusCode)"])))
                    return
                }
            }
            DispatchQueue.main.async {
                self.logout(authUser: authUser)
                completion(.success(()))
            }
        }
        task.resume()
    }
}
