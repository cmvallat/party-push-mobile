//
//  APIResponse.swift
//  PartyPushMobileApp
//
//  Created by Christian Vallat on 1/8/25.
//

import Foundation
import SwiftUI

struct APIResponse<T: Decodable>: Decodable, Identifiable {
    var message: String
    // generic array so we can decode response to any model, e.g. Food, Host, User etc.
    var data: [T]?
    var id: String{
        message
    }
}
