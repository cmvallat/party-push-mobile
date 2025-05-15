//
//  Song_RequesterApp.swift
//  Song_Requester
//
//  Created by Christian Vallat on 12/21/23.
//

import SwiftUI

@main
struct PartyPushMobileApp: App {
    
    @UIApplicationDelegateAdaptor private var appDelegate: AppDelegate
    @ObservedObject var sessionManager = SessionManager()
    
    var body: some Scene {
        WindowGroup {
            switch sessionManager.authState{
                
            case .login(let authUser):
                LoginView(authUser: authUser)
                    .environmentObject(sessionManager)
                
            case .signUp:
                SignUpView()
                    .environmentObject(sessionManager)
                
            case .session(let authUser):
                UserManagementPage(authUser: authUser)
                    .environmentObject(sessionManager)
                
            case .resetPassword(let authUser):
                PasswordResetPrompt(authUser: authUser)
                    .environmentObject(sessionManager)
            }
        }
    }
}

class AppDelegate: NSObject, UIApplicationDelegate, UNUserNotificationCenterDelegate {

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        UNUserNotificationCenter.current().delegate = self

        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            guard granted else {
                print("User denied notification permissions")
                return
            }

            DispatchQueue.main.async {
                UIApplication.shared.registerForRemoteNotifications()
            }
        }

        return true
    }

    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        let tokenParts = deviceToken.map { data in String(format: "%02.2hhx", data) }
        let token = tokenParts.joined()
        
        print("Device Token: \(token)")
        
        // register their device so we can use it in our SNS list for push notifications
//        registerDeviceTokenWithBackend(token: token)
    };

    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
       print(error.localizedDescription)
    }

    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.banner, .badge, .sound])
    }
    
//    func registerDeviceTokenWithBackend(token: String) {
//        guard let userId = UserDefaults.standard.string(forKey: "cognito_username") else {
//            print("Missing cognito_username in UserDefaults")
//            return
//        }
//        
//        guard let partyCode = UserDefaults.standard.string(forKey: "party_code") else {
//            print("Missing party_code in UserDefaults")
//            return
//        }
//
//        guard let url = URL(string: "https://qyb4z6bik0.execute-api.us-east-1.amazonaws.com/Prod/hello") else {
//            print("Invalid backend URL")
//            return
//        }
//
//        var request = URLRequest(url: url)
//        request.httpMethod = "POST"
//        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
//
//
//        do {
//            request.httpBody = try JSONSerialization.data(withJSONObject: body, options: [])
//        } catch {
//            print("Failed to encode JSON: \(error)")
//            return
//        }
//
//        URLSession.shared.dataTask(with: request) { data, response, error in
//            if let error = error {
//                print("Registration failed: \(error)")
//            } else {
//                print("Device token registered successfully with backend")
//            }
//        }.resume()
//    }
    
//    func registerDeviceTokenWithBackend(token: String) {
//        // SNS Platform Application ARN for APNS (replace with your actual ARN)
//        let platformApplicationArn = "arn:aws:sns:us-east-1:123456789012:app/APNS/YourApp"
//
//        // Create the SNS endpoint
//        let snsClient = AmazonSimpleNotificationServiceClient()
//
//        let request = CreatePlatformEndpointRequest(
//            platformApplicationArn: platformApplicationArn,
//            token: token
//        )
//
//        snsClient.createPlatformEndpoint(request) { result, error in
//            if let error = error {
//                print("Failed to create SNS platform endpoint: \(error)")
//                return
//            }
//            
//            guard let result = result, let endpointArn = result.endpointArn else {
//                print("SNS response didn't contain endpoint ARN")
//                return
//            }
//            
//            // Store the endpoint ARN for later use (e.g., after login)
//            UserDefaults.standard.set(endpointArn, forKey: "sns_endpoint_arn")
//            
//            // Optionally, send the endpoint ARN to your backend to associate it with the user later
//            print("Device token registered successfully with SNS. Endpoint ARN: \(endpointArn)")
//
//            // You can also call your backend to associate the endpoint ARN with the user after login
//            // For now, we're just saving it locally.
//        }
//    }


    func checkNotificationRegistration(for authUser: AuthUser, partyCode: String, completion: @escaping (Bool) -> Void) {
        let urlString = "https://5yi62brbq6.execute-api.us-east-1.amazonaws.com/Prod/hello/username=\(authUser.username)"
        guard let url = URL(string: urlString) else {
            completion(false)
            return
        }

        URLSession.shared.dataTask(with: url) { data, _, error in
            guard let data = data, error == nil else {
                completion(false)
                return
            }

            if let result = try? JSONDecoder().decode(NotificationStatusResponse.self, from: data) {
                completion(result.alreadyRegistered)
            } else {
                completion(false)
            }
        }.resume()
    }

    struct NotificationStatusResponse: Decodable {
        let alreadyRegistered: Bool
    }


}
