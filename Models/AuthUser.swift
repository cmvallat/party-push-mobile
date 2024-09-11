//
//  AuthUser.swift
//  Song_Requester
//
//  Created by Christian Vallat on 8/6/24.
//

import Foundation
import Observation

@Observable
class AuthUser {
    var email: String = ""
    var username: String = ""
    var password: String = ""
    var cognito_username = UUID()
    var accessToken: String = ""
    var idToken: String = ""
    var refreshToken: String = ""
}

