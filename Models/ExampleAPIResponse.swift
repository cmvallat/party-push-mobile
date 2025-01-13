//
//  ExampleAPIResponse.swift
//  PartyPushMobileApp
//
//  Created by Christian Vallat on 1/8/25.
//

import Foundation
import SwiftUI

struct ExampleAPIResponse: Hashable, Codable, Identifiable {
    var message: String
    var id: String{
        message
    }
}
