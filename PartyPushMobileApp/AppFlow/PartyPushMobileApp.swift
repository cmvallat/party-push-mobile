//
//  Song_RequesterApp.swift
//  Song_Requester
//
//  Created by Christian Vallat on 12/21/23.
//

import SwiftUI
import TipKit

@main
struct PartyPushMobileApp: App {
    
    @UIApplicationDelegateAdaptor private var appDelegate: AppDelegate
    @ObservedObject var sessionManager = SessionManager()
    @StateObject var appState = AppState()
    
    init() {
        // For development only: clear all UserDefaults
//        if let bundle = Bundle.main.bundleIdentifier {
//            UserDefaults.standard.removePersistentDomain(forName: bundle)
//            UserDefaults.standard.synchronize()
//        }
        // For development only:, uncomment to ensure they show up each time
//        try? Tips.resetDatastore()
        try? Tips.configure()
        sessionManager.checkForExistingSession()
    }
    
    var body: some Scene {
        WindowGroup {
            AppEntryRootView()
                .environmentObject(sessionManager)
        }
    }
}

class AppDelegate: NSObject, UIApplicationDelegate, UNUserNotificationCenterDelegate {

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        UNUserNotificationCenter.current().delegate = self

        return true
    }
    
    func application(_ application: UIApplication, continue userActivity: NSUserActivity, restorationHandler: @escaping ([UIUserActivityRestoring]?) -> Void) -> Bool {
          if userActivity.activityType == NSUserActivityTypeBrowsingWeb, let url = userActivity.webpageURL {
              print("AppDelegate received Universal Link: \(url)")
              NotificationCenter.default.post(name: Notification.Name("UniversalLinkOpened"), object: url)
              return true
          }
          return false
      }

    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        let tokenParts = deviceToken.map { data in String(format: "%02.2hhx", data) }
        let token = tokenParts.joined()
//        print("Device Token: \(token)")
        
        UserDefaults.standard.set(token, forKey: "deviceToken")
    };

    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
       print(error.localizedDescription)
    }

    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.banner, .badge, .sound])
    }

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

