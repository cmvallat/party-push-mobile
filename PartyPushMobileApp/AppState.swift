//
//  AppState.swift
//  PartyPushMobileApp
//
//  Created by Christian Vallat on 5/31/25.
//

import Foundation
import Combine
import SwiftUI

class AppState: ObservableObject {
    enum AtPartyStatus: String {
        case active
        case left
        case removed
    }
    @Published var endedPartyCode: String? = nil
    @Published var needToRefresh: Bool = false
    @Published var kickedGuestUsername: String? = nil
    // need to declare enum here
    @Published var atPartyState: AtPartyStatus = .active
}
