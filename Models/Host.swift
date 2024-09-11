//
//  Host.swift
//  PartyPushMobileApp
//
//  Created by Christian Vallat on 8/30/24.
//

import Foundation
import SwiftUI

struct Host: Hashable, Codable, Identifiable {
    var username: String
    var party_name: String
    var party_code: String
    var invite_only: Int
    var cognito_username: String
    
    var id: String{
        username
    }
}
