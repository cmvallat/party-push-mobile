//
//  SessionManager.swift
//  Song_Requester
//
//  Created by Christian Vallat on 8/4/24.
//

import Foundation

enum AuthState {
    case unauthorized(LoginFlow)
    case resetPassword(authUser: AuthUser)
    case session(authUser: AuthUser)

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
    
    func showSession(authUser: AuthUser) {
        authState = .session(authUser: authUser)
    }

    func showLogin() {
        authState = .unauthorized(.login)
    }

    func showSignUp() {
        authState = .unauthorized(.signUp)
    }
    
    func showPasswordReset(authUser: AuthUser){
        authState = .resetPassword(authUser: authUser)
    }
    
    func signUp(email: String, password: String, username: String, completion: @escaping (Result<AuthUser, Error>) -> Void) {
        let authUser = AuthUser()
        authUser.username = username
        authUser.password = password
        authUser.email = email
        
        print("Attempting sign up for \(email)")
        
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
        
        print("login: Username ( \(authUser.username) )")
        print("login: Password ( \(authUser.password) )")
        
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
            
            print("success accessToken: " + authUser.accessToken)
            print("success idToken: " + authUser.idToken)
            print("success refreshToken: " + authUser.refreshToken)
            
            completion(.success(authUser))
        }
        // if the user just signed up
        else if (result.0 == "User is not confirmed.") {
            // set tokens so we can use them to make api calls
            authUser.accessToken = result.1.accessToken
            authUser.idToken = result.1.idToken
            authUser.refreshToken = result.1.refreshToken
            
            print("not confirmed accessToken: " + authUser.accessToken)
            print("not confirmed idToken: " + authUser.idToken)
            print("not confirmed refreshToken: " + authUser.refreshToken)
            
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
        print("verifyEmail: Username ( \(authUser.email) )")

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
        print(returnMessage)
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
                print("ERROR")
                retCode = error?.localizedDescription ?? "Failure"
                sem.signal()
                return
            }
            let dataJSON = try? JSONSerialization.jsonObject(with: data, options: [])
            if let dataJSON = dataJSON as? [String: Any] {
                print(dataJSON)
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
}
