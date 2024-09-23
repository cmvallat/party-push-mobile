//
//  SessionManager.swift
//  Song_Requester
//
//  Created by Christian Vallat on 8/4/24.
//

import Foundation

enum AuthState{
    case signUp
    case login(authUser: AuthUser)
    case verifyCode(authUser: AuthUser)
    case session(authUser: AuthUser)
    case resetPassword(authUser: AuthUser)
}

final class SessionManager : ObservableObject {
    @Published var authState: AuthState = .signUp
    
    // not sensitive so we don't need to store elsewhere
    let clientId: String = "up7gikj8g2jb4lpvqekgdumap"
    let cognitoUrl: URL = URL(string: "https://cognito-idp.us-east-1.amazonaws.com/")!
    
    func showLogin(authUser: AuthUser){
        authState = .login(authUser: authUser)
    }
    
    func showSignUp(){
        authState = .signUp
    }
    
    func showVerifyCode(authUser: AuthUser){
        authState = .verifyCode(authUser: authUser)
    }
    
    func showSession(authUser: AuthUser){
        authState = .session(authUser: authUser)
    }
    
    func showPasswordReset(authUser: AuthUser){
        authState = .resetPassword(authUser: authUser)
    }
    
    func signUp(authUser: AuthUser) -> String {
        print("SIGNUP: Username ( \(authUser.email) )")
        let parameters: [String: Any] = [
            "Username" : authUser.email,
            "Password" : authUser.password,
            "ClientId": clientId
        ]
        var retCode = waitForRequest(authUser: authUser, url: "AWSCognitoIdentityProviderService.SignUp", method: "Post", parameters: parameters)
        if (retCode.0) == "Success"
        {
            retCode.0 = login(authUser: authUser)
        }
        if(retCode.0 == "User is not confirmed.")
        {
            self.showVerifyCode(authUser: retCode.1)
        }
        return retCode.0
    }
    
    func login(authUser: AuthUser) -> String {
        print("login: Username ( \(authUser.email) )")
        let parameters: [String: Any] = [
            "AuthFlow": "USER_PASSWORD_AUTH",
            "AuthParameters": [
                "USERNAME" : authUser.email,
                "PASSWORD": authUser.password,
            ],
            "ClientId": clientId
        ]
        let result = waitForRequest(authUser: authUser, url: "AWSCognitoIdentityProviderService.InitiateAuth", method: "Post", parameters: parameters)
        if(result.0 == "Success")
        {
            // set access token and call management page
            // which should be able to access token to make calls
            authUser.accessToken = result.1.accessToken
            authUser.idToken = result.1.idToken
            authUser.refreshToken = result.1.refreshToken
//            self.showSession(authUser: authUser)
        }
        else if(result.0 == "User is not confirmed.")
        {
            self.showVerifyCode(authUser: result.1)
        }
        else if(result.0 == "Incorrect username or password")
        {
            // Todo: handle
            print(result.0)
        }
        return result.0
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
    
    func verifyEmail(authUser: AuthUser, confirmationCode: String) -> String {
        print("verifyEmail: Username ( \(authUser.email) )")
        let parameters: [String: Any] = [
            "ConfirmationCode": confirmationCode,
            "Username": authUser.email,
            "ClientId": clientId
        ]
        var retCode = waitForRequest(authUser: authUser, url: "AWSCognitoIdentityProviderService.ConfirmSignUp", method: "Post", parameters: parameters)
        if (retCode.0) == "Success" 
        {
            retCode.0 = login(authUser: authUser)
        }
        return retCode.0
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
