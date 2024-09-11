//
//  Guest.swift
//  PartyPushMobileApp
//
//  Created by Christian Vallat on 9/2/24.
//

import Foundation
import SwiftUI

struct Guest: Hashable, Codable, Identifiable 
{
    var username: String
    var guest_name: String
    var party_code: String
    var at_party: Int
    var cognito_username: String
    
    var id: String{
        username
    }
}
