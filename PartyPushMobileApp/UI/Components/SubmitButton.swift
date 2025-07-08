//
//  SubmitButton.swift
//  PartyPushMobileApp
//
//  Created by Christian Vallat on 7/8/25.
//
import SwiftUI

struct SubmitButton: View {
    var title: String = "Submit"
    var isLoading: Bool = false
    var action: () -> Void
    var body: some View {
        Button(action: action) {
            if isLoading {
                ProgressView()
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
            } else {
                Text(title)
                    .font(.system(size: 18, weight: .semibold, design: .rounded))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
            }
        }
        .background(Palette.accentBlue)
        .cornerRadius(14)
        .shadow(color: Palette.accentBlue.opacity(0.6), radius: 8, x: 0, y: 4)
        .disabled(isLoading)
        .padding(.horizontal, 20)
    }
}
