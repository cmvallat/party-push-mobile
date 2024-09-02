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
    var phone_number: String
    var spotify_device_id: String
    var invite_only: Int
    
    var id: String{
        username
    }
}
