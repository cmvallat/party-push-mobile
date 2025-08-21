//
//  PushNotificationTestView.swift
//  PartyPushMobileApp
//
//  Created by Christian Vallat on 9/8/24.
//

import SwiftUI

struct PushNotificationTestView: View
{
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    init() {
        requestPushAuthorization();
    }

    var body: some View {
        Button("Send test notification") {
            sendNotification(authUser: AuthUser(), title: "Party Push", body: "This is a test notification from Party Push")
        }
    }
}

func requestPushAuthorization() {
    UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { success, error in
        if success {
            print("Push notifications allowed")
        } else if let error = error {
            print(error.localizedDescription)
        }
    }
}

func registerForNotifications() {
    UIApplication.shared.registerForRemoteNotifications()
}

#Preview {
    PushNotificationTestView()
}
