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
                
            case .verifyCode(let authUser):
                VerifyCodeView(authUser: authUser)
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
        return true
    }

    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        let tokenParts = deviceToken.map { data in String(format: "%02.2hhx", data) }
        let token = tokenParts.joined()
        print("Device Token: \(token)")
    };

    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
       print(error.localizedDescription)
    }

    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.banner, .badge, .sound])
    }
}
