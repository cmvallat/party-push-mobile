//
//  UserManagementPage.swift
//  Song_Requester
//
//  Created by Christian Vallat on 8/4/24.
//

import Foundation
import SwiftUI
import AuthenticationServices

struct UserManagementPage: View {
    
    let authUser: AuthUser
    
    var body: some View 
    {
        VStack
        {
            Spacer()
            
            HostList(authUser: authUser)
            GuestList(authUser: authUser)
            
            Spacer()
        }
        .padding([.leading,.trailing], 15)
        .background(Gradient(
            colors: [.blue, .pink]).opacity(0.2))
        .onAppear(perform: {
            sendNotification(authUser: authUser, title: "Party Push", body: "Hi, welcome back to party push!")
        })
    }
}

#Preview {
    UserManagementPage(authUser: AuthUser())
}
