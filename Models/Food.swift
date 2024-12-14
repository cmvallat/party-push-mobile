//
//  Food.swift
//  PartyPushMobileApp
//
//  Created by Christian Vallat on 9/26/24.
//

import Foundation
import SwiftUI

struct Food: Hashable, Codable, Identifiable {
    var item_name: String
    var party_code: String
    var status: String
    var cognito_username: UUID
    var username: String
    
    var id: String{
        item_name
    }
}
