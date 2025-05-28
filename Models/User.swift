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
    var sns_endpoint_arn: String?

    var id: String{
        username
    }
    
    var image: Image {
        Image(systemName: "party.popper.fill")
    }
}
