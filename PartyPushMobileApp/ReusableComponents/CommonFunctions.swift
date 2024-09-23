//
//  CommonFunctions.swift
//  PartyPushMobileApp
//
//  Created by Christian Vallat on 9/23/24.
//

import Foundation
import SwiftUI
import AuthenticationServices
import JWTDecode

func sendNotification(authUser: AuthUser, title: String, body: String)
{
    let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.sound = UNNotificationSound.default

        // Set up a trigger for the notification (wait 5s)
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: (5), repeats: false)

        // Create the request
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)

        // Add the request to the notification center
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print(error.localizedDescription)
            } else {
                print("Notification scheduled")
            }
        }
}

// Todo: determine if we need this function? Or do we just need to add the token to the call above? If we don't need it, make sure to remove JWTDecode dependency
func authorizeCall(authUser: AuthUser) -> AuthUser
{
    let accessToken = try? decode(jwt: authUser.accessToken)
    let idToken = try? decode(jwt: authUser.idToken)
    let cognito_username_from_accessToken = accessToken?["username"].string ?? "defaultAccessToken"
    let cognito_username_from_idToken = idToken?["cognito:username"].string ?? "defaultIdToken"
    
    if(cognito_username_from_accessToken != cognito_username_from_idToken)
    {
        // if the cognito username of the tokens don't match, then we have a problem and shouldn't be accessing the API with this cognito username
        // Todo: handle here
    }
    else
    {
        // if they do match, we're good to call the API for the requested user's objects
        
        // set the cognito_username field here to call api with
        
        // either cognito_username variable works here
        // since they would be the same in this check
        authUser.cognito_username = UUID(uuidString: cognito_username_from_accessToken) ?? UUID()
    }
    
    return authUser
}
