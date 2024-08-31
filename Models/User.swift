//
//  User.swift
//  PartyPushMobileApp
//
//  Created by Christian Vallat on 8/30/24.
//

import Foundation
import SwiftUI

struct User: Hashable, Codable, Identifiable {
    var id: Int
    var username: String
    var password: String
    var phone: String
    
    var image: Image {
        Image(systemName: "party.popper.fill")
    }
}
