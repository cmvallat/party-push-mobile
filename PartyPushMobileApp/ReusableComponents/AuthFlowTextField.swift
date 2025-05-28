//
//  AuthFlowTextField.swift
//  PartyPushMobileApp
//
//  Created by Nicholas Georgiou on 5/16/25.
//

import SwiftUI

struct AuthFlowTextField: View {
    var label: String
    var value: Binding<String>
    var secure: Bool
    
    var body: some View {
        if (secure) {
            return AnyView(
                SecureField(
                    label,
                    text: value
                )
                .textFieldStyle(.roundedBorder)
                .font(.title)
                .frame(width: 300)
                .autocapitalization(.none)
            )
        } else {
            return AnyView(
                TextField(
                    label,
                    text: value
                )
                .textFieldStyle(.roundedBorder)
                .font(.title)
                .frame(width: 300)
                .autocapitalization(.none)
            )
        }
    }
}
