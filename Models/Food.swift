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
    var username: String
    var cognito_username: UUID
    
    // Todo: add constraint to only have one item named the same at a party
    var id: String{
        item_name + party_code
    }
}
