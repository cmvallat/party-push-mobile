//
//  SandboxView.swift
//  PartyPushMobileApp
//
//  Created by Christian Vallat on 9/23/24.
//


import SwiftUI

// Todo: move to Common
struct ApiResponseFormat: Codable{
    let statusCode: Int
    let body: String
    let isBase64Encoded: Bool
}

struct SandboxView: View {
    
    var host: Host
    let authUser: AuthUser
    
    var body: some View {
        VStack
        {
            Text("Hello World")
        }
    }
}

//#Preview {
//    SandboxView(host:hosts[0], authUser: AuthUser())
//}
