//
//  AuthTestView.swift
//  Song_Requester
//
//  Created by Christian Vallat on 8/2/24.
//

import SwiftUI

struct AuthTestView: View {
    
    // to test AuthController functions
    let authUser: AuthUser
    
    var body: some View {
        Text("Email: \(authUser.email)")
        Text("Password: \(authUser.password)")
        Text("Id Token: \(authUser.idToken)")
        Text("Access Token: \(authUser.accessToken)")
        Text("Refresh Token: \(authUser.refreshToken)")
    }
}

#Preview {
    AuthTestView(authUser: AuthUser())
}
