//
//  PushNotificationTestView.swift
//  PartyPushMobileApp
//
//  Created by Christian Vallat on 9/8/24.
//

import SwiftUI

struct PushNotificationTestView: View {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    init() {
        requestPushAuthorization();
    }

    var body: some View {
        Button("Send notifications") {
//            sendNotification();
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        PushNotificationTestView()
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
