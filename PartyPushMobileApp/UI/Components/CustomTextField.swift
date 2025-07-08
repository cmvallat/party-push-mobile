//
//  CustomTextField.swift
//  PartyPushMobileApp
//
//  Created by Christian Vallat on 7/8/25.
//
import SwiftUI

struct CustomTextField: View {
    @Binding var text: String
    let placeholder: String

    var body: some View {
        ZStack(alignment: .leading) {
            if text.isEmpty {
                Text(placeholder)
                    .foregroundColor(Palette.placeholderColor)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
            }
            TextField("", text: $text)
                .foregroundColor(Palette.deepTextColor)
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
        }
        .background(
            RoundedRectangle(cornerRadius: 14)
                .fill(Palette.lighterButtonBackground)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 14)
                .stroke(Palette.accentBlue, lineWidth: 1)
        )
    }
}
