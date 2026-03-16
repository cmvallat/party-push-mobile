//
//  DeleteGuestResponse.swift
//  PartyPushMobileApp
//
//  Created by Christian Vallat on 3/15/26.
//

struct DeleteGuestAPIResponse: Codable {
    let Success: Bool
    let Message: String
    let NotificationSent: Bool
    let NotificationError: String?
}
