//
//  AuthFlowButton.swift
//  PartyPushMobileApp
//
//  Created by Nicholas Georgiou on 5/16/25.
//

import SwiftUI

struct AuthFlowButton: View {
    var label: String
    var isPrimary: Bool
    var color: Color
    var onClick: () -> Void
    
    var body: some View {
        Button(label) {
            onClick()
        }
        .foregroundColor(isPrimary ? .white : color)
        .frame(maxWidth: 300, maxHeight: 45)
        .font(.headline)
        .background(isPrimary ? color : nil)
        .clipShape(RoundedRectangle(cornerRadius: 5))
        .overlay(isPrimary ? nil :
            RoundedRectangle(cornerRadius: 6)
                .stroke(color, lineWidth: 2)
        )
    }
}
