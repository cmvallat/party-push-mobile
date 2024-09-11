//
//  User.swift
//  PartyPushMobileApp
//
//  Created by Christian Vallat on 8/30/24.
//

import Foundation
import SwiftUI

struct User: Hashable, Codable, Identifiable {
    var username: String
    var email: String
    var cognito_username: UUID
    
    var id: UUID{
        cognito_username
    }
    
    var image: Image {
        Image(systemName: "party.popper.fill")
    }
}
