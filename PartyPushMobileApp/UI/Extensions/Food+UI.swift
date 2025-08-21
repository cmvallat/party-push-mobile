//
//  Food+UI.swift
//  PartyPushMobileApp
//
//  Created by Christian Vallat on 4/29/25.
//

import SwiftUI

extension Food {
    var statusIcon: Image {
        switch status {
        case "out":
            return Image(systemName: "exclamationmark.shield.fill")
        case "low":
            return Image(systemName: "exclamationmark.triangle.fill")
        case "full":
            return Image(systemName: "checkmark.circle.fill")
        default:
            return Image(systemName: "questionmark.circle.fill")
        }
    }

    var statusColor: Color {
        switch status {
        case "out":
            return .red
        case "low":
            return .yellow
        case "full":
            return .green
        default:
            return .gray
        }
    }
}
