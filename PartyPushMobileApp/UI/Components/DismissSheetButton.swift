//
//  DismissSheetButton.swift
//  PartyPushMobileApp
//
//  Created by Christian Vallat on 7/8/25.
//
import SwiftUI

struct DismissSheetButton: View {
    var onDismiss: () -> Void
    var body: some View {
        Button(action: onDismiss) {
            ZStack {
                Circle()
                    .fill(Palette.lighterButtonBackground)
                    .frame(width: 36, height: 36)
                    .overlay(
                        Circle().stroke(Palette.accentBlue, lineWidth: 1)
                    )
                Image(systemName: "xmark")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(Palette.accentBlue)
            }
        }
        .padding(.top, 8)
        .padding(.trailing, 8)
    }
}
