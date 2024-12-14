//
//  CategorizedHost.swift
//  PartyPushMobileApp
//
//  Created by Christian Vallat on 9/25/24.
//

import Foundation
import SwiftUI

struct CategorizedHost: Hashable, Codable, Identifiable {
    var username: String
    var party_name: String
    var party_code: String
    var invite_only: Int
    var cognito_username: UUID
    var isHostedParty: Bool = true
    
    var id: String{
        party_code
    }
}
